import { Controller } from "@hotwired/stimulus";
import debounce from "debounce";

// Connects to data-controller="analyze"
export default class extends Controller {
  static targets = ["category", "subcategory"]

  initialize() {
    this.submit = debounce(this.submit.bind(this), 300)
  }

  connect() {
    const collection = document.getElementsByClassName("popover");

    for (let i = 0; i < collection.length; i++) {
      collection[i].parentNode.removeChild(collection[i]);
    }
  }

  submit() {
    console.log("Submitting form");

    this.element.requestSubmit();
  }
}
