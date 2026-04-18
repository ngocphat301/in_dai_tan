import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["kind", "coverBlock", "galleryBlock"]

  connect () {
    this._sync()
  }

  kindChanged () {
    this._sync()
  }

  _sync () {
    const isGallery = this.kindTarget.value === "gallery"
    this.coverBlockTarget.classList.toggle("is-hidden", isGallery)
    this.galleryBlockTarget.classList.toggle("is-hidden", !isGallery)
    this.coverBlockTarget.querySelectorAll("input[type='file']").forEach((el) => {
      el.disabled = isGallery
      if (isGallery) el.value = ""
    })
    this.galleryBlockTarget.querySelectorAll("input[type='file']").forEach((el) => {
      el.disabled = !isGallery
      if (!isGallery) el.value = ""
    })
  }
}
