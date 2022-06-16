import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="analyze"
export default class extends Controller {
  connect() {}
  refresh(event) {
    let location = event.target.value;
    let year_checkboxes = [...document.getElementsByName("year-checkbox")];

    let selected_years = year_checkboxes
      .filter((item) => {
        return item.checked;
      })
      .map((item) => {
        return item.id;
      });
    window.location = location + "&academic_years=" + selected_years.join(",");
  }
}
