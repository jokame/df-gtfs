DROP SCHEMA IF EXISTS gtfs CASCADE;
CREATE SCHEMA gtfs;

DROP DOMAIN IF EXISTS wgs84_lat CASCADE;
CREATE DOMAIN gtfs.wgs84_lat AS DOUBLE PRECISION CHECK(VALUE >= -90 AND VALUE <= 90);

DROP DOMAIN IF EXISTS wgs84_lon CASCADE;
CREATE DOMAIN gtfs.wgs84_lon AS DOUBLE PRECISION CHECK(VALUE >= -180 AND VALUE <= 180);

DROP DOMAIN IF EXISTS gtfstime CASCADE;
CREATE DOMAIN gtfs.gtfstime AS text CHECK(VALUE ~ '^[0-9]?[0-9]:[0-5][0-9]:[0-5][0-9]$');

DROP TABLE IF EXISTS gtfs.agency CASCADE;

CREATE TABLE gtfs.agency
(
  agency_id         text UNIQUE NULL,
  agency_name       text NOT NULL,
  agency_url        text NOT NULL,
  agency_timezone   text NOT NULL,
  agency_lang       text NULL,
  agency_phone      text NULL
);

DROP TABLE IF EXISTS gtfs.stops CASCADE;

CREATE TABLE gtfs.stops
(
  stop_id           text PRIMARY KEY,
  stop_code         text UNIQUE NULL,
  stop_name         text NOT NULL,
  stop_desc         text NULL,
  stop_lat          wgs84_lat NOT NULL,
  stop_lon          wgs84_lon NOT NULL,
  zone_id           text NULL,
  stop_url          text NULL,
  location_type     boolean NULL,
  parent_station    text NULL,
  wheelchair_boarding text NULL,
  stop_direction  text NULL
);

DROP TABLE IF EXISTS gtfs.routes CASCADE;

CREATE TABLE gtfs.routes
(
  route_id          text PRIMARY KEY,
  agency_id         text NULL REFERENCES agency(agency_id) ON DELETE CASCADE,
  route_short_name  text NOT NULL,
  route_long_name   text NOT NULL,
  route_desc        text NULL,
  route_type        integer NOT NULL,
  route_url         text NULL,
  route_color       text NULL,
  route_text_color  text NULL,
  route_bikes_allowed text NULL
);

DROP TABLE IF EXISTS gtfs.calendar CASCADE;

CREATE TABLE gtfs.calendar
(
  service_id        text PRIMARY KEY,
  monday            boolean NOT NULL,
  tuesday           boolean NOT NULL,
  wednesday         boolean NOT NULL,
  thursday          boolean NOT NULL,
  friday            boolean NOT NULL,
  saturday          boolean NOT NULL,
  sunday            boolean NOT NULL,
  start_date        numeric(8) NOT NULL,
  end_date          numeric(8) NOT NULL
);

DROP TABLE IF EXISTS gtfs.shapes CASCADE;

CREATE TABLE gtfs.shapes
(
  shape_id          text PRIMARY KEY,
  shape_pt_lat      wgs84_lat NOT NULL,
  shape_pt_lon      wgs84_lon NOT NULL,
  shape_pt_sequence integer NOT NULL,
  shape_dist_traveled double precision NULL
);

DROP TABLE IF EXISTS gtfs.trips CASCADE;

CREATE TABLE gtfs.trips
(
  route_id          text NOT NULL REFERENCES routes ON DELETE CASCADE,
  service_id        text NOT NULL REFERENCES calendar,
  trip_id           text NOT NULL PRIMARY KEY,
  trip_headsign     text NULL,
  trip_short_name   text NULL,
  direction_id      boolean NULL,
  block_id          text NULL,
  shape_id          text NULL REFERENCES shapes,
  route_short_name  text NULL,
  wheelchair_accessible text NULL,
  trip_bikes_allowed text NULL
);

DROP TABLE IF EXISTS gtfs.stop_times CASCADE;

CREATE TABLE gtfs.stop_times
(
  trip_id           text NOT NULL REFERENCES trips ON DELETE CASCADE,
  arrival_time      interval NOT NULL,
  departure_time    interval NOT NULL,
  stop_id           text NOT NULL REFERENCES stops ON DELETE CASCADE,
  stop_sequence     integer NOT NULL,
  stop_headsign     text NULL,
  pickup_type       integer NULL CHECK(pickup_type >= 0 and pickup_type <=3),
  drop_off_type     integer NULL CHECK(drop_off_type >= 0 and drop_off_type <=3),
  shape_dist_traveled double precision NULL,
  route_short_name  text NULL
);

DROP TABLE IF EXISTS gtfs.frequencies CASCADE;

CREATE TABLE gtfs.frequencies
(
  trip_id           text NOT NULL REFERENCES trips ON DELETE CASCADE,
  start_time        interval NOT NULL,
  end_time          interval NOT NULL,
  headway_secs      integer NOT NULL,
  exact_times   text NULL
);

DROP TABLE IF EXISTS gtfs.transfers CASCADE;

CREATE TABLE gtfs.transfers
(
    from_stop_id  text NOT NULL REFERENCES stops ON DELETE CASCADE,
    to_stop_id    text NOT NULL REFERENCES stops ON DELETE CASCADE,
    transfer_type   integer NOT NULL
);

\copy gtfs.agency from './gtfs/agency.txt' with csv header
\copy gtfs.stops from './gtfs/stops.txt' with csv header
\copy gtfs.routes from './gtfs/routes.txt' with csv header
\copy gtfs.calendar from './gtfs/calendar.txt' with csv header
\copy gtfs.shapes from './gtfs/shapes.txt' with csv header
\copy gtfs.trips from './gtfs/trips.txt' with csv header
\copy gtfs.stop_times from './gtfs/stop_times.txt' with csv header
\copy gtfs.frequencies from './gtfs/frequencies.txt' with csv header
\copy gtfs.transfers from './gtfs/transfers.txt' with csv header