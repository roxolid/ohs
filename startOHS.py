import os

nmConnect(username='oracle',password=os.environ["ADMIN_PASSWORD"],domainName='ohs_domain')
nmStart(serverName='ohs1', serverType='OHS')

