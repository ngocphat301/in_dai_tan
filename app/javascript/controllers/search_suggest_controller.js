import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "panel"]
  static values = {
    url: String,
    minLength: { type: Number, default: 2 },
    kind: { type: String, default: "product" },
    postScope: { type: String, default: "" }
  }

  connect() {
    this._timer = null
    this._onDocClick = (event) => {
      if (!this.element.contains(event.target)) this.hide()
    }
    document.addEventListener("click", this._onDocClick)
  }

  disconnect() {
    document.removeEventListener("click", this._onDocClick)
    clearTimeout(this._timer)
  }

  onInput() {
    clearTimeout(this._timer)
    this._timer = setTimeout(() => this.fetchSuggest(), 200)
  }

  onFocus() {
    this.fetchSuggest()
  }

  hide() {
    if (!this.hasPanelTarget) return
    this.panelTarget.hidden = true
    this.panelTarget.innerHTML = ""
  }

  async fetchSuggest() {
    if (!this.hasInputTarget || !this.hasPanelTarget) return

    const q = this.inputTarget.value.trim()
    if (q.length < this.minLengthValue) {
      this.hide()
      return
    }

    try {
      const kind = this.kindValue || "product"
      let url = `${this.urlValue}?q=${encodeURIComponent(q)}&kind=${encodeURIComponent(kind)}`
      if (kind === "post") {
        const ps = (this.postScopeValue || "all").trim() || "all"
        url += `&post_scope=${encodeURIComponent(ps)}`
      }
      const res = await fetch(url, {
        headers: { Accept: "application/json" }
      })
      if (!res.ok) return
      const data = await res.json()
      this.render(data.suggestions || [])
    } catch (_e) {
      this.hide()
    }
  }

  render(items) {
    if (!items.length) {
      this.hide()
      return
    }

    const ul = document.createElement("ul")
    ul.className = "dm-search-suggest__list"

    for (const item of items) {
      const li = document.createElement("li")
      const a = document.createElement("a")
      a.href = item.url
      a.className = "dm-search-suggest__link"
      a.textContent = item.text
      a.addEventListener("mousedown", (e) => {
        e.preventDefault()
        window.location.href = item.url
      })
      li.appendChild(a)
      ul.appendChild(li)
    }

    this.panelTarget.replaceChildren(ul)
    this.panelTarget.hidden = false
  }
}
