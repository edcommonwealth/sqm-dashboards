import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="analyze"
export default class extends Controller {
  connect() { }
  refresh(event) {
    let base_url = event.target.value;
    let target = event.target;
    console.log(this.selected_slice(target))
    console.log(target.name)

    let url =
      base_url +
      "&academic_years=" +
      this.selected_years().join(",") +
      "&source=" +
      this.selected_source(target) +
      "&slice=" +
      this.selected_slice(target) +
      "&group=" +
      this.selected_group() +
      "&graph=" +
      this.selected_graph(target) +
      "&races=" +
      this.selected_races().join(",") +
      "&genders=" +
      this.selected_genders().join(",") +
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

  selected_source(target) {
    if (target.name === 'source') {
      return target.id;
    }
    if (target.name === 'slice' || target.name === 'group') {
      return 'survey-data-only';
    }

    return window.source;
  }

  selected_slice(target) {
    if (target.name === 'source' && target.id === 'all-data') {
      return 'all-data';
    }
    if (target.name === 'source' && target.id === 'survey-data-only') {
      return 'students-and-teachers';
    }

    if (target.name === 'group') {
      return 'students-by-group';
    }

    if (target.name === 'source' || target.name === 'slice') {
      let slices = [...document.getElementsByName("slice")];
      let selected_slice = slices
        .filter((item) => {
          return item.id != "all-data";
        })
        .filter((item) => {
          return item.checked;
        })
        .map((item) => {
          return item.id;
        });

      return selected_slice[0];
    }

    return window.slice;
  }

  selected_graph(target) {
    if (target.name === 'source' && target.id === 'all-data') {
      return 'all-data'
    }
    if (target.name === 'source' && target.id === 'survey-data-only') {
      return 'students-and-teachers'
    }

    let graphs = [...document.getElementsByName("slice")];
    let selected_slice = graphs
      .filter((item) => {
        return item.checked;
      })
      .map((item) => {
        return item.id;
      })[0];

    if (target.name === 'slice' || target.name === 'group') {
      if (selected_slice === 'students-and-teachers') {
        return 'students-and-teachers';
      } else if (this.selected_group() === 'race') {
        return 'students-by-race';
      } else if (this.selected_group() === 'gender') {
        return 'students-by-gender';
      } else if (this.selected_group() === 'grade') {
        return 'students-by-grade';
      }
    }

    return window.graph;

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

  selected_genders() {
    let gender_checkboxes = [...document.getElementsByName("gender-checkbox")]
    let genders = gender_checkboxes
      .filter((item) => {
        return item.checked;
      })
      .map((item) => {
        return item.id.replace('gender-', '');
      });

    return genders;
  }
}
