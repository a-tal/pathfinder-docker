# pathfinder-docker

This repo will build pathfinder (https://github.com/exodus4d/pathfinder) as a docker container.

Batteries included.

## Building

`docker build -t pathfinder .`

## Optional build-args

* `MYSQL_DUMP_HOST`: a URL that's hosting mysql-latest.tar.bz2, default is `https://www.fuzzwork.co.uk/dump`
* `GIT_BRANCH`: what branch to clone and build from https://github.com/exodus4d/pathfinder, default is `master`

## Running

```
docker run -d --name=pathfinder \
-e DB_USERNAME=pathfinder \
-e DB_PASSWORD=somesqlpassword \
-e ADMIN_EMAIL=pathfinder@your.host \
-e SERVER_NAME=your.host \
-p 8080:80 \
pathfinder
```

On first launch, go to `http://your_docker_host:8080/setup` run the db setup and fix any table errors if you run into any (I was, but the web ui could fix them...)
