# Repo Searcher

This Rails project searches and lists github repositories by consuming [the github API](https://api.github.com/)

## Requirements & Setup

To be able to setup and run this project you'll need to have [docker-compose](https://docs.docker.com/compose/install/) installed (If you're using linux, you should also perform [the linux post-install steps](https://docs.docker.com/engine/install/linux-postinstall/)).

To setup the project, run the following command in the root of the repository to build the docker container: `docker-compose up --build`. This step is also necessary after making changes to the Gemfile or Compose files

## Running the project

To start the server in the background:
```console
$ docker-compose up -d
```

To open the container's console (only works after starting the server):
```
$ docker-compose exec web bash
```