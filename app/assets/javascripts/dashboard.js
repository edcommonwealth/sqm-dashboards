document.addEventListener("DOMContentLoaded", function() {
  const selectSchoolElement = document.querySelector('#select-school');

  selectSchoolElement.addEventListener('change', (event) => {
    change_school(event);
  });

  const selectDistrictElement = document.querySelector('#select-district');

  selectDistrictElement.addEventListener('change', (event) => {
    change_district(event);
  });
});

function change_school(event) {
  const school_slug = event.target.value;

  const district_regex = /districts\/(.+)\/schools/;
  const district_slug = window.location.pathname.match(district_regex)[1];

  const year_range_regex = /year=(.+)/;
  const year_range = window.location.search.match(year_range_regex)[1];

  window.location = `/districts/${district_slug}/schools/${school_slug}/dashboard?year=${year_range}`;
};

function change_district(event) {
  const district_slug = event.target.value;

  const year_range_regex = /year=(.+)/;
  const year_range = window.location.search.match(year_range_regex)[1];

  window.location = `/districts/${district_slug}/schools/first/dashboard?year=${year_range}`;
};
