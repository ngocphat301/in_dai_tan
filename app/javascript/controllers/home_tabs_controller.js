import { Controller } from "@hotwired/stimulus"

/** Tab Tin tức / Dự án trên trang chủ */
export default class extends Controller {
  static targets = ["tab", "panel"]
  static values = { active: String }

  connect() {
    const initial = this.activeValue || this.tabTargets[0]?.dataset.tabId || "news"
    this.activate(initial)
  }

  select(event) {
    const id = event.currentTarget.dataset.tabId
    if (id) this.activate(id)
  }

  activate(id) {
    this.tabTargets.forEach((t) => {
      const on = t.dataset.tabId === id
      t.setAttribute("aria-selected", on ? "true" : "false")
      t.classList.toggle("is-active", on)
      t.tabIndex = on ? 0 : -1
    })
    this.panelTargets.forEach((p) => {
      const on = p.dataset.tabId === id
      p.hidden = !on
      p.setAttribute("aria-hidden", on ? "false" : "true")
      p.classList.toggle("is-active", on)
    })
    this.activeValue = id
  }
}
