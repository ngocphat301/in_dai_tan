import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { endsAt: String }

  connect () {
    if (!this.endsAtValue) return
    this._tick()
    this._timer = setInterval(() => this._tick(), 1000)
  }

  disconnect () {
    if (this._timer) clearInterval(this._timer)
  }

  _tick () {
    const end = Date.parse(this.endsAtValue)
    if (!Number.isFinite(end)) return
    const ms = end - Date.now()
    if (ms <= 0) {
      this.element.textContent = "00:00:00"
      if (this._timer) clearInterval(this._timer)
      return
    }
    const totalSec = Math.floor(ms / 1000)
    const h = Math.floor(totalSec / 3600)
    const m = Math.floor((totalSec % 3600) / 60)
    const s = totalSec % 60
    const pad = (n) => String(n).padStart(2, "0")
    this.element.textContent = `${pad(h)}:${pad(m)}:${pad(s)}`
  }
}
