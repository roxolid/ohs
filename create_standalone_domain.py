OH ='/u01/ohs'
domainName = 'ohs_domain'
domainDir = OH + '/user_projects/domains/' + domainName
# Read OHS Standalone template
# using 12.1.2
#readTemplate(OH +'/ohs/common/templates/wls/ohs_standalone_template_12.1.2.jar')
# using 12.1.3
readTemplate(OH +'/wlserver/common/templates/wls/base_standalone.jar')
addTemplate(OH +'/ohs/common/templates/wls/ohs_standalone_template_12.1.3.jar')
# Configure Nodemanager
cd('/')
create(domainName, 'SecurityConfiguration') 
cd('SecurityConfiguration/' + domainName)
set('NodeManagerUsername', 'oracle')
set('NodeManagerPasswordEncrypted', 'welcome1')
setOption('NodeManagerType', 'PerDomainNodeManager')
cd('/Machines/localmachine/NodeManager/localmachine')
cmo.setListenPort(5556)
# Optional Steps:
# The standalone OHS template already comes with an
# out­of­the­box machine ('localmachine') and a single
# instance of OHS ('ohs1') with default configuration
# values. The remaining steps are needed only if the
# out­of­the­box defaults need to be changed
#cd('/OHS/<component_name>')
#cmo.setAdminHost('127.0.0.1')
#cmo.setAdminPort('<admin_port_num>')
#cmo.setListenAddress('<ip_address>')
#cmo.setListenPort('<port_num>')
#cmo.setSSLListenPort('<ssl_port_num>')
# create the domain
writeDomain(domainDir)
closeTemplate()

