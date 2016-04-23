
# CPANTesters Deploy

This repository contains deploy scripts and configuration files for the
CPANTesters servers.

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
contains the main routines for the CPANTesters deploy processes.

### `backend/`

This directory contains the scripts that maintain the CPANTesters data,
reading incoming test reports and summarizing into the database tables.

### `etc/`

This directory contains configuration files and templates which are
deployed to the servers.

### `dist/`

The application distributions. These are synced from the source by a Rex
task, and are not included in this repository.

