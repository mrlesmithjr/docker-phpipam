docker-phpipam
--------------

Builds [Docker] image to run [phpIPAM] container with persistent data.  

Requirements
------------

A working [Docker] setup.  

## How-To
Spin up [phpIPAM] environment using the included `docker-compose.yml`.  

```
version: '2'
services:
  db:
    image: mrlesmithjr/mysql:latest
    volumes:
      - "db:/var/lib/mysql"
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: phpipam
      MYSQL_DATABASE: phpipam
      MYSQL_USER: phpipam
      MYSQL_PASSWORD: phpipam

  web:
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

volumes:
  db:
```

Spin up the environment with `docker-compose up -d`

Once complete if you run `docker ps` you should see similar to below:

```
CONTAINER ID        IMAGE                               COMMAND                  CREATED             STATUS              PORTS                           NAMES
2446630340d9        mrlesmithjr/docker-phpipam:latest   "apache2ctl -D FOREGR"   43 minutes ago      Up 43 minutes       443/tcp, 0.0.0.0:8000->80/tcp   dockerphpipam_web_1
1082d5b687b0        mrlesmithjr/mysql:latest            "docker-entrypoint.sh"   3 hours ago         Up 43 minutes       3306/tcp                        dockerphpipam_db_1
```
One thing that is left which still needs work is the [phpIPAM] DB schema but we
can handle that with the below:
```
docker exec -it dockerphpipam_web_1 bash -c "mysql -u phpipam -p -h db phpipam < /var/www/html/db/SCHEMA.sql"
```
When prompted for password enter `phpipam` and the DB will be populated.  
Now open up your browser of choice and connect to http://127.0.0.1:8000 and
login with `admin/ipamadmin`. And you will be prompted to change the default
password.

And you are now good to go to begin using [phpIPAM].

Notes
-----
I was not able to get cron jobs to run as desired
however you can execute the following manually for example or schedule them to run from your [Docker] host.

`Discover hosts`
```
docker exec -it dockerphpipam_web_1 /usr/bin/php /var/www/html/functions/scripts/discoveryCheck.php
```
`Resolve IP addresses`
```
docker exec -it dockerphpipam_web_1 /usr/bin/php /var/www/html/functions/scripts/resolveIPaddresses.php
```
`Ping check`
```
docker exec -it dockerphpipam_web_1 /usr/bin/php /var/www/html/functions/scripts/pingCheck.php
```
If you spin this up using `docker-compose` then you will have a persistent data
volume that gets created to ensure that your data remains. The data volume is
created as a name so it is easier to find and will always be mapped to the same
volume. By default this will be named as the project name_db. So for example:
`dockerphpipam_db`.
You can view/inspect this volume by:
```
docker volume inspect dockerphpipam_db
```
```
[
    {
        "Name": "dockerphpipam_db",
        "Driver": "local",
        "Mountpoint": "/var/lib/docker/volumes/dockerphpipam_db/_data",
        "Labels": null,
        "Scope": "local"
    }
]
```
And if you were to have spun this up previously when the data volume was `./data`
then you can easily migrate your existing data by doing the following (using above
example) in the project folder:
```
sudo su
sudo cp -r ./data/. /var/lib/docker/volumes/dockerphpipam_db/_data
```

[phpIPAM]: <http://phpipam.net>
[Docker]: <http://docker.com>
