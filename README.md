# Docker Image for WP Browser Codeception Testing

This is a standalone docker container for running Codeception tests on a WordPress site.

Note that this is designed to run in the WordPress root folder, not inside a plugin or theme folder. This is best used for running tests on a custom site.

## Usage

Configure [WP Browser](https://github.com/lucatume/wp-browser/) to run tests on your site.

Create a docker-compose.yml in your project root based on the one below.

Run the default command on the wpbrowser container

```shell
docker-compose --file docker-compose.yml run --rm wpbrowser
```

## Sample docker-compose

```yaml
version: '3'

services:
  db:
    image: 'mysql:5.7'
    command: --max_allowed_packet=32505856
    networks:
      db:
        aliases:
          - sql
    environment:
      - MYSQL_DATABASE=wordpress
      - MYSQL_PASSWORD=wordpress
      - MYSQL_ROOT_PASSWORD=root
      - MYSQL_USER=wordpress
    ports:
      - 33060:3306
    restart: always
    volumes:
      - 'db_data:/var/lib/mysql'

  wpbrowser:
    image: 'ryanshoover/wp-browser:latest'
    command: 'codecept run acceptance -vvv --debug'
    networks:
      db:
    depends_on:
      - db
    environment:
      - DB_HOST=sql
      - DB_NAME=wordpress
      - DB_PASSWORD=wordpress
      - DB_USER=wordpress
      - SQL_DUMP_URL=tests/_data/mdb_dump.sql
    volumes:
      - './wp-content:/var/www/html/wp-content'
      - './tests:/var/www/html/tests'
      - './codeception.yml:/var/www/html/codeception.yml'

volumes:
  db_data:
networks: db:
```

## Opinionated Configuration

This repo has an opinion on how Codeception should be set up. Specifically, it includes a `codeception.dist.yml` file that is based on WP Browser defaults. You can override these settings by placing a `codeception.yml` file in your project root folder.

The container that is created will have a working instance of WordPress inside it. The instance has a URL of `http://localhost` and expects a database prefix of `wp_`.
