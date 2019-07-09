#!/bin/bash

# Ensure mysql is loaded
dockerize -wait tcp://$DB_HOST:3306 -timeout 1m

# Ensure Apache is running
service apache2 start

# Link codeception config if not yet linked
if [ ! -e codeception.dist.yml ]; then
	ln -s /var/www/config/codeception.dist.yml /var/www/html/codeception.dist.yml
fi

# Download WordPress
wp core download \
	--path=/var/www/html \
	--quiet \
	--allow-root

# Config WordPress
wp config create \
	--path=/var/www/html \
	--dbname="$DB_NAME" \
	--dbuser="$DB_USER" \
	--dbpass="$DB_PASSWORD" \
	--dbhost="$DB_HOST" \
	--dbprefix="$WP_TABLE_PREFIX" \
	--skip-check \
	--quiet \
	--allow-root

# Install WP if not yet installed
if ! $( wp core is-installed --allow-root ); then
	wp core install \
		--path=/var/www/html \
		--url=$WP_URL \
		--title='Test' \
		--admin_user=$ADMIN_USERNAME \
		--admin_password=$ADMIN_PASSWORD \
		--admin_email=$ADMIN_EMAIL \
		--allow-root
fi


# import our db dump
wp db import \
	/var/www/html/tests/mdb_dump.sql \
	--allow-root

# Add our testing user as it got erased form the db import
wp user create $ADMIN_USERNAME $ADMIN_EMAIL \
		--role='administrator' \
		--user_pass=$ADMIN_PASSWORD \
		--allow-root

# Run the passed command
exec "$@"
