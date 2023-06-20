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
      this.selected_items("race").join(",") +
      "&genders=" +
      this.selected_items("gender").join(",") +
      "&incomes=" +
      this.selected_items("income").join(",") +
      "&grades=" +
      this.selected_items("grade").join(",");

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

    const groups = new Map([
      ['gender', 'students-by-gender'],
      ['grade', 'students-by-grade'],
      ['income', 'students-by-income'],
      ['race', 'students-by-race']
    ])

    if (target.name === 'slice' || target.name === 'group') {
      if (selected_slice === 'students-and-teachers') {
        return 'students-and-teachers';
      }
      return groups.get(this.selected_group());
    }

    return window.graph;

  }

  selected_items(type) {
    let checkboxes = [...document.getElementsByName(`${type}-checkbox`)]
    let items = checkboxes
      .filter((item) => {
        return item.checked;
      })
      .map((item) => {
        return item.id.replace(`${type}-`, '');
      });

    return items;
  }
}
