import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="analyze"
export default class extends Controller {
  connect() { }
  refresh(event) {
    let location = event.target.value+ "&academic_years=";
    let year_checkboxes = document.getElementsByName("year-checkbox");
    let selected_years = [];

    let ending = "";
    year_checkboxes.forEach((item)=>{
      if(item.checked) {
        selected_years.push(item.id)
      }
    })

    console.log(location)
    window.location = location + selected_years.join(",")
  }
}
