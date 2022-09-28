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
      "&group=" +
      this.selected_group() +
      "&slice=" +
      this.selected_slice() +
      "&graph=" +
      this.selected_graph() +
      "&races=" +
      this.selected_races().join(",") +
      "&grades=" +
      this.selected_grades().join(",");

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

  selected_group() {
    let groups = [...document.getElementsByName("group-option")];
    let selected_group = groups
      .filter((item) => {
        return item.selected;
      })
      .map((item) => {
        return item.id;
      });

    return selected_group[0];
  }

  selected_slice() {
    let slices = [...document.getElementsByName("slice")];
    let selected_slice = slices
      .filter((item) => {
        return item.checked;
      })
      .map((item) => {
        return item.id;
      });

    return selected_slice[0];
  }

  selected_graph() {
    let graphs = [...document.getElementsByName("slice")];
    let selected_graph = graphs
      .filter((item) => {
        return item.checked;
      })
      .map((item) => {
        return item.id;
      })[0];
    if (selected_graph === 'students-and-teachers') {
      return selected_graph;
    }

    if (this.selected_group() === 'race') {
      return 'students-by-race'
    } else {
      return 'students-by-grade'
    }
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

  selected_grades() {
    let grade_checkboxes = [...document.getElementsByName("grade-checkbox")]
    let grades = grade_checkboxes
      .filter((item) => {
        return item.checked;
      })
      .map((item) => {
        return item.id.replace('grade-', '');
      });

    return grades;
  }
}
