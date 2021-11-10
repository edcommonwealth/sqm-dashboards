import { showEmptyDatasetModal } from "modal";

describe("Empty data set modal", () => {
  describe("When a modal element exists on the page", () => {
    beforeEach(() => {
      document.body.innerHTML = `<html><body>
        <div class="modal" tabindex="-1">
          <div class="modal-dialog">
            <div class="modal-content">
              <div class="modal-header">
                <h5 class="modal-title">Modal title</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
              </div>
              <div class="modal-body">
                <p>Modal body text goes here.</p>
              </div>
              <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                <button type="button" class="btn btn-primary">Save changes</button>
              </div>
            </div>
          </div>
        </div>
        </body> </html> `;
    });

    it("Adds a class to make the modal visible", () => {
      showEmptyDatasetModal();
      const modal = document.querySelector(".modal");
      expect(modal.classList.contains('show')).toBe(true);
    });
  });

  describe("When a modal doesn't exist on the page", () => {
    beforeEach(() => {
      document.body.innerHTML = `
        <html>
        <body></body>
        </html>
        `
    })

    it("ignores the content", () =>{
      showEmptyDatasetModal();
      const modal = document.querySelector(".modal");
      expect(modal).toBe(null);
    })
  })
});
