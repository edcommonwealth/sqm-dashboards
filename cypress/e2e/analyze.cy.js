describe('navigates the analyze page', () => {
  it('it displays counts of students and teacher in the hovers', () => {

    login("/districts/lowell/schools/abraham-lincoln-elementary-school/analyze?year=2022-23&category=1&academic_years=2022-23", "bGVlOmxlZSE=")
  })
})

function login(path, credentials) {
  cy.visit(path, {
    headers: {
      authorization: `Basic ${credentials}`
    },
    failOnStatusCode: false
  })
}
