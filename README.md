# THELIA DOCKER STACK

A docker configuration is provided in this separate repository of Thelia. It uses docker-compose.

It requires obviously [docker](https://docker.com/) and [docker-compose](http://docs.docker.com/compose/)

## How to build / start containers
First, check the data of the .env.docker file which will serve as the basis for the installation.


Run in a terminal :
```shell 
bash _docker-start.bash
# you can pass --xdebug or/and --spx to build this extensions with PHP
```
It will ask you the theme name, you can choose what you want. 
The script will copy the source files from "modern" theme to your theme name directory.

When the script ended, you can see your website in a browser with this url :  
[http://localhost:8080](http://localhost:8080)

## How to stop containers

Run in a terminal :
```shell 
docker-compose down --remove-orphans
# OR 
docker compose down
```

## How to execute commands
All the script are launched through docker. For examples :

```shell 
docker-compose exec php-fpm php Thelia cache:clear
docker-compose exec php-fpm composer install
docker-compose exec mariadb mysql -u root -p thelia -e 'select * from thelia.product'
```


## Default datas 
```
MySQL user : thelia  
MySQL password : thelia  
MySQL database : thelia  
MySQL root user : root  
MySQL root password : root  

Admin URL : /admin
Admin user : thelia2  
Admin password : thelia2
```

## Demo datas
After 

## How to change the configuration

All the configuration can be customized for your own project in `docker-compose.yaml`. Each `Dockerfile` of containers are located in the `.docker` directory. It uses the official [php image](https://hub.docker.com/_/php/) provided by docker so you can change the php version as you want.
You can also install all the extension you want.

Each time you modify the configuration, you have to rebuild the containers :
``` 
docker-composer build --no-cache
```

And run again bash script.