import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["media", "aboveDesc", "scroll", "moreBtn"]
  static values = { expanded: { type: Boolean, default: false } }

  connect () {
    if (!this.hasScrollTarget) return
    this._ro = new ResizeObserver(() => this.measure())
    if (this.hasMediaTarget) this._ro.observe(this.mediaTarget)
    if (this.hasAboveDescTarget) this._ro.observe(this.aboveDescTarget)
    this._onResize = () => this.measure()
    window.addEventListener("resize", this._onResize)
    this.measure()
  }

  disconnect () {
    this._ro?.disconnect()
    window.removeEventListener("resize", this._onResize)
  }

  measure () {
    if (!this.hasScrollTarget || !this.hasMediaTarget) return
    if (this.expandedValue) {
      this._applyExpanded()
      return
    }

    const mh = this.mediaTarget.getBoundingClientRect().height
    const ah = this.hasAboveDescTarget ? this.aboveDescTarget.getBoundingClientRect().height : 0
    const gap = 16
    const max = Math.max(100, Math.floor(mh - ah - gap))

    this.scrollTarget.style.maxHeight = `${max}px`
    this.scrollTarget.style.overflow = "hidden"

    requestAnimationFrame(() => {
      const sh = this.scrollTarget.scrollHeight
      if (sh > max + 2) {
        this.scrollTarget.classList.add("is-clamped")
        if (this.hasMoreBtnTarget) {
          this.moreBtnTarget.hidden = false
          this.moreBtnTarget.textContent = "Xem thêm"
        }
      } else {
        this.scrollTarget.classList.remove("is-clamped")
        this.scrollTarget.style.maxHeight = ""
        this.scrollTarget.style.overflow = ""
        if (this.hasMoreBtnTarget) this.moreBtnTarget.hidden = true
      }
    })
  }

  toggle () {
    this.expandedValue = !this.expandedValue
    if (this.expandedValue) {
      this._applyExpanded()
    } else {
      this.measure()
    }
  }

  _applyExpanded () {
    if (!this.hasScrollTarget) return
    this.scrollTarget.style.maxHeight = "none"
    this.scrollTarget.style.overflow = "visible"
    this.scrollTarget.classList.remove("is-clamped")
    if (this.hasMoreBtnTarget) {
      this.moreBtnTarget.hidden = false
      this.moreBtnTarget.textContent = "Thu gọn"
    }
  }
}
