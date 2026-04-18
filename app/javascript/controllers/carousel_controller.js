import { Controller } from "@hotwired/stimulus"

// Hai chế độ:
// - Mặc định (perView = 0): track rộng n × 100% viewport, mỗi slide chiếm 100/n % — dùng banner.
// - Peek (perView > 0 + target item): một hàng nhiều ô, mỗi ô rộng viewport/perView; next/prev dịch 1 ô.
export default class extends Controller {
  static targets = ["track", "slide", "dot", "viewport", "item"]
  static values = {
    index: { type: Number, default: 0 },
    interval: { type: Number, default: 0 },
    perView: { type: Number, default: 0 }
  }

  connect () {
    this._peek = this.perViewValue > 0 && this.itemTargets.length > 0
    if (this._peek) {
      this.itemCount = this.itemTargets.length
      this.maxIndex = Math.max(0, this.itemCount - this.perViewValue)
      this.positionCount = this.maxIndex + 1
    } else {
      this.count = this.slideTargets.length
    }

    if (!this._peek && this.count === 0) return

    this._onResize = () => {
      if (this._peek) this.indexValue = Math.min(this.indexValue, this.maxIndex)
      this._applyTransform()
    }
    window.addEventListener("resize", this._onResize)

    requestAnimationFrame(() => {
      this._applyTransform()
      requestAnimationFrame(() => this._applyTransform())
    })

    const tickable = this._peek ? this.positionCount > 1 : this.count > 1
    if (tickable && this.intervalValue > 0) {
      this._timer = window.setInterval(() => this.next(), this.intervalValue)
    }
  }

  disconnect () {
    window.removeEventListener("resize", this._onResize)
    if (this._timer) window.clearInterval(this._timer)
  }

  next () {
    if (this._peek) {
      if (this.positionCount <= 1) return
      this.indexValue = (this.indexValue + 1) % this.positionCount
      this._applyTransform()
      return
    }
    if (this.count <= 1) return
    this.indexValue = (this.indexValue + 1) % this.count
    this._applyTransform()
  }

  prev () {
    if (this._peek) {
      if (this.positionCount <= 1) return
      this.indexValue = (this.indexValue - 1 + this.positionCount) % this.positionCount
      this._applyTransform()
      return
    }
    if (this.count <= 1) return
    this.indexValue = (this.indexValue - 1 + this.count) % this.count
    this._applyTransform()
  }

  goTo (event) {
    const i = parseInt(event.currentTarget.dataset.index, 10)
    if (Number.isNaN(i)) return
    if (this._peek) {
      if (i < 0 || i > this.maxIndex) return
    } else if (i < 0 || i >= this.count) {
      return
    }
    this.indexValue = i
    this._applyTransform()
  }

  _applyTransform () {
    if (!this.hasTrackTarget) return
    if (this._peek) {
      this._applyPeekTransform()
      return
    }
    if (this.count === 0) return
    const pct = (this.indexValue * 100) / this.count
    this.trackTarget.style.transform = `translateX(-${pct}%)`

    if (this.hasDotTarget) {
      this.dotTargets.forEach((dot, i) => {
        const on = i === this.indexValue
        dot.classList.toggle("is-active", on)
        dot.setAttribute("aria-selected", on ? "true" : "false")
      })
    }
  }

  _applyPeekTransform () {
    const track = this.trackTarget
    const items = this.itemTargets
    if (items.length === 0) return

    const vp = this.hasViewportTarget ? this.viewportTarget : track.parentElement
    const gap = parseFloat(window.getComputedStyle(track).gap || "0") || 0
    const per = this.perViewValue
    const vw = vp.clientWidth
    const cardW = (vw - gap * (per - 1)) / per

    items.forEach((el) => {
      el.style.flexBasis = `${cardW}px`
      el.style.flexShrink = "0"
      el.style.flexGrow = "0"
      el.style.width = `${cardW}px`
    })

    const step = items[0].offsetWidth + gap
    track.style.transform = `translateX(-${this.indexValue * step}px)`
  }
}
