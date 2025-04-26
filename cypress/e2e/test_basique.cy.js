describe('Test de base', () => {
  it('Visite Google et vérifie le titre', () => {
    cy.visit('https://www.google.com')
    cy.title().should('include', 'Google')
  })
})
