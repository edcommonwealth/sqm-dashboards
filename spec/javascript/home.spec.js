import  {initializeListenersForHomeDropdowns } from "home"

it("returns true when called", () =>{

 document.body.innerHTML =
    '<div>' +
    '  <select id="school-dropdown"></select>' +
    '  <select id="district-dropdown"></select>' +
    '</div>';
  
  expect(initializeListenersForHomeDropdowns()).toBe(true)
})
