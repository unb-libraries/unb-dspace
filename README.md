# DSpace @ UNB

Themes & other customizations for UNB's implementation of the DSpace repository.

## Set up development environment

The SHERPA/RoMEO aspect uses JAXB 2.0 which is distributed with Java 6, and requires Java 5 as a minimum version.

Clone appropriate branch of the repo: `[git]/unb-dspace`

Fetch DSpace source release: `[dspace-src]`

### Maven assembly file

Back up or delete Maven assembly file; copy or link version from cloned git repo:

`cp [dspace-src]/dspace/src/assemble/assembly.xml [dspace-src]/dspace/src/assemble/default-assembly.xml`
 
`cp [git]/unb-dspace/dspace/src/assemble/assembly.xml [dspace-src]/dspace/src/assemble/assembly.xml`

### RiverRun source

Link RiverRun source:

`cd [dspace-src]`

`ln -s [git]/riverrun ./riverrun`




