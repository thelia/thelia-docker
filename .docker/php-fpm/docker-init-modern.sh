#!/bin/sh
set -e

echo "PHP docker-init.sh"
set -o allexport
eval $(cat '.env' | sed -e '/^#/d;/^\s*$/d' -e 's/\(\w*\)[ \t]*=[ \t]*\(.*\)/\1=\2/' -e "s/=['\"]\(.*\)['\"]/=\1/g" -e "s/'/'\\\''/g" -e "s/=\(.*\)/='\1'/g")
set +o allexport

[ -d local/session ] || mkdir -p local/session
[ -d local/media ] || mkdir -p local/media
chmod -R +w local/session && chmod -R +w local/media

docker-compose exec php-fpm composer install

DB_FILE=local/config/database.yml
if ! test -f "$DB_FILE"; then
    docker-compose exec php-fpm php Thelia thelia:install --db_host=mariadb --db_port=3306 --db_username=root --db_name="${MYSQL_DATABASE}" --db_password="${MYSQL_ROOT_PASSWORD}"
    docker-compose exec php-fpm php Thelia module:refresh
    docker-compose exec php-fpm php Thelia module:activate OpenApi
    docker-compose exec php-fpm php Thelia module:activate ChoiceFilter
    docker-compose exec php-fpm php Thelia module:activate StoreSeo
    docker-compose exec php-fpm php Thelia module:activate ShortCode
    docker-compose exec php-fpm php Thelia module:activate ShortCodeMeta
    docker-compose exec php-fpm php Thelia module:activate SmartyRedirection
    docker-compose exec php-fpm php Thelia module:deactivate HookAdminHome
    docker-compose exec php-fpm php Thelia module:deactivate HookAnalytics
    docker-compose exec php-fpm php Thelia module:deactivate HookCart
    docker-compose exec php-fpm php Thelia module:deactivate HookCustomer
    docker-compose exec php-fpm php Thelia module:deactivate HookSearch
    docker-compose exec php-fpm php Thelia module:deactivate HookLang
    docker-compose exec php-fpm php Thelia module:deactivate HookCurrency
    docker-compose exec php-fpm php Thelia module:deactivate HookNavigation
    docker-compose exec php-fpm php Thelia module:deactivate HookProductsNew
    docker-compose exec php-fpm php Thelia module:deactivate HookSocial
    docker-compose exec php-fpm php Thelia module:deactivate HookNewsletter
    docker-compose exec php-fpm php Thelia module:deactivate HookContact
    docker-compose exec php-fpm php Thelia module:deactivate HookLinks
    docker-compose exec php-fpm php Thelia module:deactivate HookProductsOffer

    docker-compose exec php-fpm php Thelia template:set frontOffice "${ACTIVE_FRONT_TEMPLATE}"
    docker-compose exec php-fpm php Thelia template:set backOffice "${ACTIVE_ADMIN_TEMPLATE}"
    docker-compose exec php-fpm php Thelia thelia:config set imagine_graphic_driver imagick
    docker-compose exec php-fpm php Thelia admin:create --login_name thelia --password thelia --last_name thelia --first_name thelia --email thelia@example.com
fi

docker-compose exec php-fpm php Thelia module:refresh
