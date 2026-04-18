import { Controller } from "@hotwired/stimulus"

let CropperClass = null

async function ensureCropper () {
  if (CropperClass) return CropperClass
  const mod = await import("cropperjs")
  CropperClass = mod.default || mod
  return CropperClass
}

export default class extends Controller {
  static targets = ["file", "dialog", "image", "widthInput", "heightInput", "lockRatio", "dimsDisplay"]
  static values = {
    outputWidth: { type: Number, default: 1000 },
    outputHeight: { type: Number, default: 1250 },
    minOutput: { type: Number, default: 50 },
    maxOutput: { type: Number, default: 4000 },
    batch: { type: Boolean, default: false }
  }

  connect () {
    this._cropper = null
    this._objectUrl = null
    this._sizeDebounce = null
    this._clearBatchState()
    this._syncInputsFromValues()
  }

  disconnect () {
    if (this._sizeDebounce) clearTimeout(this._sizeDebounce)
    this._teardownCropper()
    this._revokeObjectUrl()
    this._clearBatchState()
  }

  pick () {
    const input = this.fileTarget
    if (this.batchValue) {
      const list = Array.from(input.files || []).filter((f) => f.type.startsWith("image/"))
      if (!list.length) return
      input.value = ""
      this._batchRemaining = list
      this._batchDone = []
      const titleEl = this.element.querySelector(".admin-image-crop__title")
      this._savedTitleHtml = titleEl ? titleEl.innerHTML : null
      this._startNextFromBatch()
      return
    }

    const file = input.files?.[0]
    if (!file || !file.type.startsWith("image/")) return

    this._mime = file.type
    this._revokeObjectUrl()
    this._objectUrl = URL.createObjectURL(file)
    const img = this.imageTarget
    img.addEventListener("load", () => { this._openDialog() }, { once: true })
    img.src = this._objectUrl
  }

  _startNextFromBatch () {
    const file = this._batchRemaining?.shift()
    if (!file) {
      this._finishBatch()
      return
    }
    this._mime = file.type
    this._batchCurrentBaseName = file.name.replace(/\.[^.]+$/, "") || "image"
    this._revokeObjectUrl()
    this._objectUrl = URL.createObjectURL(file)
    const img = this.imageTarget
    img.addEventListener("load", () => { this._openDialog() }, { once: true })
    img.src = this._objectUrl
  }

  sizeInputsChanged () {
    if (this._sizeDebounce) clearTimeout(this._sizeDebounce)
    this._sizeDebounce = setTimeout(() => {
      this._sizeDebounce = null
      this._reinitCropperIfOpen()
    }, 350)
  }

  lockToggled () {
    this._reinitCropperIfOpen()
  }

  _syncInputsFromValues () {
    if (!this.hasWidthInputTarget || !this.hasHeightInputTarget) return
    this.widthInputTarget.value = String(this.outputWidthValue)
    this.heightInputTarget.value = String(this.outputHeightValue)
    this._refreshDimsDisplay()
  }

  _clamp (n) {
    return Math.min(this.maxOutputValue, Math.max(this.minOutputValue, n))
  }

  _readOutputW () {
    if (this.hasWidthInputTarget) {
      const n = parseInt(this.widthInputTarget.value, 10)
      if (Number.isFinite(n)) return this._clamp(n)
    }
    return this.outputWidthValue
  }

  _readOutputH () {
    if (this.hasHeightInputTarget) {
      const n = parseInt(this.heightInputTarget.value, 10)
      if (Number.isFinite(n)) return this._clamp(n)
    }
    return this.outputHeightValue
  }

  _lockRatioOn () {
    return !this.hasLockRatioTarget || this.lockRatioTarget.checked
  }

  _refreshDimsDisplay () {
    if (!this.hasDimsDisplayTarget) return
    const w = this._readOutputW()
    const h = this._readOutputH()
    this.dimsDisplayTarget.innerHTML = `<strong>${w}×${h}px</strong>`
  }

  async _reinitCropperIfOpen () {
    if (!this.dialogTarget.open || !this._objectUrl) return
    this._refreshDimsDisplay()
    if (this.batchValue && this._batchRemaining !== undefined) {
      const titleEl = this.element.querySelector(".admin-image-crop__title")
      if (titleEl) {
        const cur = this._batchDone.length + 1
        const total = cur + this._batchRemaining.length
        const w = this._readOutputW()
        const h = this._readOutputH()
        titleEl.textContent =
          `Ảnh ${cur}/${total} — xuất ${w}×${h}px (kéo vùng, bấm Áp dụng)`
      }
    }
    this._teardownCropper()
    await this._mountCropper()
  }

