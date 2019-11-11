# Monitored LXD Environment

## Environment


![Alt text](topology_1.jpg?raw=true "Topology 1")


## Script Details

```
	########################################################################
	#
	#       Filename:  monitored_lxd_environment.sh
	#
	#    Description:  Monitored LXD Environment General Script.
	#                  Run as super user.
	#
	#        Version:  1.1
	#        Created:  08/10/2019 17:12:36 PM
	#       Revision:  1
	#
	#         Author:  Gustavo P de O Celani
	#
	########################################################################
```


## SSH

This machine is on DMZ network that has access to internet under firewall rules. It is responsable to access all another machines using SSHv2.


Alias usage:
```
# SSH Alias - Network DMZ
$ ssh-ssh
$ ssh-proxy

# SSH Alias - Network SERVERS
$ ssh-log
$ ssh-gerencia

# SSH Alias - Network WEB
$ ssh-www1
$ ssh-www2
```

### SSH Hardering

* SSH Protol 2

* Disabling root login

* Client sessions
	- Client Alive Interval: 300
	- Client Alive Count Max: 3

* Avoiding default port (22 -> 4578)

* Disabling X11 forwarding

* Only 'ssh_user' allowed

* 3-Factor authentication
	- Password
	- RSA Key
	- Challenge PAM with Google-Authenticator

* Fail2ban
	- Selected ban time
	- 3 Max retry
	- Alias to watch logs: `$ log-fail2ban`

