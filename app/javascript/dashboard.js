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
