import 'bootstrap';

export function initializeListenersForHomeDropdowns() {
  const districtDropdown = document.querySelector("#district-dropdown");
  if (districtDropdown) {
    const schoolDropdown = document.querySelector("#school-dropdown");
    districtDropdown.addEventListener("change", (event) => {
      const districtId = Number(event.target.value);
      const schoolsInDistrict = window.schools.filter(
        (school) => school.district_id === districtId
      );

      schoolDropdown.replaceChildren(
        ...schoolsInDistrict.map((school) => {
          return createOptionForSelect(school.name, school.url, false);
        })
      );

      let optionElem = createOptionForSelect("Select a school", schoolDropdown.firstChild.value, true)
      schoolDropdown.insertBefore(optionElem, schoolDropdown.firstChild);

      schoolDropdown.disabled = false;
    });

    schoolDropdown.addEventListener("change", (event) => {
      const goButton = document.querySelector('button[data-id="go-to-school"]');
      goButton.disabled = false;
    });

    document
      .querySelector('button[data-id="go-to-school"]')
      .addEventListener("click", (event) => {
        const selectedSchoolURL = schoolDropdown.value;
        window.location = selectedSchoolURL;
      });
  }
}

function createOptionForSelect(name, value, selected) {
  const optionElem = document.createElement("option");
  optionElem.setAttribute("value", value);

  if (selected === true) {
    optionElem.setAttribute("selected", "selected");
  }
  const schoolNameNode = document.createTextNode(name);
  optionElem.appendChild(schoolNameNode);
  return optionElem;
}
