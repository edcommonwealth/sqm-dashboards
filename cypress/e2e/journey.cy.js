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

describe('navigates the site', () => {
  it('displays the div containing the framework wheel', () => {
    cy.visit('/')
    cy.get('.framework-wheel-container').should('have.length', 1)
  })

  it('displays the title of the teachers and leadership accordion', () => {
    cy.visit('/')
    cy.get('[data-bs-target="#teachers-and-leadership-item"]').should('include.text', "Teachers & Leadership")
  })

  it('shows schools when a district is selected', () => {
    cy.visit('/')
    cy.get("#district-dropdown").select('Lee Public Schools')
    cy.get("#school-dropdown").select('Lee Elementary School')
    cy.get("#school-dropdown").children("option[selected='selected']").should('have.text', 'Lee Elementary School')

    cy.contains('Go').click()

    cy.url().should('include', '/districts/lee-public-schools/schools/lee-elementary-school/overview?year=2022-23')
  })


  it('displays overview content', () => {
    login("districts/lee-public-schools/schools/lee-elementary-school/overview?year=2022-23", "bGVlOmxlZSE=")
    cy.url().should('include', '/districts/lee-public-schools/schools/lee-elementary-school/overview?year=2022-23')
    const icons = ['.fa-apple-alt', '.fa-school', '.fa-users-cog', '.fa-graduation-cap', '.fa-heart']
    for (const icon of icons) {
      cy.get(icon).should('exist')
    }
  })
})

// #     district_admin_sees_overview_content

// #     click_on "Teachers & Leadership"
// #     district_admin_sees_browse_content

// #     click_on "Overview"
// #     district_admin_sees_overview_content

// #     click_on "Analyze"
// #     district_admin_sees_analyze_content

// #     go_to_different_category(different_category)
// #     district_admin_sees_category_change

// #     go_to_different_subcategory(different_subcategory)
// #     district_admin_sees_subcategory_change

// #     click_on "Browse"
// #     district_admin_sees_browse_content

// #     click_on "School Culture"
// #     expect(page).to have_text("Measures the degree to which the school environment is safe, caring, and academically-oriented. It considers factors like bullying, student-teacher relationships, and student valuing of learning.")

// #     go_to_different_school_in_same_district(school_in_same_district)
// #     district_admin_sees_schools_change

// #     go_to_different_district(different_district)
// #     district_admin_sees_district_change

// #     go_to_different_year(ay_2019_20)
// #     district_admin_sees_year_change

function login(path, credentials) {
  cy.visit(path, {
    headers: {
      authorization: `Basic ${credentials}`
    },
    failOnStatusCode: false
  })
}