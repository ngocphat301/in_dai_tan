import { Controller } from "@hotwired/stimulus"

// Popup form báo giá (<dialog>) + Select2 trong modal.
export default class extends Controller {
  static targets = [ "dialog" ]
  static values = { openOnLoad: Boolean }

  connect () {
    this.dialogTarget.addEventListener("close", () => this._destroySelect2())
    if (this.openOnLoadValue) {
      requestAnimationFrame(() => this.open())
    }
  }

  open (event) {
    event?.preventDefault()
    const dlg = this.dialogTarget
    const from = event?.currentTarget?.dataset?.returnTo || "home"
    const ret = document.getElementById("quote-return-to-field")
    if (ret) ret.value = from

    if (dlg.showModal) dlg.showModal()
    else dlg.setAttribute("open", "")

    const selEarly = dlg.querySelector("select.select2-quote-category")
    const embeddedPrefill = selEarly?.dataset?.prefillCategoryId
    const triggerCat = event?.currentTarget?.dataset?.productCategoryId
    const categoryId = triggerCat || embeddedPrefill || ""
    const blogPostId = event?.currentTarget?.dataset?.blogPostId
    const blogField = document.getElementById("quote-blog-post-id-field")
    if (blogField && blogPostId) blogField.value = blogPostId

    requestAnimationFrame(() => {
      this._initSelect2()
      if (!categoryId) return
      requestAnimationFrame(() => {
        const sel = dlg.querySelector("select.select2-quote-category")
        if (!sel) return
        const $ = window.jQuery
        if ($?.fn?.select2 && $(sel).data("select2")) {
          $(sel).val(String(categoryId)).trigger("change")
        } else {
          sel.value = String(categoryId)
        }
      })
    })
  }

  close (event) {
    event?.preventDefault()
    this._destroySelect2()
    const dlg = this.dialogTarget
    if (dlg.close) dlg.close()
    else dlg.removeAttribute("open")
  }

  backdropClose (event) {
    if (event.target === this.dialogTarget) this.close(event)
  }

  _initSelect2 () {
    const $ = window.jQuery
    const dlg = this.dialogTarget
    const el = dlg?.querySelector?.("select.select2-quote-category")
    if (!$?.fn?.select2 || !el) return
    const $el = $(el)
    if ($el.data("select2")) return
    $el.select2({
      width: "100%",
      placeholder: "Chọn danh mục sản phẩm…",
      allowClear: true,
      dropdownParent: $(dlg)
    })
    // Bài dịch vụ: nếu vẫn chưa chọn, khi mở dropdown gán danh mục gắn bài (data-prefill-category-id).
    $el.on("select2:open", () => {
      const blogId = document.getElementById("quote-blog-post-id-field")?.value
      if (!blogId) return
      const pre = el.dataset.prefillCategoryId
      if (!pre) return
      const cur = $el.val()
      if (cur != null && String(cur) !== "") return
      $el.val(String(pre)).trigger("change")
    })
  }

  _destroySelect2 () {
    const $ = window.jQuery
    const el = this.dialogTarget?.querySelector?.("select.select2-quote-category")
    if (!$?.fn?.select2 || !el) return
    const $el = $(el)
    if ($el.data("select2")) $el.select2("destroy")
  }
}
