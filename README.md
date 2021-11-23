# catalog-browse

## To start
Connect to the U-M Library VPN

![Screen Shot 2021-11-18 at 2 44 56 PM](https://user-images.githubusercontent.com/27687379/142486728-5fe21b80-b02c-4e89-a2ef-e74440e99bfa.png)

Copy the environment file example
```
cp -r .env-example .env
```

Get the actual `CATALOG_SOLR` value from a developer, and update the `.env` file.
```
CATALOG_SOLR='http://catalog-solr-server'
```

Build the image
```
docker-compose build
```
Install the gems
```
docker-compose run --rm web bundle install
```
Start the app
```
docker-compose up
```
In a browser go to http://localhost:4567/callnumber?query=U-M
