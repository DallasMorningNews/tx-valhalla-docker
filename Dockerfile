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
# http://download.geofabrik.de/ For example, to load neighboring states:
#
# RUN curl http://download.geofabrik.de/north-america/us/new-mexico-latest.osm.pbf \
#   --silent \
#   --fail \
#   --remote-name
# RUN curl http://download.geofabrik.de/north-america/us/oklahoma-latest.osm.pbf \
#   --silent \
#   --fail \
#   --remote-name
# RUN curl http://download.geofabrik.de/north-america/us/louisiana-latest.osm.pbf \
#   --silent \
#   --fail \
#   --remote-name

# Use valhalla's config-building script to create a valhalla.json config file
WORKDIR /valhalla_data
RUN valhalla_build_config \
  --mjolnir-tile-dir ${PWD}/tiles \
  --mjolnir-tile-extract ${PWD}/tiles.tar \
  --mjolnir-timezone ${PWD}/tiles/timezones.sqlite \
  --mjolnir-admin ${PWD}/tiles/admins.sqlite \
  > valhalla.json

# Build the routing tiles
RUN mkdir tiles
RUN valhalla_build_tiles -c valhalla.json extracts/*.osm.pbf

# .tar up the files for running the server
RUN find tiles | sort -n | tar cf tiles.tar --no-recursion -T -

# Start the Valhalla API server and make it available on 8002
CMD valhalla_route_service valhalla.json 1
EXPOSE 8002
