import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["textarea", "suggestion"]
  static values = { users: Array }

  connect() {
    this.fetchUsers()
    this.suggestionList = null
    this.justSelected = false

    const textarea = this.textarea
    if (textarea) {
      this.createBackdrop(textarea)
      this.syncHighlight(textarea)
    }
  }

  get textarea() {
    return this.hasTextareaTarget ? this.textareaTarget : this.element.querySelector("textarea")
  }

  async fetchUsers() {
    try {
      const response = await fetch("/users/list.json")
      if (response.ok) {
        this.usersValue = await response.json()
      }
    } catch (error) {
      console.error("Failed to fetch users:", error)
    }
  }

  handleInput(event) {
    if (this.justSelected) {
      this.justSelected = false
      return
    }

    const textarea = event.target
    this.syncHighlight(textarea)

    const text = textarea.value
    const cursorPos = textarea.selectionStart

    const textBeforeCursor = text.substring(0, cursorPos)
    const lastAt = textBeforeCursor.lastIndexOf("@")

    if (lastAt === -1 || textBeforeCursor.substring(lastAt).includes(" ")) {
      this.closeSuggestions()
      return
    }

    const mentionStart = lastAt + 1
    const searchTerm = textBeforeCursor.substring(mentionStart).toLowerCase()

    if (searchTerm.length === 0) {
      this.closeSuggestions()
      return
    }

    this.showSuggestions(searchTerm, textarea, lastAt)
  }

  showSuggestions(searchTerm, textarea, atPosition) {
    const matches = this.usersValue.filter((user) =>
      user.username.toLowerCase().includes(searchTerm)
    )

    if (matches.length === 0) {
      this.closeSuggestions()
      return
    }

    if (!this.suggestionList) {
      this.suggestionList = this.createSuggestionsList(textarea)
    }

    this.suggestionList.innerHTML = matches
      .map(
        (user) =>
          `<div class="suggestion-item px-3 py-2 hover:bg-blue-100 cursor-pointer" data-username="${user.username}">
            ${user.username}
          </div>`
      )
      .join("")

    Array.from(this.suggestionList.querySelectorAll(".suggestion-item")).forEach(
      (item) => {
        item.addEventListener("click", () => {
          this.selectMention(item.dataset.username, textarea, atPosition)
        })
      }
    )

    const coordinates = this.getCaretCoordinates(textarea, atPosition)
    this.suggestionList.style.top = `${textarea.offsetTop + coordinates.top - textarea.scrollTop + coordinates.height}px`
    this.suggestionList.style.left = `${textarea.offsetLeft + coordinates.left - textarea.scrollLeft}px`

    this.suggestionList.style.display = "block"
  }

  getCaretCoordinates(textarea, position) {
    const properties = [
      "direction",
      "boxSizing",
      "width",
      "height",
      "overflowX",
      "overflowY",
      "borderTopWidth",
      "borderRightWidth",
      "borderBottomWidth",
      "borderLeftWidth",
      "borderStyle",
      "paddingTop",
      "paddingRight",
      "paddingBottom",
      "paddingLeft",
      "fontStyle",
      "fontVariant",
      "fontWeight",
      "fontStretch",
      "fontSize",
      "fontSizeAdjust",
      "lineHeight",
      "fontFamily",
      "textAlign",
      "textTransform",
      "textIndent",
      "textDecoration",
      "letterSpacing",
      "wordSpacing",
      "tabSize",
      "MozTabSize"
    ]

    const div = document.createElement("div")
    div.id = "input-textarea-caret-position-mirror-div"
    document.body.appendChild(div)

    const style = div.style
    const computed = window.getComputedStyle(textarea)

    style.position = "absolute"
    style.visibility = "hidden"

    properties.forEach((prop) => {
      style[prop] = computed[prop]
    })

    style.overflowY = "hidden"

    div.textContent = textarea.value.substring(0, position)

    const span = document.createElement("span")
    span.textContent = textarea.value.substring(position, position + 1) || "."
    div.appendChild(span)

    const coordinates = {
      top: span.offsetTop + parseInt(computed.borderTopWidth || 0),
      left: span.offsetLeft + parseInt(computed.borderLeftWidth || 0),
      height: span.offsetHeight
    }

    document.body.removeChild(div)

    return coordinates
  }

  createBackdrop(textarea) {
    if (this.backdrop) return this.backdrop

    if (textarea.parentNode && textarea.parentNode.classList.contains("mentions-wrapper")) {
      const backdrop = textarea.parentNode.querySelector(".mentions-backdrop")
      if (backdrop) {
        this.backdrop = backdrop
        return backdrop
      }
    }

    const computed = window.getComputedStyle(textarea)

    let originalColor = computed.color
    if (!originalColor || originalColor === "transparent" || originalColor === "rgba(0, 0, 0, 0)") {
      let parent = textarea.parentElement
      while (parent) {
        const parentColor = window.getComputedStyle(parent).color
        if (parentColor && parentColor !== "transparent" && parentColor !== "rgba(0, 0, 0, 0)") {
          originalColor = parentColor
          break
        }
        parent = parent.parentElement
      }
      if (!originalColor || originalColor === "transparent" || originalColor === "rgba(0, 0, 0, 0)") {
        originalColor = "#1e293b"
      }
    }

    const wrapper = document.createElement("div")
    wrapper.className = "mentions-wrapper"
    wrapper.style.position = "relative"
    wrapper.style.display = computed.display
    wrapper.style.width = "100%"

    textarea.parentNode.insertBefore(wrapper, textarea)
    wrapper.appendChild(textarea)

    const backdrop = document.createElement("div")
    backdrop.className = "mentions-backdrop"
    
    wrapper.insertBefore(backdrop, textarea)
    this.backdrop = backdrop

    const properties = [
      "fontFamily", "fontSize", "fontWeight", "fontStyle", "lineHeight",
      "paddingTop", "paddingRight", "paddingBottom", "paddingLeft",
      "borderTopWidth", "borderRightWidth", "borderBottomWidth", "borderLeftWidth",
      "borderStyle", "boxSizing", "width", "height", "textTransform", "textAlign",
      "letterSpacing", "wordSpacing", "whiteSpace", "wordBreak"
    ]

    properties.forEach((prop) => {
      backdrop.style[prop] = computed[prop]
    })

    backdrop.style.position = "absolute"
    backdrop.style.top = "0"
    backdrop.style.left = "0"
    backdrop.style.backgroundColor = "transparent"
    backdrop.style.color = originalColor
    backdrop.style.overflowY = "auto"
    backdrop.style.overflowX = "hidden"
    backdrop.style.pointerEvents = "none"
    backdrop.style.borderColor = "transparent"

    textarea.style.color = "transparent"
    textarea.style.caretColor = originalColor || "black"
    textarea.style.background = "transparent"
    textarea.style.position = "relative"
    textarea.style.zIndex = "2"

    textarea.addEventListener("scroll", () => {
      backdrop.scrollTop = textarea.scrollTop
      backdrop.scrollLeft = textarea.scrollLeft
    })

    if (typeof ResizeObserver !== "undefined") {
      const resizeObserver = new ResizeObserver(() => {
        const comp = window.getComputedStyle(textarea)
        backdrop.style.width = comp.width
        backdrop.style.height = comp.height
      })
      resizeObserver.observe(textarea)
    }

    return backdrop
  }

  syncHighlight(textarea) {
    if (!this.backdrop) return

    let text = textarea.value

    // Escape HTML
    text = text
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")

    // Highlight matches of @username or typed @
    text = text.replace(/@[\w.-]*/g, '<mark class="bg-transparent text-blue-700 rounded">$&</mark>')

    if (text.endsWith("\n")) {
      text += " "
    }

    this.backdrop.innerHTML = text
    this.backdrop.scrollTop = textarea.scrollTop
    this.backdrop.scrollLeft = textarea.scrollLeft
  }

  createSuggestionsList(textarea) {
    let list = document.getElementById("mention-suggestions")
    if (!list) {
      list = document.createElement("div")
      list.id = "mention-suggestions"
      list.className =
        "absolute bg-white border border-slate-300 rounded-lg shadow-lg max-h-48 overflow-y-auto z-10 min-w-48"
      textarea.parentNode.style.position = "relative"
      textarea.parentNode.appendChild(list)
    }
    return list
  }

  selectMention(username, textarea, atPosition) {
    const text = textarea.value
    const beforeAt = text.substring(0, atPosition)
    const afterCursor = text.substring(textarea.selectionStart)

    const mentionText = `@${username} `
    textarea.value = beforeAt + mentionText + afterCursor

    textarea.selectionStart = atPosition + mentionText.length
    textarea.selectionEnd = atPosition + mentionText.length

    this.closeSuggestions()
    textarea.focus()

    this.justSelected = true
    this.syncHighlight(textarea)

    textarea.dispatchEvent(new Event("input", { bubbles: true }))
  }

  closeSuggestions() {
    if (this.suggestionList) {
      this.suggestionList.style.display = "none"
    }
  }

  disconnect() {
    this.closeSuggestions()
  }
}

