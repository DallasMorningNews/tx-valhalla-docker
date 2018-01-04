FROM ubuntu:trusty

# Add utilities required for installation from a PPA
RUN apt-get update
RUN apt-get install -y apt-utils software-properties-common python-software-properties

# Install Valhalla from their PPA repo
RUN add-apt-repository -y ppa:valhalla-core/valhalla
RUN apt-get update
RUN apt-get install -y valhalla-bin curl

# Download a PDF OpenStreetMap regional extract as our source data
WORKDIR /valhalla_data/extracts
RUN curl http://download.geofabrik.de/north-america/us/texas-latest.osm.pbf \
  --silent \
  --fail \
  --remote-name

# NOTE: You can add additional region downloads here. Just repeat the above curl
# command and save them to the extracts/ folder. Extracts are availalbe at:
# http://download.geofabrik.de/

# Use valhalla's config-building script to create a valhalla.json config file
WORKDIR /valhalla_data
RUN valhalla_build_config \
  --mjolnir-tile-dir ${PWD}/tiles \
  --mjolnir-tile-extract ${PWD}/tiles.tar \
  --mjolnir-timezone ${PWD}/tiles/timezones.sqlite \
  --mjolnir-admin ${PWD}/tiles/admins.sqlite \
  > valhalla.json

# Build the routing tiles
# TODO: run valhalla_build_admins?
RUN mkdir tiles
RUN valhalla_build_tiles -c valhalla.json extracts/*.osm.pbf

# .tar up the files for running the server
RUN find tiles | sort -n | tar cf tiles.tar --no-recursion -T -

#grab the demos repo and open up the point and click routing sample
# git clone --depth=1 --recurse-submodules --single-branch --branch=gh-pages https://github.com/valhalla/demos.git
# firefox demos/routing/index-internal.html &
#NOTE: set the environment pulldown to 'localhost' to point it at your own server

# Start the Valhalla API server and make it available on 8002
CMD valhalla_route_service valhalla.json 1
EXPOSE 8002
