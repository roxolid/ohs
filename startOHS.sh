#!/bin/bash

cd /u01/ohs/user_projects/domains/ohs_domain/bin
nohup ./startNodeManager.sh > nm.out 2>&1 &

# Just a little bit of waiting while the node manager starts
sleep 5s

# startOHS.py is an example of how to start OHS instance via WLST script
/u01/ohs/oracle_common/common/bin/wlst.sh startOHS.py

# startComponent.sh is the official starting script - it will just contact
# node manager, starts the instance and quit => no nohup and tail below needed
#./startComponent.sh ohs1 2>&1 > ohs1.out

# First access to instance - the only purpose of this is to force HTTP server create
# access_log file (otherwise the next tail command will quit with "no such file" error
curl http://localhost:7777 > /dev/null

# Tailing for keeping the container running
#tail -f nm.out
tail -f /u01/ohs/user_projects/domains/ohs_domain/servers/ohs1/logs/access_log
