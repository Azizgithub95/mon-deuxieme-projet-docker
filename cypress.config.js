const { defineConfig } = require('cypress')

module.exports = defineConfig({
  e2e: {
    baseUrl: 'https://www.google.com',
    specPattern: 'cypress/e2e/**/*.cy.js'
  }
})
