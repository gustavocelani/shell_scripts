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
	#        Version:  1.2
	#        Created:  08/10/2019 17:12:36 PM
	#       Revision:  1
	#
	#         Author:  Gustavo P de O Celani
	#
	########################################################################
```


## Containers


### SSH

This machine is on DMZ network that has access to internet under firewall rules. It is responsable to access all another machines using SSHv2.


### WWW1 and WWW2

This machines are on WEB network that has no access to internet under firewall rules. Each one provides a HTTP Web Server on port 80 powered by Nginx.


### Proxy

This machine is on DMZ network that has access to internet under firewall rules. It provides a HTTPS Reverse Proxy with Load Balancer on port 443 powered by Nginx.


### Log Server

This machine is on SERVERS network that has no access to internet under firewall rules. It provides a centralized log server powered by Rsyslog and LogAnalyzer.


## Hardening

### SSH

- SSH Protol 2
- Disabling root login
- Client sessions
	- Client Alive Interval: 300
	- Client Alive Count Max: 3
- Avoiding default port (22 -> 4578)
- Disabling X11 forwarding
- Only 'ssh_user' allowed
- 3-Factor authentication
	- Password
	- RSA Key
	- Challenge PAM with Google-Authenticator
- Fail2ban
	- Selected ban time
	- 3 Max retry
	- Alias to watch logs: `$ log-fail2ban`
- Firewall rules


### WWW1 and WWW2

* Firewall rules

#### Proxy

- TLS over HTTP (HTTPS)
- Load Balancer for WWW1 and WWW2
	- `https://proxy-ip/`
	- `https://proxy-ip/www`
- Reverse Proxy
	- 'www1': `https://proxy-ip/www1`
	- 'www2': `https://proxy-ip/www2`
	- 'log': `https://proxy-ip/log`
- DDoS Prevention
- Firewall rules

#### Log Server

- Avoiding Rsyslog default port (514 -> 5689)
- Allowed networks whitelist
- Log rotation weekly
- Firewall rules


## Usage

### SSH

Alias:
```
# Network DMZ
$ ssh-ssh
$ ssh-proxy

# Network SERVERS
$ ssh-log
$ ssh-gerencia

# Network WEB
$ ssh-www1
$ ssh-www2
```
