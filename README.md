
# CPANTesters Deploy

This repository contains deploy scripts and configuration files for the
CPANTesters servers.

## Getting Started

### Running the VM

To run the VM, you need Vagrant, VirtualBox, and some Vagrant plugins.
Install Vagrant and VirtualBox according to your OS, and then to install
the Vagrant plugins:

    $ vagrant plugin vbguest

### Preparing the VM

To prepare the VM by deploying basic packages and creating user
accounts, you need [Rex](http://rexify.org) installed. Rex is available
from CPAN: `cpan Rex`. The VM you create can take on multiple roles. To
see what roles are available and how to deploy them, run `perldoc
./Rexfile`.

In order to run the Rex task on your VM, make sure to pass the `-E vm`
flag to `rex`.

### Deploying Applications

Each repository in the CPAN Testers application has its own `Rexfile` to
deploy itself into the machine prepared by this repository. All of the
repository Rexfiles also support the `-E vm` flag to deploy into the VM.

These repositories are:

* [CPAN::Testers::Schema](http://github.com/cpan-testers/cpantesters-schema) - Deploy the database schema
* [CPAN::Testers::Backend](http://github.com/cpan-testers/cpantesters-backend) - Deploy the backend processing tasks and
  daemons
* [CPAN::Testers::API](http://github.com/cpan-testers/cpantesters-api) - Deploy the API server and message broker
* [CPAN::Tesrers::Web](http://github.com/cpan-testers/cpantesters-web) - Deploy the primary web application

## Architecture Overview

This is a quick overview of the CPANTesters architecture as managed by
this repository.

### Database and Metabase

The primary source of CPANTesters data is the Metabase. This is the
database that the CPANTesters reporters write to. This database is
managed elsewhere.

The CPANTesters project reads from the Metabase and writes raw data and
report summaries to a local MySQL database. This local MySQL database is
managed here.

### Backend ETL

The backend processes read from the Metabase and writes to the local
database. These processes also send out the regular report e-mails,
summarize the raw reports in to easily-queried tables, and maintain the
data the web app requires.

### Web app

The CPANTesters web app is the final piece and uses the MySQL database
and the data the Backend ETL provides to make a frontend that users can
use. There are also APIs available from the web frontend.

## Repository Overview

### Rexfile

CPANTesters is managed with [Rex](http://rexify.org). The `Rexfile`
contains the main routines for the CPANTesters deploy processes. To
see the documentation for deploying, do `perldoc ./Rexfile`.

### `backend/`

This directory contains the scripts that maintain the CPANTesters data,
reading incoming test reports and summarizing into the database tables.

### `etc/`

This directory contains configuration files and templates which are
deployed to the servers.

### `dist/`

The application distributions. These are synced from the source by a Rex
task, and are not included in this repository.

