function initDmNav() {
  document.querySelectorAll(".dm-nav__trigger").forEach((btn) => {
    if (btn.dataset.dmNavBound) return
    btn.dataset.dmNavBound = "1"
    btn.addEventListener("click", (e) => {
      if (window.matchMedia("(min-width: 961px)").matches) return
      e.preventDefault()
      e.stopPropagation()
      const li = btn.closest(".dm-nav__item")
      const open = !li.classList.contains("dm-nav__item--open")
      document.querySelectorAll(".dm-nav__item--open").forEach((o) => {
        if (o !== li) {
          o.classList.remove("dm-nav__item--open")
          const b = o.querySelector(".dm-nav__trigger")
          if (b) b.setAttribute("aria-expanded", "false")
        }
      })
      li.classList.toggle("dm-nav__item--open", open)
      btn.setAttribute("aria-expanded", open ? "true" : "false")
    })
  })

  document.querySelectorAll(".dm-menu-toggle").forEach((toggle) => {
    if (toggle.dataset.dmMenuBound) return
    toggle.dataset.dmMenuBound = "1"
    const nav = document.querySelector(".dm-nav")
    toggle.addEventListener("change", () => {
      if (!nav) return
      nav.classList.toggle("dm-nav--open", toggle.checked)
      document.body.classList.toggle("dm-menu-open", toggle.checked)
      if (!toggle.checked) {
        document.querySelectorAll(".dm-nav__item--open").forEach((o) => {
          o.classList.remove("dm-nav__item--open")
          const b = o.querySelector(".dm-nav__trigger")
          if (b) b.setAttribute("aria-expanded", "false")
        })
      }
    })
  })
}

document.addEventListener("turbo:load", initDmNav)
document.addEventListener("DOMContentLoaded", initDmNav)

document.addEventListener("turbo:before-visit", () => {
  const toggle = document.getElementById("dm-menu-toggle")
  if (toggle) toggle.checked = false
  document.body.classList.remove("dm-menu-open")
  document.querySelector(".dm-nav")?.classList.remove("dm-nav--open")
})

if (!window.__dmNavOutsideClose) {
  window.__dmNavOutsideClose = true
  document.addEventListener("click", (e) => {
    if (window.matchMedia("(min-width: 961px)").matches) return
    if (e.target.closest(".dm-nav__item--mega, .dm-nav__item--dropdown, .dm-menu-burger, .dm-menu-toggle")) return
    document.querySelectorAll(".dm-nav__item--open").forEach((o) => {
      o.classList.remove("dm-nav__item--open")
      const b = o.querySelector(".dm-nav__trigger")
      if (b) b.setAttribute("aria-expanded", "false")
    })
  })
}
