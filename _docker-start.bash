#!/bin/bash

if ! test -f ".env"; then
  read -p "$(echo -e "\e[1;37;45m You don't have a .env file, we will create it. Please enter a template name : \e[0m")" template_name
  if [[ -z "$template_name" ]]; then
    echo -e "\e[1;37;41m Invalid template name \e[0m"
    exit 0
  fi
  # first, strip underscores
  template_name=${template_name//_/}
  # next, replace spaces with underscores
  template_name=${template_name// /_}
  # now, clean out anything that's not alphanumeric or an underscore
  template_name=${template_name//[^a-zA-Z0-9_]/}
  # finally, lowercase with TR
  template_name="$(echo $template_name | tr '[A-Z]' '[a-z]')"
  cp ".env.docker" ".env"
  sed -i "s/modern/${template_name}/g" .env >/dev/null
  echo -e "\e[1;37;42m .env file created with success with template name \"${template_name}\" \e[0m"
fi

read -p "$(echo -e "\e[1;37;45m Do you want to enable php xdebug ? [Y/n] : \e[0m")" with_xdebug
with_xdebug=${with_xdebug:-'n'}
export WITH_XDEBUG=with_xdebug
echo -e "\e[1;37;46m Starting docker \e[0m"

docker-compose up -d --build php-fpm

if [ ! -f Thelia ]
then
  docker-compose exec php-fpm composer --no-interaction create-project thelia/thelia-project thelia 2.5
fi

rm -Rf thelia/.docker
mv -vn thelia/{.,}* ./
rm -Rf thelia

set -o allexport
eval $(cat '.env' | sed -e '/^#/d;/^\s*$/d' -e 's/\(\w*\)[ \t]*=[ \t]*\(.*\)/\1=\2/' -e "s/=['\"]\(.*\)['\"]/=\1/g" -e "s/'/'\\\''/g" -e "s/=\(.*\)/='\1'/g")
set +o allexport

if [ ! -z "$ACTIVE_FRONT_TEMPLATE" ] && [ ! -d "templates/frontOffice/$ACTIVE_FRONT_TEMPLATE" ]; then
  echo -e "\e[1;37;46m Copying template files to templates/frontOffice/$ACTIVE_FRONT_TEMPLATE \e[0m"
  cp -r "templates/frontOffice/modern" "templates/frontOffice/$ACTIVE_FRONT_TEMPLATE"
else
  echo "Template files "$template_name" already exists"
fi

docker-compose up -d --build webserver
docker-compose up -d --build mariadb
docker-compose up -d --build encore

sh .docker/php-fpm/docker-init.sh

if [[ $1 = "-demo" ]]; then
  docker-compose exec php-fpm php local/setup/import.php
fi

docker-compose exec php-fpm php Thelia c:c
docker-compose exec php-fpm php Thelia c:c --env=prod
docker-compose exec php-fpm php Thelia c:c --env=propel
