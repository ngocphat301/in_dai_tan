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
const TABLE_HTML =
  "<table><tbody><tr><th>&nbsp;</th><th>&nbsp;</th></tr><tr><td>&nbsp;</td><td>&nbsp;</td></tr></tbody></table>"

function isAdminTrixEditor (editor) {
  return editor.matches(ADMIN_TRIX_SELECTOR) || editor.closest(".admin-trix-wrap")
}

function trixEditor (element) {
  return element.editor
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

function escapeHtml (value) {
  return value
    .replace(/&/g, "&amp;")
    .replace(/"/g, "&quot;")
    .replace(/</g, "&lt;")
}

function selectedPlainText (element) {
  const editor = trixEditor(element)
  if (!editor) return ""
  const range = editor.getSelectedRange()
  if (!range || range[0] === range[1]) return ""
  return editor.getDocument().toString().slice(range[0], range[1]).trim()
}

function insertLink (element, rel) {
  const editor = trixEditor(element)
  if (!editor) return

  const url = window.prompt("URL liên kết")
  if (!url) return

  const selected = selectedPlainText(element)
  const defaultLabel = selected || url
  const textInput = window.prompt("Nhãn hiển thị (để trống = URL)", defaultLabel)
  if (textInput === null) return
  const text = (textInput.trim() || url).trim()
  const relAttr = rel ? ` rel="${escapeHtml(rel)}"` : ""
  editor.insertHTML(
    `<a href="${escapeHtml(url)}" target="_blank"${relAttr}>${escapeHtml(text)}</a>`
  )
}

function insertTable (element) {
  const editor = trixEditor(element)
  if (!editor || !Trix?.Attachment) return

  const attachment = new Trix.Attachment({
    content: TABLE_HTML,
    contentType: "text/html"
  })
  editor.insertAttachment(attachment)
}

function promptImageAlt (attachment) {
  const current = attachment.getAttributes().alt || ""
  const alt = window.prompt("Alt text cho ảnh (SEO)", current)
  if (alt === null) return
  attachment.setAttributes({ ...attachment.getAttributes(), alt: alt.trim() })
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

function addAdminToolbarExtras (toolbar, editorElement) {
  if (toolbar.dataset.adminExtrasReady === "true") return
  toolbar.dataset.adminExtrasReady = "true"

  const group =
    toolbar.querySelector(".trix-button-group--text-tools") ||
    toolbar.querySelector(".trix-button-group")
  if (!group) return

  group.appendChild(
    createTextButton("LK↓", "Liên kết: noopener noreferrer nofollow", () =>
      insertLink(editorElement, "noopener noreferrer nofollow")
    )
  )
  group.appendChild(
    createTextButton("LK↑", "Liên kết: noopener dofollow", () =>
      insertLink(editorElement, "noopener")
    )
  )
  group.appendChild(
    createTextButton("Bảng", "Chèn bảng 2×2", () => insertTable(editorElement))
  )
  group.appendChild(
    createTextButton("Alt ảnh", "Chỉnh alt ảnh đang chọn (bấm vào ảnh trước)", () =>
      promptAltForSelectedImage(editorElement)
    )
  )
}

function promptAltForSelectedImage (element) {
  const editor = trixEditor(element)
  const attachment = editor?.composition?.editingAttachment
  if (!attachment?.isPreviewable?.()) {
    window.alert("Hãy bấm vào ảnh trong bài trước, rồi bấm nút Alt ảnh.")
    return
  }
  promptImageAlt(attachment)
}

function setupAdminTrixEditor (editorElement) {
  if (!isAdminTrixEditor(editorElement)) return
  const toolbar = editorElement.toolbarElement
  if (!toolbar) return
  addHeadingButtons(toolbar)
  addAdminToolbarExtras(toolbar, editorElement)
}

document.addEventListener("trix-initialize", (event) => {
  setupAdminTrixEditor(event.target)
})

document.addEventListener("trix-attachment-add", (event) => {
  const editorElement = event.target
  if (!isAdminTrixEditor(editorElement)) return
  const attachment = event.attachment
  if (!attachment.file) return
  window.setTimeout(() => promptImageAlt(attachment), 0)
})

document.addEventListener("turbo:load", () => {
  document.querySelectorAll(ADMIN_TRIX_SELECTOR).forEach((editorElement) => {
    setupAdminTrixEditor(editorElement)
  })
})
