# tx-valhalla-docker

With Mapzen shutting down we also lose access to some of the excellent API endpoints for routing and generating drive-time polygons. Fortunately, Mapzen's service was provided by an open-source tool that uses open data &mdash; [Valhalla](https://github.com/valhalla/valhalla).

Using Docker, it's possible to download OpenStreetMap data and use it to power a local instance of Valhalla with all of the key features of Mapzen's service on your local machine. It'll allow you to do things that would normally take expensive API queries locally, such as generating drive-time polygons:

![Isochrone example logo](/etc/isochrone-example.gif?raw=true)

The [Dockerfile](Dockerfile) in this repo will scaffold a Valhalla instance pre-loaded with the data needed to generate routing information for Texas. It can be modified using the notes in the Dockerfile to install additional states or even the whole country.

## Requirements

- [Docker](https://www.docker.com/docker-mac)

## Usage

Clone this repository to your computer, step into and build the image using Docker:

```sh
$ docker build -t valhalla .
```

The above command will download fresh street data for the whole state and it will be post-processed by Valhalla. Because of that, it's a lengthy process so don't worry if it seems to be taking forever.

Once the image is built, use the `docker run` command to start the Valhalla API server:

```sh
$ docker run -t -p 8002:8002 valhalla
```

The server will start in the foreground in your terminal and should be accessible at [localhost:8002](http://localhost:8002) (you can change that address with the `-p` flag)

That means you ought to be able to issue a query to the API for anywhere in Texas. For example, the below query ought to return walking directions from _1954 Commerce St._ to _508 Young St._:

```
http://localhost:8002/route?json={"locations":[{"lat":32.7809076,"lon":-96.7943785,"street":"1954%20Commerce Street"},{"lat":32.775946,"lon":-96.8066197,"street":"508%20Young Street"}],"costing":"auto","directions_options":{"units":"miles"}}
```

For details on the various API endpoints see the official docs on Valhalla's Github account: https://github.com/valhalla/valhalla-docs/

There's also a demo of the Isochrome service included in the [`demos/`](demos/) folder. You can also access demo on Valhalla's Github account, which can be easily modified to work with your local Valhalla instance: https://github.com/valhalla/demos
