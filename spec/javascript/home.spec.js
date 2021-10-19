import { initializeListenersForHomeDropdowns } from "home";

describe("School selection and go button", () => {
  let changeDistrict, changeSchool, clickGo;

  beforeEach(() => {
    window.schools = [
      {
        district_id: 1,
        url: "/school1url",
        name: "school 1 name",
      },
      {
        district_id: 2,
        url: "/school2url",
        name: "school 2 name",
      },
    ];

    document.body.innerHTML = `
      <div>
        <select id="school-dropdown" data-id="school-dropdown" disabled></select>
        <select id="district-dropdown" data-id="district-dropdown">
          <option value="1">District 1</option>
          <option value="2">District 2</option>
        </select>
        <button data-id="go-to-school" disabled></button>
      </div>`;

    const districtDropdown = document.getElementById("district-dropdown");
    changeDistrict = (districtName) => {
      districtDropdown.value = Array.from(districtDropdown.children).find(
        (element) => element.innerHTML === districtName
      ).value;

      const event = new Event("change");
      districtDropdown.dispatchEvent(event);
    };

    changeSchool = (schoolName) => {
      const schoolDropdown = document.getElementById("school-dropdown");
      schoolDropdown.value = Array.from(schoolDropdown.children).find(
        (element) => element.innerHTML === schoolName
      ).value;
      const event = new Event("change");
      schoolDropdown.dispatchEvent(event);
    };

    clickGo = () => {
      const goButton = document.querySelector('button[data-id="go-to-school"]');
      const clickEvent = new Event("click");
      goButton.dispatchEvent(clickEvent);
    };

    initializeListenersForHomeDropdowns();
  });

  it("populates school dropdown only with schools from the selected district and the prompt", () => {
    const schoolDropdown = document.getElementById("school-dropdown");

    changeDistrict("District 1");
    expect(schoolDropdown.firstChild.innerHTML).toBe("Select a school");
    expect(schoolDropdown.childElementCount).toBe(2);

    changeDistrict("District 2");
    expect(schoolDropdown.childElementCount).toBe(2);
    expect(Array.from(schoolDropdown.options).map((o) => o.text)).toContain(
      "school 2 name"
    );
  });

  it("Clicking the go button redirects to the school url", () => {
    delete window.location;
    window.location = "";

    changeDistrict("District 1");
    changeSchool("school 1 name");
    clickGo();
    expect(window.location).toBe("/school1url");
  });

  it("enables School dropdown once a district is selected", () => {
    const schoolDropdown = document.getElementById("school-dropdown");
    changeDistrict("District 1");
    expect(schoolDropdown.disabled).toBe(false);
  });

  it("enables Go button once a school is selected", () => {
    changeDistrict("District 1");
    changeSchool("school 1 name");
    const goButton = document.querySelector('button[data-id="go-to-school"]');
    expect(goButton.disabled).toBe(false);
  });
});