  async _openDialog () {
    this._teardownCropper()
    this._syncInputsFromValues()
    this._refreshDimsDisplay()
    if (this.batchValue && this._savedTitleHtml != null) {
      const titleEl = this.element.querySelector(".admin-image-crop__title")
      if (titleEl) {
        const cur = this._batchDone.length + 1
        const total = cur + this._batchRemaining.length
        const w = this._readOutputW()
        const h = this._readOutputH()
        titleEl.textContent =
          `Ảnh ${cur}/${total} — xuất ${w}×${h}px (kéo vùng, bấm Áp dụng)`
      }
    }
    this.dialogTarget.showModal()
    await this._mountCropper()
  }

  async _mountCropper () {
    const Cropper = await ensureCropper()
    const w = this._readOutputW()
    const h = this._readOutputH()
    const locked = this._lockRatioOn()
    const ar = locked && h > 0 ? w / h : undefined
    this._cropper = new Cropper(this.imageTarget, {
      aspectRatio: ar,
      viewMode: 1,
      dragMode: "move",
      autoCropArea: 1,
      responsive: true,
      background: false
    })
  }

  backdrop (event) {
    if (event.target === this.dialogTarget) this.cancel()
  }

  cancel () {
    if (this.batchValue && this._batchRemaining !== undefined) {
      this._abortBatch()
      return
    }
    this.fileTarget.value = ""
    this._closeAndReset()
  }

  apply () {
    if (!this._cropper) return

    const cropper = this._cropper
    const inBatch = this.batchValue && this._batchRemaining !== undefined
    const w = this._readOutputW()
    const h = this._readOutputH()

    cropper.getCroppedCanvas({
      width: w,
      height: h,
      imageSmoothingEnabled: true,
      imageSmoothingQuality: "high"
    }).toBlob((blob) => {
      if (!blob) {
        cropper.destroy()
        this._cropper = null
        this._closeAndReset()
        return
      }
      const ext = this._mime === "image/png" ? "png" : "jpg"
      const type = ext === "png" ? "image/png" : "image/jpeg"

      if (inBatch) {
        const out = new File([blob], `${this._batchCurrentBaseName}-cropped.${ext}`, { type })
        this._batchDone.push(out)
        cropper.destroy()
        this._cropper = null
        if (this.dialogTarget.open) this.dialogTarget.close()
        this._revokeObjectUrl()
        this.imageTarget.removeAttribute("src")
        if (this._batchRemaining.length) {
          this._startNextFromBatch()
        } else {
          this._finishBatch()
        }
        return
      }

      const orig = this.fileTarget.files?.[0]
      const base = (orig?.name || "image").replace(/\.[^.]+$/, "")
      const file = new File([blob], `${base}-cropped.${ext}`, { type })
      const dt = new DataTransfer()
      dt.items.add(file)
      this.fileTarget.files = dt.files
      cropper.destroy()
      this._cropper = null
      if (this.dialogTarget.open) this.dialogTarget.close()
      this._revokeObjectUrl()
      this.imageTarget.removeAttribute("src")
    }, this._mime === "image/png" ? "image/png" : "image/jpeg", this._mime === "image/png" ? 1 : 0.92)
  }

  _finishBatch () {
    if (!this._batchDone?.length) {
      this._restoreBatchTitle()
      this._clearBatchState()
      return
    }
    const dt = new DataTransfer()
    this._batchDone.forEach((f) => dt.items.add(f))
    this.fileTarget.files = dt.files
    this._restoreBatchTitle()
    this._clearBatchState()
  }

  _abortBatch () {
    this.fileTarget.value = ""
    this._restoreBatchTitle()
    this._clearBatchState()
    this._closeAndReset()
  }

  _restoreBatchTitle () {
    const el = this.element.querySelector(".admin-image-crop__title")
    if (el && this._savedTitleHtml != null) el.innerHTML = this._savedTitleHtml
    this._savedTitleHtml = null
  }

  _clearBatchState () {
    this._batchRemaining = undefined
    this._batchDone = undefined
    this._batchCurrentBaseName = undefined
  }

  _closeAndReset () {
    if (this.dialogTarget.open) this.dialogTarget.close()
    this._teardownCropper()
    this._revokeObjectUrl()
    this.imageTarget.removeAttribute("src")
  }

  _teardownCropper () {
    if (this._cropper) {
      this._cropper.destroy()
      this._cropper = null
    }
  }

  _revokeObjectUrl () {
    if (this._objectUrl) {
      URL.revokeObjectURL(this._objectUrl)
      this._objectUrl = null
    }
  }
}
