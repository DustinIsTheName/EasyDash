APP_URL = ENV["HEROKU_ENV"] == 'production' ? 'https://app.easydash.io' : 'https://easydash-staging.herokuapp.com'
DEV_URL = 'https://localhost:3000'
CURRENT_URL = Rails.env.production? ? APP_URL : DEV_URL