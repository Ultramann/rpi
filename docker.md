# Docker Notes

## NPM

### Start node package with `docker run`

``` sh
touch package.json
docker run -v $PWD/package.json:/app/package.json -w /app --rm -it node:13-alpine /bin/sh
```

In the shell in the docker container run.
``` sh
yarn init (-y)
yarn add (-D) <package-1>
...
yarn add (-D) <package-n>
```

This will do a full install of the packages to the `node-modules` directory and update the `package.json` in the run; but since we're mounting the `package.json` file, it's updates are being written to the host; and since the we're running in a container with `--rm` the `node-modules` directory will be removed with you exit the container.

### Build docker image with new `package.json`

Now that you have a package.json with all right versions you can make a development container with it via a simple docker file.
``` dockerfile
FROM node:13-alpine

WORKDIR /app

COPY package.json /app
RUN npm install

COPY . .
EXPOSE 8080
 
CMD [ "yarn", "start" ]
```

and build the image with:
``` sh
docker build -t node_proj_dev
```

Or you could be fancier and setup a `docker-compose.yml`.
``` yml
version: '3'

services:
  project: 
    build: ./
```

and build the image with:
``` sh
docker-compose build
```

### Update node package with `docker run`

Need to use the current state of node-modules, to do this need to run in the current development container. With that realization, the process looks almost exactly like the [first step][start-node package-with-docker-run].

``` sh
docker run -v $PWD/package.json:/app/package.json -w /app --rm -it node_proj_dev /bin/sh
```

In the shell in the docker container run.
``` sh
yarn add (-D) <package>
yarn upgrade
```
