import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "display", "editButton", "deleteButton"]
  static values = { commentId: Number }

    openEdit(event) {
    event.preventDefault()
    this.displayTarget.classList.add("hidden")
    this.formTarget.classList.remove("hidden")
    this.editButtonTarget.classList.add("hidden")
    this.deleteButtonTarget.classList.add("hidden")
  }

  closeEdit() {
    this.formTarget.classList.add("hidden")
    this.displayTarget.classList.remove("hidden")
    this.editButtonTarget.classList.remove("hidden")
    this.deleteButtonTarget.classList.remove("hidden")
  }

  handleSubmit(event) {
    const form = event.target
    if (form.checkValidity()) {
      this.closeEdit()
    }
  }
}

