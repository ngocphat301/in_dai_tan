import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["hero", "thumb"]
  static values = { itemsJson: String }

  connect () {
    let items = []
    try {
      items = JSON.parse(this.itemsJsonValue || "[]")
    } catch (_e) {
      items = []
    }
    this.items = items
    this.index = 0
    this.render()
  }

  pick (event) {
    const i = parseInt(event.currentTarget.dataset.index, 10)
    if (!Number.isFinite(i)) return
    this.index = i
    this.render()
  }

  mainPrev () {
    this._step(-1)
  }

  mainNext () {
    this._step(1)
  }

  _step (delta) {
    if (!this.items.length) return
    this.index = (this.index + delta + this.items.length) % this.items.length
    this.render()
  }

  render () {
    if (!this.hasHeroTarget || !this.items.length) return
    const cur = this.items[this.index]
    this.heroTarget.src = cur.url
    this.heroTarget.alt = cur.alt
    this.thumbTargets.forEach((btn, i) => {
      btn.classList.toggle("is-active", i === this.index)
    })
    const thumb = this.thumbTargets[this.index]
    if (thumb) {
      thumb.scrollIntoView({ block: "nearest", inline: "center", behavior: "smooth" })
    }
  }
}
