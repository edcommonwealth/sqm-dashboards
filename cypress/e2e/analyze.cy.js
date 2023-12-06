describe('navigates the analyze page', () => {
  it('it displays counts of students and teacher in the hovers', () => {
    // login("/districts/lee-public-schools/schools/lee-elementary-school/analyze?year=2022-23&academic_years=2022-23", "bGVlOmxlZSE=")
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
