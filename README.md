# DSpace @ UNB

Themes & other customizations for UNB's implementation of the DSpace repository.

## Get the source

Clone appropriate branch of the repo: `[git-repos]/unb-dspace`

Fetch DSpace 1.7.x source release: `[dspace-src]`

### RiverRun config files

Link RiverRun config files, etc., to DSpace source directory:

`cd [dspace-src]`

`ln -s [git-repos]/unb-dspace/riverrun ./riverrun`

Any RiverRun config files in [git-repo]/riverrun/config are copied over default
DSpace config files during installation package generation. Config edits should
be made, and tracked, in
 
`[git-repo]/riverrun/config`

### Modified Maven assembly file

Maven assembly file has been modified to include config files, etc., from `[dspace-src]/riverrun`
Copy or link modified version from git repo:

`cp [git-repos]/unb-dspace/dspace/src/assemble/assembly.xml [dspace-src]/dspace/src/assemble/assembly.xml`

### Theme, i18n overlays

Link theme and i18n overlays to DSpace source.

`cd [dspace-src]/dspace/modules/xmlui`

Remove empty `src/main/webapp` dir & link from git repo:

`ln -s [git-repos]/unb-dspace/dspace/modules/xmlui/src` .

### Customized RiverRun aspects

Add custom XMLUI aspects as a module overlay:

`cd [dspace-src]/dspace/modules`

`ln -s [git-repos]/unb-dspace/riverrun/modules/riverrun-xmlui .`

Add module as a dependency in `[dspace-src]/dspace/modules/pom.xml`:
```xml
  ...
  <modules>
    <module>xmlui</module>
    <module>riverrun-xmlui</module>
    ...
  </modules>
```

Also, add the module as a dependency in pom.xml of UI modules as needed (XMLUI, JSPUI, etc.).
In `[dsapce-src]/dspace/modules/xmlui/pom.xml`:

```xml  
  <dependencies>
    ... 
    <dependency>
      <groupId>ca.unb.lib.riverrun</groupId>
      <artifactId>riverrun-xmlui-api</artifactId>
      <version>2.0</version>
    </dependency>
  </dependencies>`
```

### Metadata crosswalks

Add custom metadata crosswalks as a module overlay:

`cd [dspace-src]/dspace/modules`

`ln -s [git-repos]/unb-dspace/riverrun/modules/riverrun-oai .`

Add module as a dependency in `[dspace-src]/dspace/modules/pom.xml`:

```xml
  ...
  <modules>
    <module>xmlui</module>
    <module>riverrun-oai</module>
    ...
  </modules>
```

.. and in `[dsapce-src]/dspace/modules/oai/pom.xml`:

```xml  
  <dependencies>
    ... 
    <dependency>
      <groupId>ca.unb.lib.riverrun</groupId>
      <artifactId>riverrun-xmlui-api</artifactId>
      <version>2.0</version>
    </dependency>
  </dependencies>`
```

## Build & deploy

Set up config values specific to your development environment with the default Maven profile defined in `settings.xml.default`.  

`cp [git-repos]/unb-dspace/dspace/config/settings.xml.default $HOME/.m2/settings.xml`

Edit properties defined in `$HOME/.m2/settings.xml`.  To use the settings in the build:

`cd [dspace-src]/dspace`

`mvn package -Dconfigure-dspace=true`


