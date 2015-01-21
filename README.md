Oracle HTTP Server Docker container
===

This repository contains resources for running Oracle HTTP Server (OHS) in a Docker container.

## Based on Oracle Linux Docker image

For more information please read the [Docker Images from Oracle Linux](http://public-yum.oracle.com/docker-images) page.

## How to build and run

## Prerequisities

Obviously, you need to have Docker installed on your computer. Then, you will also need to download and unzip the OHS binary installation file available on Oracle Technology Network (OTN).

## Building steps

First of all you need to clone this repository to some (temporary) directory on your computer, of course. Second, 

> This step cannot be automatized because you need to accept the Licence agreement.

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
$ docker run -d -t -i -p 7777:7777 roxolid/ohs:DBG7
```

The output will be _tailed access.log_ of HTTP Server instance. 

# Default image

The default version of image will have:
* OHS installed
* Standalone domain created
* Node manager started (in default configuration - listening on ssl://localhost:5556)
* HTTP Server instance created and started

# Customizations of image
## Running just Node manager
## Running with just bash

# Adding web pages
      
tail -f  /u01/ohs/user_projects/domains/ohs_domain/servers/ohs1/logs/access_log


