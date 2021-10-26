// Entry point for the build script in your package.json
import Rails from "@rails/ujs"
import Turbolinks from "turbolinks"
import * as ActiveStorage from "@rails/activestorage"
// import "channels"

Rails.start()
Turbolinks.start()
ActiveStorage.start()
import { initializeListenersForNavDropdowns } from "./dashboard.js"
import { initializeListenersForHomeDropdowns } from "./home.js"

document.addEventListener("turbolinks:load", () => {
  initializeListenersForNavDropdowns()
  initializeListenersForHomeDropdowns()
})
