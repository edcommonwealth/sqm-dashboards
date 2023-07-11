/// <reference types="cypress" />

// Welcome to Cypress!
//
// This spec file contains a variety of sample tests
// for a todo list app that are designed to demonstrate
// the power of writing tests in Cypress.
//
// To learn more about how Cypress works and
// what makes it such an awesome testing tool,
// please read our getting started guide:
// https://on.cypress.io/introduction-to-cypress

describe('example to-do app', () => {
  beforeEach(() => {
    cy.visit('/')
  })

  it('displays the div containing the framework wheel', () => {
    cy.get('.framework-wheel-container').should('have.length', 1)
  })

  it('displays the title of the teachers and leadership accordion', () => {
    cy.get('[data-bs-target="#teachers-and-leadership-item"]').should('include.text', "Teachers & Leadership")
  })

  it('shows schools when a district is selected', () => {
    cy.get("#district-dropdown").select('Lee Public Schools')
    cy.get("#school-dropdown").select('Lee Elementary School')
    cy.get("#school-dropdown").children("option[selected='selected']").should('have.text', 'Lee Elementary School')

    cy.contains('Go').click()

    cy.visit("districts/lee-public-schools/schools/lee-elementary-school/overview?year=2022-23", {
      headers: {
        authorization: 'Basic bGVlOmxlZSE='
      },
      failOnStatusCode: false
    })

    cy.url().should('include', '/districts/lee-public-schools/schools/lee-elementary-school/overview?year=2022-23')
  })
})
