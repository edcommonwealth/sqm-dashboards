import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="analyze"
export default class extends Controller {
  connect() { }
  change_category(event) {
        window.location = event.target.value
  }
}
