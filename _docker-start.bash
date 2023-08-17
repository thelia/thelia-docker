#!/bin/bash
############################################################
# Help                                                     #
############################################################
Help() {
  # Display Help
  echo "This script will build and run docker containers for Thelia 2.5."
  echo
  echo "Syntax: _docker-start.bash [--xdebug|spx]"
  echo "arguments:"
  echo "--xdebug     will build php with xdebug"
  echo "--spx     will build php with spx"
  exit
}

# OPTIONS
with_xdebug=0
with_spx=0
while [ -n "$1" ]; do
  case "$1" in
  --xdebug) with_xdebug=1 ;;
  --spx) with_spx=1 ;;
  help) Help ;;
  *) echo "Option $1 not recognized" ;;
  esac
  shift
done

# CREATE ENV FILE
if ! test -f ".env"; then
  read -p "$(echo -e "\e[1;37;45m You don't have a .env file, we will create it. Please enter a template name : \e[0m")" template_name
  if [[ -z "$template_name" ]]; then
    echo -e "\e[1;37;41m Invalid template name \e[0m"
    exit 0
  fi
  template_name=${template_name//_/}
  template_name=${template_name// /_}
  template_name=${template_name//[^a-zA-Z0-9_]/}
  template_name="$(echo $template_name | tr '[A-Z]' '[a-z]')"
  cp ".env.docker" ".env"
  sed -i "s/modern/${template_name}/g" .env >/dev/null
  echo -e "\e[1;37;42m .env file created with success with template name \"${template_name}\" \e[0m"
fi

# GET ENV VARIABLES
set -o allexport
eval $(cat '.env' | sed -e '/^#/d;/^\s*$/d' -e 's/\(\w*\)[ \t]*=[ \t]*\(.*\)/\1=\2/' -e "s/=['\"]\(.*\)['\"]/=\1/g" -e "s/'/'\\\''/g" -e "s/=\(.*\)/='\1'/g")
set +o allexport

# INSTALL AND / OR START
if [ ! -f Thelia ]; then
  export WITH_XDEBUG=$with_xdebug
  export WITH_SPX=$with_spx
  # INSTALL THELIA PROJECT
  docker-compose up -d --build php-fpm
  docker-compose exec php-fpm composer --no-interaction create-project thelia/thelia-project thelia 2.5.*
  rm -Rf thelia/.docker
  mv -vn thelia/{.,}* ./
  rm -Rf thelia
  rm -f templates/frontOffice/modern/.dockerignore

  # START SERVICES
  docker-compose up -d --build webserver
  docker-compose up -d --build mariadb
  docker-compose up -d --build mailhog
  #docker-compose up -d --build node

  # COPY THEME SOURCES
  mkdir -p "templates/frontOffice/$ACTIVE_FRONT_TEMPLATE"
  if [ ! -z "$ACTIVE_FRONT_TEMPLATE" ] && [ ! -d "templates/frontOffice/$ACTIVE_FRONT_TEMPLATE" ]; then
    echo -e "\e[1;37;46m Copying template files modern to templates/frontOffice/$ACTIVE_FRONT_TEMPLATE \e[0m"
    cp -r ./templates/frontOffice/modern/* ./templates/frontOffice/"$ACTIVE_FRONT_TEMPLATE"
    echo -e 'Install thelia and init theme modern'
    chmod +x .docker/php-fpm/docker-init-modern.sh
    sh .docker/php-fpm/docker-init-modern.sh
  fi
else
  # ONLY START SERVICES
  docker-compose up -d php-fpm
  docker-compose up -d webserver
  docker-compose up -d mariadb
  docker-compose up -d mailhog
  #docker-compose up -d node
fi

# CACHE
docker-compose exec php-fpm php Thelia cache:clear
docker-compose exec php-fpm php Thelia cache:clear --env=prod
docker-compose exec php-fpm php Thelia cache:clear --env=propel
