import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="analyze"
export default class extends Controller {
  connect() { }
  refresh(event) {
    let base_url = event.target.value;

    let url =
      base_url +
      "&academic_years=" +
      this.selected_years().join(",") +
      "&graph=" +
      this.selected_graph() +
      "&races=" +
      this.selected_races().join(",");

    this.go_to(url);
  }


  go_to(location) {
    window.location = location;
  }

  selected_years() {
    let year_checkboxes = [...document.getElementsByName("year-checkbox")];
    let years = year_checkboxes
      .filter((item) => {
        return item.checked;
      })
      .map((item) => {
        return item.id;
      });

    return years;
  }

  selected_graph() {
    let graphs = [...document.getElementsByName("graph")];
    let selected_graph = graphs
      .filter((item) => {
        return item.checked;
      })
      .map((item) => {
        return item.id;
      });

    return selected_graph[0];
  }

  selected_races() {
    let race_checkboxes = [...document.getElementsByName("race-checkbox")]
    let races = race_checkboxes
      .filter((item) => {
        return item.checked;
      })
      .map((item) => {
        return item.id;
      });

    return races;
  }
}
