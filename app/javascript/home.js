export function initializeListenersForHomeDropdowns() {
  document.addEventListener("turbolinks:load", () => {
    const districtDropdown = document.querySelector("#district-dropdown");
    if (districtDropdown) {
      districtDropdown.addEventListener("change", (event) => {
        const schoolDropdown = document.querySelector("#school-dropdown");

        const districtId = Number(event.target.value);

        const schoolsInDistrict = window.schools.filter(
          (school) => school.district_id === districtId
        );

        schoolsInDistrict.forEach((school) => {
          const optionElem = document.createElement("option");
          optionElem.setAttribute("value", school.url);
          const schoolNameNode = document.createTextNode(school.name);
          optionElem.appendChild(schoolNameNode);
          schoolDropdown.appendChild(optionElem);
        });
      });

      document
        .querySelector('button[data-id="go-to-school"]')
        .addEventListener("click", (event) => {
          const selectedSchoolURL =
            document.querySelector("#school-dropdown").value;
          window.location = selectedSchoolURL;
        });
    }
  });
  return true;
}
