# catalog-browse

## To start
Connect to the U-M Library VPN

![Screen Shot 2021-11-18 at 2 44 56 PM](https://user-images.githubusercontent.com/27687379/142486728-5fe21b80-b02c-4e89-a2ef-e74440e99bfa.png)

Copy the environment file example
```
cp -r .env-example .env
```

Get the actual values from a developer, and update the `.env` file.
```
BIBLIO_SOLR='http://biblio-server'
CATALOG_SOLR='http://catalog-solr-server'
CALLNUMBERS_CORE='callnumbers'
AUTHORS_CORE='authors'
AUTHOR_ON='true'
SUBJECT_ON='true'
```

Build the image
```
docker-compose build
```

Install the gems
```
docker-compose run --rm web bundle install
```

Install the npm packages
```
docker-compose run --rm web npm install
```

Start the app
```
docker-compose up
```

Build the styles
```
docker-compose run --rm web npm run build
```

Run the tests
```
docker-compose run web bundle exec rspec
```
In a browser go to http://localhost:4567/callnumber?query=UM1

## How to work on features
If you are working on features, set up a gate so that the feature can be turned on and off until the release.

In this project we create an environment variable for the feature. If it is true the feature is enabled. If it is false then it is turned off. 

Current Features:
* `AUTHOR_ON='true'` for enabling Browse By Author
* `SUBJECT_ON='true'` for enabling Browse By Subject
