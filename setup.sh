cd src && docker run -v $(pwd):/srv/pim -w /srv/pim --rm akeneo/pim-php-dev:4.0 \
                      php -d memory_limit=4G /usr/local/bin/composer create-project --prefer-dist \
                      akeneo/pim-community-standard /srv/pim "4.0.*@stable"
