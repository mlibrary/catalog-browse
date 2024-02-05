# Overview
Monthly dependency update to help maintain Catalog Browse.

## NPM
These dependencies have been updated to their latest versions:
- `cssnano`
- `postcss`
- `postcss-cli`
- `postcss-import`

## Workflows
These actions have been updated to their latest versions:
- `actions/checkout`
- `aquasecurity/trivy-action`
- `mlibrary/deploy-to-kubernetes`
- `mlibrary/platform-engineering-workflows/.github/workflows/build-production.yml`
- `mlibrary/platform-engineering-workflows/.github/workflows/build-unstable.yml`
- `ruby/setup-ruby`
- `xom9ikk/dotenv`

## Testing
- Install the updated packages (`docker-compose run --rm web npm install`).
- Make a CSS change, and build the styles (`docker-compose run --rm web npm run build`).
- Start [the site](http://localhost:4567/callnumber?query=UM1) to see if your change was made, and everything still works (`docker-compose up`).
- Make sure the PR is consistent in these browsers:
  - [x] Chrome
  - [x] Firefox
  - [x] Safari
  - [x] Edge
