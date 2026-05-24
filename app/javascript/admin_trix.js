// Mở rộng Trix cho form bài viết admin: H1/H2/H3, link rel, bảng, alt ảnh, toolbar sticky (CSS).
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

function isAdminTrixEditor (editor) {
  return editor.matches(ADMIN_TRIX_SELECTOR) || editor.closest(".admin-trix-wrap")
}

function createTextButton (label, title, onClick) {
  const button = document.createElement("button")
  button.type = "button"
  button.className = "trix-button trix-button--text"
  button.title = title
  button.tabIndex = -1
  button.textContent = label
  button.addEventListener("click", (e) => {
    e.preventDefault()
    onClick()
  })
  return button
}

function insertLink (editor, rel) {
  const url = window.prompt("URL liên kết")
  if (!url) return
  const text = window.prompt("Nhãn hiển thị (để trống = URL)", url) || url
  const esc = (s) => s.replace(/&/g, "&amp;").replace(/"/g, "&quot;").replace(/</g, "&lt;")
  const relAttr = rel ? ` rel="${esc(rel)}"` : ""
  editor.insertHTML(
    `<a href="${esc(url)}" target="_blank"${relAttr}>${esc(text)}</a>`
  )
}

function insertTable (editor) {
  editor.insertHTML(
    "<table><tbody><tr><td>&nbsp;</td><td>&nbsp;</td></tr><tr><td>&nbsp;</td><td>&nbsp;</td></tr></tbody></table>"
  )
}

function createHeadingButton (level, attribute, title) {
  const button = document.createElement("button")
  button.type = "button"
  button.className = `trix-button trix-button--text trix-button--heading-${level}`
  button.dataset.trixAttribute = attribute
  button.title = title
  button.tabIndex = -1
  button.textContent = `H${level}`
  return button
}

function addHeadingButtons (toolbar) {
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

function addAdminToolbarExtras (toolbar, editor) {
  if (toolbar.dataset.adminExtrasReady === "true") return
  toolbar.dataset.adminExtrasReady = "true"

  const group =
    toolbar.querySelector(".trix-button-group--text-tools") ||
    toolbar.querySelector(".trix-button-group")
  if (!group) return

  group.appendChild(
    createTextButton("Link↓", "Liên kết nofollow", () =>
      insertLink(editor, "noopener noreferrer nofollow")
    )
  )
  group.appendChild(
    createTextButton("Link↑", "Liên kết dofollow", () => insertLink(editor, "noopener"))
  )
  group.appendChild(
    createTextButton("Bảng", "Chèn bảng 2×2", () => insertTable(editor))
  )
}

function setupAdminTrixEditor (editor) {
  if (!isAdminTrixEditor(editor)) return
  const toolbar = editor.toolbarElement
  if (!toolbar) return
  addHeadingButtons(toolbar)
  addAdminToolbarExtras(toolbar, editor)
}

document.addEventListener("trix-initialize", (event) => {
  setupAdminTrixEditor(event.target)
})

document.addEventListener("trix-attachment-add", (event) => {
  const editor = event.target
  if (!isAdminTrixEditor(editor)) return
  const attachment = event.attachment
  if (!attachment.file) return
  window.setTimeout(() => {
    const current = attachment.getAttributes().alt || ""
    const alt = window.prompt("Alt text cho ảnh (SEO)", current)
    if (alt != null && alt !== "") attachment.setAttributes({ ...attachment.getAttributes(), alt })
  }, 0)
})

document.addEventListener("turbo:load", () => {
  document.querySelectorAll(ADMIN_TRIX_SELECTOR).forEach((editor) => {
    setupAdminTrixEditor(editor)
  })
})
