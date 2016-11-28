# Add the oracle jvm ppa, and install java8
# https://launchpad.net/~webupd8team/+archive/ubuntu/java

oracle-ppa:
	pkgrepo.managed:
		- humanname: WebUpd8 Oracle Java PPA repository
		- name: deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main
		- dist: trusty
		- file: /etc/apt/sources.list.d/webupd8team-java.list
		- keyid: EEA14886
		- keyserver: keyserver.ubuntu.com

oracle-license-select:
	debconf.set:
		- name: oracle-java8-installer
		- data:
			'shared/accepted-oracle-license-v1-1': {'type': 'boolean', 'value': 'true'}

oracle-java8-installer:
	pkg:
		- installed
		- require:
		    - pkgrepo: oracle-ppa
		    - oracle-license-select
