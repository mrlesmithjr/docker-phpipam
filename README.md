docker-phpipam
--------------

Builds docker image to run [phpIPAM] container with persistent data.  

Requirements
------------

A working Docker setup.  

## How-To
Spin up phpIPAM environment using the included `docker-compose.yml`.  

```
version: '2'
services:
  db:
    image: mysql:5.7
    volumes:
      - "./.data/db:/var/lib/mysql"
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: phpipam
      MYSQL_DATABASE: phpipam
      MYSQL_USER: phpipam
      MYSQL_PASSWORD: phpipam

  phpipam:
    depends_on:
      - db
    image: mrlesmithjr/docker-phpipam:latest
    links:
      - db
    ports:
      - "8000:80"
    restart: always
    environment:
      MYSQL_DB_HOSTNAME: db
      MYSQL_DB_USERNAME: phpipam
      MYSQL_DB_PASSWORD: phpipam
      MYSQL_DB_NAME: phpipam
      MYSQL_DB_PORT: 3306
```
Spin up the environment with `docker-compose up -d`

Once complete if you run `docker ps` you should see similar to below:

```
CONTAINER ID        IMAGE                               COMMAND                  CREATED             STATUS              PORTS                           NAMES
2b74b05e3362        mrlesmithjr/docker-phpipam:latest   "apache2ctl -D FOREGR"   10 seconds ago      Up 9 seconds        443/tcp, 0.0.0.0:8000->80/tcp   dockerphpipam_phpipam_1
a132a22c6a49        mysql:5.7                           "docker-entrypoint.sh"   11 seconds ago      Up 10 seconds       3306/tcp                        dockerphpipam_db_1
```
One thing that is left which still needs work is the phpIPAM DB schema but we
can handle that with the below:
```
docker exec -it dockerphpipam_phpipam_1 bash -c "mysql -u root -p -h db phpipam < /var/www/html/db/SCHEMA.sql"
```
When prompted for password enter `phpipam` and the DB will be populated.  
Now open up your browser of choice and connect to http://127.0.0.1:8000 and
login with `admin/ipamadmin`. And you will be prompted to change the default
password.

And you are now good to go to begin using [phpIPAM].

[phpIPAM]: <http://phpipam.net>
