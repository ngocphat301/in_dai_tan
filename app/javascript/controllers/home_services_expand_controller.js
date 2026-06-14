import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["grid", "moreBtn"]
  static values = { limit: { type: Number, default: 4 } }

  connect () {
    if (!this.hasGridTarget) return

    this._mobileQuery = window.matchMedia("(max-width: 767px)")
    this._onMobileChange = () => this._evaluateCollapse()
    this._mobileQuery.addEventListener("change", this._onMobileChange)
    this._evaluateCollapse()
  }

  disconnect () {
    if (this._mobileQuery) this._mobileQuery.removeEventListener("change", this._onMobileChange)
  }

  _evaluateCollapse () {
    const total = this.gridTarget.children.length
    const isMobile = this._mobileQuery.matches

    if (isMobile && total > this.limitValue) {
      this.element.classList.add("is-collapsed")
      if (this.hasMoreBtnTarget) this.moreBtnTarget.hidden = false
    } else {
      this.element.classList.remove("is-collapsed")
      if (this.hasMoreBtnTarget) this.moreBtnTarget.hidden = true
    }
  }

  expand () {
    this.element.classList.remove("is-collapsed")
    if (this.hasMoreBtnTarget) {
      this.moreBtnTarget.hidden = true
      this.moreBtnTarget.setAttribute("aria-expanded", "true")
    }
  }
}
