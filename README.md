Oracle HTTP Server Docker container
===

This repository contains resources for running Oracle HTTP Server (OHS) in a Docker container.

### Based on Oracle Linux Docker image

For more information please read the [Docker Images from Oracle Linux](http://public-yum.oracle.com/docker-images) page.
> You might be also interested in other images based on the same base - check [WebLogic Community repository](https://github.com/weblogic-community/). For example, you can find the [WebLogic Server Docker image](https://github.com/weblogic-community/weblogic-docker) there.

### How to build and run
Follow the steps below to get this image up and running.

### Prerequisities

Obviously, you need to have Docker installed on your computer (if you don't have it yet, setup it following the instructions on [Docker Installation page](https://docs.docker.com/installation/)). Then, you will also need to download and unzip the OHS binary installation file available on [Oracle Technology Network](http://www.oracle.com/technetwork/middleware/webtier/downloads/index.html) (OTN). The file you download should be named _fmw_12.1.3.0.0_ohs_linux64_Disk1_1of1.zip_ and after unzipping you should get _fmw_12.1.3.0.0_ohs_linux64.bin_. Please note that if the file name is a little bit different (for example, the version of FMW will be 12.1.3.0.1 once such version is release, you will have to alter the _Dockerfile_ too - just find the line starting with `ENV HTTP_BIN` and edit the file name.
> Downloading of product cannot be automatized because you need to accept the Licence agreement.

> Please note, that you will need OTN account for that - but you certainly already have one. If not, no problem - it's free, just create one by registering on any OTN page (probably the download page in this case).

### Building steps

1. Clone this repository into some folder on your computer 
2. Copy the previously downloaded OHS installation binary into the same folder
3. Run the build command:

   ```
   $  docker build -t oracle/ohs:12.1.3 .
   ```
4. Check the built image with

   ```
   $ docker images
   REPOSITORY          TAG                 IMAGE ID            CREATED             VIRTUAL SIZE
   oracle/ohs         12.1.3              9d1baedc3b9f        10 seconds ago      2.992 GB
   ...
   ```

### Running the image

You can run the image with simple command:
```
$ docker run -d -t -i -p 7777:7777 oracle/ohs:12.1.3
```

The output will show 'tailed' _access.log_ of HTTP Server instance and keeps running.

## Default image

The default version of container will have:
* OHS installed
* Standalone domain created
* Node manager started (in default configuration - listening on ssl://localhost:5556)
* HTTP Server instance created and started

## Customizations of container startup
You can change the startup behavior of container by just simply changing the default command to run.

### Running just Node manager
When you don't want to start the OHS instance, start the container as follows:
```
$ docker run -d -t -i -p 7777:7777 -p 5556:5556 roxolid/ohs:12.1.3 /u01/ohs/user_projects/domains/ohs_domain/bin/startNodeManager.sh
```

After such start, the container will display the output of node manager log. To start a HTTP server instance you need to connect to node manager with WLST _from host_ and start instance manually.
> That's also reason why port 5556 was added to run parameters - now it's mapped from host to guest

To start instance manually, run following commands on the host:
```
$ <ORACLE_HOME>/oracle_common/common/bin/wlst.sh

Initializing WebLogic Scripting Tool (WLST) ...

Jython scans all the jar files it can find at first startup. Depending on the system, this process may take a few minutes to complete, and WLST may not return a prompt right away.

Welcome to WebLogic Server Administration Scripting Shell

Type help() for help on available commands

wls:/offline> nmConnect(username='oracle',password='<PASSWORD>',host='localhost',domainName='ohs_domain')
Connecting to Node Manager ...
Successfully Connected to Node Manager.
wls:/nm/ohs_domain> nmStart(serverName='ohs1',serverType='OHS')
Starting server ohs1 ...
Successfully started server ohs1 ...
wls:/nm/ohs_domain> nmDisconnect()
Successfully disconnected from Node Manager.
wls:/offline> exit()


Exiting WebLogic Scripting Tool.

```
> Set `<ORACLE_HOME>` to your Fusion Middleware product Oracle home.
> The password can be find in _Dockerfile_. Just find the line starting with `ENV ADMIN_PASSWORD`. You can also change this password prior building the image.

### Running with just bash
Similarly, if you want to control the whole startup process, just start with shell and do everything manually:
```
$ docker run -d -t -i -p 7777:7777 roxolid/ohs:12.1.3 /bin/bash
```
Then you will probably want to go to `/u01/ohs/user_projects/domains/ohs_domain/bin` and start the node manager and HTTP server instance. Check the `startOHS.sh` script for details.

## Adding web pages
Well, you will probably want to put your own webpages into HTTP server for serving. There are two methods how to do that.

### Web root on host
Simply 'mount' the folder from host to the folder on guest where HTTP server serves files from. Use `-v` switch for that:
```
$ docker run -d -t -i -p 7777:7777 -v <HOST_WEROOT>:/u01/ohs/ohs/templates/htdocs/ roxolid/ohs:12.1.3
```
Of course, change `<HOST_WEBROOT>` to an _absolute_ path on your host machine.

### Copy files to container
This method is useful if you want to pre-populate the container with your web files. It's not different from the first method, but it allows you to commit newly copied files to new image, so when the container is started anywhere else, files will be included. Start container similarly to first method:
```
$ docker run -d -t -i -p 7777:7777 -v <HOST_WEROOT>:/mnt/hostweb roxolid/ohs:12.1.3 /bin/bash
```

Then, in guest shell session copy the files:
```
[oracle@<CONTAINER_ID> bin]$ cp -rf /mnt/hostweb/* ~/data/vms/docker/oracle/ohs
```

Then you need to commit the container (from host):
```
$ docker commit -m "Populated with files" <CONTAINER_ID> oracle/ohs:12.1.3-files
```
Of course, you can choose any other name/tag for your new image.

> You can see the `<CONTAINER_ID>` either in running shell or list it with `docker ps` command.

Then check it is there:
```
$ docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             VIRTUAL SIZE
oracle/ohs         12.1.3-files        9d1baedc3b9f        10 seconds ago      2.999 GB
oracle/ohs         12.1.3              9d1baedc3b9f        1 hour ago          2.992 GB
   ...
```

Enjoy!

> I made this README file intentionaly smooth-talking. When I started with Docker, I was happy for every small enlighting note on what's going on, so I hope this README will also help someone to understand more ;-)

