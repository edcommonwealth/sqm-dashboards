// Entry point for the build script in your package.json
import Rails from "@rails/ujs";
import * as ActiveStorage from "@rails/activestorage";

Rails.start();
ActiveStorage.start();

import {
  initializeListenersForNavDropdowns,
  initializePopovers,
} from "./overview";
import { showEmptyDatasetModal } from "./modal";

document.addEventListener("turbo:load", () => {
  initializeListenersForNavDropdowns();
  initializePopovers();
  showEmptyDatasetModal();
});
import "@hotwired/turbo-rails";
import "./controllers";
