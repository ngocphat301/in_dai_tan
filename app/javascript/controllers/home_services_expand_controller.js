import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["grid", "moreBtn"]
  static values = { limit: { type: Number, default: 4 } }

  connect () {
    if (!this.hasGridTarget) return
    const total = this.gridTarget.children.length
    if (total <= this.limitValue) {
      if (this.hasMoreBtnTarget) this.moreBtnTarget.hidden = true
      return
    }
    this.element.classList.add("is-collapsed")
  }

  expand () {
    this.element.classList.remove("is-collapsed")
    if (this.hasMoreBtnTarget) {
      this.moreBtnTarget.hidden = true
      this.moreBtnTarget.setAttribute("aria-expanded", "true")
    }
  }
}
