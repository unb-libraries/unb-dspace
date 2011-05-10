# DSpace @ UNB

Themes & other customizations for UNB's implementation of the DSpace repository.

## Set up development environment

Clone appropriate branch of the repo: `[git]/unb-dspace`

Fetch DSpace source release: `[dspace-src]`

### dspace/bin 

Copy or link custom scripts from `[git]/unb-dspace/dspace/bin` to `[dspace-src]/dspace/bin`

`define-structure`
`import-data`
`map-handles`

### dspace/config

Copy or link git-managed config files:

`mv [dspace-src]/dspace/config [dspace-src]/dspace/config_default`

`ln -s [git]/unb-dspace/dspace/config [dspace-src]/dspace/config`

### dspace/data 

Link sample data set:

`ln -s [git]/unb-dspace/dspace/data [dspace-src]/dspace/data`

### dspace/modules 

Remove existing (empty) webapp directory:

`rmdir [dspace-src]/dspace/modules/xmlui/src/main/webapp`

`ln -s [git]/unb-dspace/dspace/modules/xmlui/src/main/webapp [dspace-src]/dspace/modules/xmlui/src/main/webapp`

### dspace/src 

Back up or delete Maven assembly file; copy or link modified version to include `dspace/data` in package:

`cp [dspace-src]/dspace/src/assemble/assembly.xml [dspace-src]/dspace/src/assemble/default-assembly.xml`
 
`cp [git]/unb-dspace/dspace/src/assemble/assembly.xml [dspace-src]/dspace/src/assemble/assembly.xml`

Copy or link RiverRun build file (defines tasks for loading sample data):

`cp [git]/unb-dspace/dspace/src/main/config/build-riverrun.xml [dspace-src]/dspace/src/main/config/build-riverrun.xml`

## RiverRun extensions to DSpace

Link `riverrun-api` and `riverrun-xmlui` projects to DSpace source:

`ln -s [git]/unb-dspace/riverrun-api [dspace-src]/riverrun-api`

`ln -s [git]/unb-dspace/riverrun-api [dspace-src]/riverrun-xmlui`

Copy modified POM files to build RiverRun extensions:

`cp [git]/unb-dspace/dspace/pom.xml [dspace-src]/dspace/pom.xml`

The OAI and XMLUI webapps depend on RiverRun extensions, so update the POMs here, too:

`cp [git]/unb-dspace/dspace/modules/oai/pom.xml [dspace-src]/dspace/modules/oai/pom.xml`

`cp [git]/unb-dspace/dspace/modules/xmlui/pom.xml [dspace-src]/dspace/modules/xmlui/pom.xml`

See DSpace build cookbook for details: https://wiki.duraspace.org/display/DSPACE/BuildCookbook

## Maven configuration

Customize config values with the default Maven profile defined in `settings.xml.default`.  

`cp [git]/unb-dspace/dspace/config/settings.xml.default $HOME/.m2/settings.xml`

Edit properties defined in `$HOME/.m2/settings.xml`.  To use the settings in the build:

`cd [dspace-src]/dspace`
`mvn package -Dconfigure-dspace=true`

### Override PostgreSQL connection information

** Maven 3 **

If you're not connecting to PostgreSQL with default user account and password: edit the connection settings in the PostgreSQL profile defined in `[dspace-src]/dspace/pom.xml`

Run Maven:

`mvn package -Dconfigure-dspace=true -P postgres`

** Maven 2 **

Copy `[dspace-src]/dspace/profiles-example.xml` to `[dspace-src]/dspace/profiles.xml`.  Edit connection details; Maven will pick up `profiles.xml` automatically.

## RiverRun Ant tasks

Run Maven, as usual:

`cd [dspace-src]/dspace`

`mvn package -Dconfigure-dspace=true`

Get a list of RiverRun-specific tasks:

`cd [dspace-src]/dspace/target/[build-dir]`

`ant -f build-riverrun.xml`
