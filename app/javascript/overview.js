import { Popover } from "bootstrap";

export function initializeListenersForNavDropdowns() {
  const schoolDropdown = document.querySelector("#select-school");
  if (schoolDropdown) {
    document
      .querySelector("#select-school")
      .addEventListener("change", (event) => {
        window.location = event.target.value;
      });

    document
      .querySelector("#select-district")
      .addEventListener("change", (event) => {
        window.location = event.target.value;
      });
  }
}

export function initializePopovers() {
  document
    .querySelectorAll('[data-bs-toggle="popover"]')
    .forEach(popoverElement => {
      new Popover(popoverElement, { trigger: 'hover focus' })
    })
}
