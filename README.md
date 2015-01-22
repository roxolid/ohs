Oracle HTTP Server Docker container
===

This repository contains resources for running Oracle HTTP Server (OHS) in a Docker container.

## Based on Oracle Linux Docker image

For more information please read the [Docker Images from Oracle Linux](http://public-yum.oracle.com/docker-images) page.
> You might be also interested in other images based on the same base - check [WebLogic Community repository](https://github.com/weblogic-community/). For example, you can find the [WebLogic Server Docker image](https://github.com/weblogic-community/weblogic-docker) there.

## How to build and run
Follow the steps below to get this image up and running.

## Prerequisities

Obviously, you need to have Docker installed on your computer. Then, you will also need to download and unzip the OHS binary installation file available on Oracle Technology Network (OTN).
> Downloading of product cannot be automatized because you need to accept the Licence agreement.

> Please note, that you will need OTN account for that - but you certainly already have one. If not, no problem - it's free, just create one by registering on any OTN page (probably the download page in this case).

## Building steps

1. Clone this repository into some folder on your computer 
2. Copy the previously download OHS installation binary into the same folder
3. Run the build command:

   ```
   $  docker build -t roxolid/ohs:12.1.3 .
   ```
4. Check the built image with

   ```
   $ docker images
   REPOSITORY          TAG                 IMAGE ID            CREATED             VIRTUAL SIZE
   roxolid/ohs         12.1.3              9d1baedc3b9f        10 seconds ago      2.992 GB
   ...
   ```

## Running the image

You can run the image with simple command:
```
$ docker run -d -t -i -p 7777:7777 roxolid/ohs:12.1.3
```

The output will show _'tailed' access.log_ of HTTP Server instance and keeps running.

# Default image

The default version of image will have:
* OHS installed
* Standalone domain created
* Node manager started (in default configuration - listening on ssl://localhost:5556)
* HTTP Server instance created and started

# Customizations of container startup
You can change the startup behavior of container by just simply changing the default command to run.

## Running just Node manager
When you don't want to start the OHS instance, just start the container as follows:
```
$ docker run -d -t -i -p 7777:7777 -p 5556:5556 roxolid/ohs:12.1.3 /u01/ohs/user_projects/domains/ohs_domain/bin/startNodeManager.sh
```

After such start, the container will display the output of node manager log. To start a HTTP server instance you need to connect to it with WLST from host and start instance manually.
> That's also reason why port 5556 was added to run parameters - now it's mapped from host to guest

To start instance manually, run following commands on the host:
```
$ _<ORACLE_HOME>_/oracle_common/common/bin/wlst.sh
```
> Set `<ORACLE_HOME>` to your Fusion Middleware product Oracle home.

## Running with just bash
Similarly, if you want to control the whole startup process, just start with shell and do everything manually:
```
$ docker run -d -t -i -p 7777:7777 roxolid/ohs:12.1.3 /bin/bash
```
Then you will probably want to go to `/u01/ohs/user_projects/domains/ohs_domain/bin` and start the node manager and HTTP server instance. Check the `startOHS.sh` script for details.

# Adding web pages

Enjoy!

> I made this README file intentionaly smooth-talking. When I started with Docker, I was happy for every small enlighting note on what's going on, so I hope this README will also help someone to understand more ;-)

