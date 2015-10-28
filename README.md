# virtualBoxik
A set of scripts designed to help manage Virtual Machines.

boxikListener.err/.log :
	Output logs of the delService program, simple things like on/off, IP address adding, and any errors that occur.
  
cleanHosts.sh :
	Run as root. Cleans offline/non-existing hosts from /ansible/hosts and /etc/ssh/ssh_config 
  
configVMNetwork.sh:
	Updates the network configurations of all owned VM's, (user-specific unlike cleanHosts), required for Guest->Host connections. Run after any manual VM cloning.
  
  
cloneLink.sh:
	Creates some clones, usage->
		./cloneLink.sh nameToBeClone name'sSnapshotName newName numberOfVM's	
	Automatically runs configVMNetwork after completion so no need to do that manually.
  
listVM.sh :
  Run as root. Lists all VM's across all users.
  
  
BoxikScripts: Don't run these yourself, program use only. 
  
  
boxikListener.sh:
	Listens for any incoming connections from "itself", so only VM's on the Host machines can access it. Routes any commands into manage.sh.
    
manage.sh:
	Parses commands and forwards them to the appropriate scripts.

host.sh:
	Creates host listings in /etc/ssh/ssh_config and /ansible/hosts. Requires IP and VM name.
  
boxik_config:
	Some configuration options , more info in file.

secureGuestKey:
	You can place your key anywhere you want, provided you update the boxik_config file. You can remove these if not needed.
