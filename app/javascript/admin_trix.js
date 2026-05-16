// Mở rộng Trix cho form bài viết admin: nút H1/H2/H3 tạo thẻ HTML thật (<h1>, <h2>, <h3>),
// không phải chỉ đổi font hay in đậm (<strong>).
const { Trix } = window
if (Trix) {
  Object.assign(Trix.config.blockAttributes, {
    heading1: {
      tagName: "h1",
      terminal: true,
      breakOnReturn: true,
      group: false
    },
    heading2: {
      tagName: "h2",
      terminal: true,
      breakOnReturn: true,
      group: false
    },
    heading3: {
      tagName: "h3",
      terminal: true,
      breakOnReturn: true,
      group: false
    }
  })
}

const ADMIN_TRIX_SELECTOR = ".admin-trix-wrap trix-editor, trix-editor.admin-trix"

function isAdminTrixEditor(editor) {
  return editor.matches(ADMIN_TRIX_SELECTOR) || editor.closest(".admin-trix-wrap")
}

function createHeadingButton(level, attribute, title) {
  const button = document.createElement("button")
  button.type = "button"
  button.className = `trix-button trix-button--text trix-button--heading-${level}`
  button.dataset.trixAttribute = attribute
  button.title = title
  button.tabIndex = -1
  button.textContent = `H${level}`
  return button
}

function addHeadingButtons(toolbar) {
  const iconHeading = toolbar.querySelector(".trix-button--icon-heading-1")
  if (!iconHeading || iconHeading.dataset.adminHeadingsReady === "true") return

  const group = iconHeading.parentElement
  iconHeading.dataset.adminHeadingsReady = "true"
  iconHeading.hidden = true
  iconHeading.setAttribute("aria-hidden", "true")

  const h1 = createHeadingButton(1, "heading1", "Tiêu đề 1 (H1)")
  const h2 = createHeadingButton(2, "heading2", "Tiêu đề 2 (H2)")
  const h3 = createHeadingButton(3, "heading3", "Tiêu đề 3 (H3)")

  group.insertBefore(h1, iconHeading)
  group.insertBefore(h2, h1.nextSibling)
  group.insertBefore(h3, h2.nextSibling)
}

document.addEventListener("trix-initialize", (event) => {
  const editor = event.target
  if (!isAdminTrixEditor(editor)) return

  addHeadingButtons(editor.toolbarElement)
})

document.addEventListener("turbo:load", () => {
  document.querySelectorAll(ADMIN_TRIX_SELECTOR).forEach((editor) => {
    if (editor.toolbarElement) addHeadingButtons(editor.toolbarElement)
  })
})
