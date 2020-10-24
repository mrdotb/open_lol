const purgecss = require('@fullhuman/postcss-purgecss')({
  content: [
    '../lib/maidolly_web/templates/**/*.html.eex',
    '../lib/maidolly_web/templates/**/*.html.leex',
  ],

  defaultExtractor: content => content.match(/[\w-/.:]+(?<!:)/g) || []
})

module.exports = {
  plugins: [
    require('tailwindcss'),
    require('autoprefixer'),
    ...process.env.NODE_ENV === 'production'
    ? [purgecss]
    : []
  ]
}
