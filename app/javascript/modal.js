import { Modal } from "bootstrap";

export function showEmptyDatasetModal() {
  const modal = document.querySelector('.modal');
  if(modal){
    new Modal(modal).show();
  }
}
