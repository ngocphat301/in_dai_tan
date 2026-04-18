import { Controller } from "@hotwired/stimulus"

// Popup quảng cáo (bài blog loại quảng cáo + form SĐT): chỉ hiện lần đầu truy cập web (localStorage).
// ?ads_preview=1 (development) bỏ qua localStorage để kiểm tra.
const ADS_POPUP_STORAGE_KEY = "inTanDaiAdsPopupDone_v2"

export default class extends Controller {
  static targets = [ "dialog", "form", "error", "phone" ]
  static values = { preview: { type: Boolean, default: false } }

  connect () {
    if (!this.previewValue && this._alreadySeen()) return
    this._timer = window.setTimeout(() => this.open(), 500)
  }

  disconnect () {
    if (this._timer) window.clearTimeout(this._timer)
  }

  open () {
    const dlg = this.dialogTarget
    if (!dlg) return
    if (dlg.showModal) dlg.showModal()
    else dlg.setAttribute("open", "")
  }

  close (event) {
    event?.preventDefault()
    this._dismiss()
    const dlg = this.dialogTarget
    if (dlg?.close) dlg.close()
    else dlg?.removeAttribute("open")
  }

  backdropClose (event) {
    if (event.target === this.dialogTarget) this.close(event)
  }

  async submit (event) {
    event.preventDefault()
    if (!this.hasFormTarget) return
    this._clearError()
    const form = this.formTarget
    const token = document.querySelector('meta[name="csrf-token"]')?.content
    const fd = new FormData(form)
    try {
      const res = await fetch(form.action, {
        method: "POST",
        headers: {
          Accept: "application/json",
          "X-Requested-With": "XMLHttpRequest",
          "X-CSRF-Token": token || ""
        },
        body: fd
      })
      const data = await res.json().catch(() => ({}))
      if (res.ok && data.ok) {
        this._dismiss()
        this.close()
        return
      }
      const msg = (data.errors && data.errors.join(" ")) || "Gửi không thành công."
      this._showError(msg)
    } catch (_e) {
      this._showError("Lỗi mạng, thử lại sau.")
    }
  }

  _alreadySeen () {
    try {
      return window.localStorage.getItem(ADS_POPUP_STORAGE_KEY) === "1"
    } catch (_e) {
      return false
    }
  }

  _dismiss () {
    try {
      window.localStorage.setItem(ADS_POPUP_STORAGE_KEY, "1")
    } catch (_e) { /* private mode / disabled storage */ }
  }

  _clearError () {
    if (!this.hasErrorTarget) return
    this.errorTarget.textContent = ""
    this.errorTarget.hidden = true
  }

  _showError (message) {
    if (!this.hasErrorTarget) return
    this.errorTarget.textContent = message
    this.errorTarget.hidden = false
  }
}
