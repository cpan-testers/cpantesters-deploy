
# CPANTesters Deploy

This repository contains a development environment, deploy scripts, and
configuration files for the CPANTesters servers.

## Getting Started (Development Environment)

This repository can be used as a development environment, and is the
recommended way to develop for CPAN Testers.

### Prerequisites

To use this environment, you must have:

1. `make`
2. `git`
3. `docker`
    * On MacOS and Windows, install [Docker Desktop](https://www.docker.com/products/docker-desktop)

### Fetch Project Code

To fetch the project code, use `make src`. This will download the CPAN
Testers repositories into the `src/` directory.

### Build Docker Containers

To build the initial Docker containers, use `make compose`. This will
build:

1. `cpantesters/base` - The base CPAN Testers container
2. `cpantesters/schema` - Container with the CPAN Testers schema
3. `cpantesters/backend` - The backend, which runs Minion workers
4. `cpantesters/api` - The API web application
5. `cpantesters/web` - The new web application
6. The docker-compose utility container instances

Each build will write a log to `build-*.log` to inspect for issues.

Docker itself is smart about not rebuilding things it does not need to,
so `make compose` will be as fast as it can be. However, if you want to
only build a certain container, you can use the following `make`
targets:

* `make docker-base`
* `make docker-schema`
* `make docker-backend`
* `make docker-api`
* `make docker-web`

### Run Test Cluster

To run the test cluster, use `make start`. This uses the
`docker-compose.yml` file to run a full CPAN Testers cluster including
two database nodes, an API node, and a Web node. This also automatically
runs a database upgrade (deploying the schema if it's missing).

Once the cluster starts, you can test the web apps with these URLs:

* <http://localhost:3000> - The main web app
* <http://localhost:4000> - The API web app
* <http://localhost:5000> - The legacy metabase web app

To view the logs from the docker containers, use `docker-compose logs`.
The `-f` flag will follow the logs like `tail -f`.

### Populate Test Data

To add some data to your development instance, run `make data` and
specify a distribution (with an optional version), like so:

    make data DIST=Mojolicious@8.27

This will download all the data from the primary CPAN Testers database
and load it into your dev site.

### Make Changes

Make changes to the code in the `src/` directory. When you're done, use
`make compose` to rebuild the images and `make restart` to restart the
containers.

#### Connect to the Tester database

To connect to the running tester database, use `make connect`.

#### Backend processing of incoming test reports

Once a report is in the database, it must be processed. Any report in
the database can be reprocessed any number of times.

To re-process an existing test report, run the `beam run report process`
command inside the `backend` container:

    docker-compose exec backend beam run report process dc9c7be4-1985-11ea-9825-b8cf277f9bb7

To send a request to re-process the report to the Minion job queue, use
`beam run report queue`:

    docker-compose exec backend beam minion run report queue dc9c7be4-1985-11ea-9825-b8cf277f9bb7

To see all the available backend commands:

    docker-compose exec backend beam list

#### Test reporting clients

To submit reports to your dev instance, install and configure
[CPAN::Reporter](http://metacpan.org/pod/CPAN::Reporter).

    # Enter the cpan shell using the `cpan` command
    cpan> install Task::CPAN::Reporter
    cpan> reload cpan
    cpan> o conf init test_report

When asked about the `transport?` value, use the value below

    Metabase uri http://localhost:5000/api/v1/ id_file metabase_id.json

This config file is also used by CPANPLUS and App-cpanminus-reporter.

*NOTE:* CPAN::Reporter tries to stop you from sending duplicate reports
by keeping track of the reports you've sent. If you get this message,
you should clear the cache in `~/.cpanreporter/reports-sent.db`.

    CPAN::Reporter: this appears to be a duplicate report for the test phase:
    PASS Mojolicious-8.27 darwin-2level 18.0.0

    Test report will not be sent.

#### Web applications

Make your change in the `src/` project directory, rebuild and restart
(`make compose restart`). Your changed files will be added to the Docker
containers and ready to run! Note: Only files added to the Git repo will
be installed into the Docker containers.

## Architecture Overview

This is a quick overview of the CPANTesters architecture as managed by
this repository.

### Database and Metabase (`cpantesters-schema`)

The primary source of CPANTesters data is the schema. This is the
database that the CPANTesters reporters write to.

A mock version of the previous main database, Metabase, is still written
to for legacy processes. These need to be updated to use the main
database and then the Metabase can be decomissioned.

### Backend ETL (`cpantesters-backend`)

The backend processes turn the full test reports into summaries,
statistics, and metrics.  These processes also send out the regular
report e-mails, summarize the raw reports in to easily-queried tables,
and maintain the data the web app requires.

### Web app (`cpantesters-api`, `cpantesters-web`)

The CPANTesters web app is the final piece and uses the MySQL database
and the data the Backend ETL provides to make a frontend that users can
use. There are also APIs available from the web frontend.

The web app has its own database to manage user accounts and
preferences.

## Repository Overview

### Rexfile

CPANTesters is managed with [Rex](http://rexify.org). The `Rexfile`
contains the main routines for the CPANTesters deploy processes. To
see the documentation for deploying, do `perldoc ./Rexfile`.

### Dockerfile

CPAN Testers is currently being migrated to Docker containers to make it
easier to develop and deploy. During the transition, Docker is used for
development, but production deployment is done using Rex.

The Dockerfile in this repository builds a base image with prereqs that
all the apps need. The Dockerfiles in the `src` repositories are
responsible for their own prereqs.

### docker-compose.yml

The docker compose configuration for a development cluster. See "Getting
Started", above.

### `src/`

The location for the CPAN Testers source repositories. Use `make src` to
populate these.

### `etc/`

This directory contains configuration files and templates which are
deployed to the servers.

### `dist/`

CPAN distributions to include in the CPAN Testers base image. This
allows pre-release versions of CPAN modules to be tested in the
development environment.

