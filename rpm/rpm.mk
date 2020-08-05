NAME       ?=
VERSION    ?=
PLATFORM   ?=
ITERATION  ?=
RPM        ?=

MAINTAINER := Zenoss CM <cm@zenoss.com>
VENDOR     := Zenoss, Inc.
URL        := http://zenoss.com/
CATEGORY   := admin
DEST       := dest

$(DEST)/$(RPM):
	fpm \
		--verbose \
		-t rpm \
		-s dir \
		-C /pkg \
		-p /pkg \
		-n $(NAME) \
		-v $(VERSION) \
		-d 'bzip2' \
		-d 'device-mapper-libs' \
		-d 'dmidecode' \
		-d 'gzip' \
		-d 'hiredis >= 0.12.1' \
		-d 'krb5-workstation >= 1.15.1' \
		-d 'libaio' \
		-d 'libart_lgpl' \
		-d 'libasyncns' \
		-d 'libgomp' \
		-d 'libsmi = 0.5.0' \
		-d 'mariadb' \
		-d 'memcached >= 1.4.15' \
		-d 'MySQL-python = 1.2.5' \
		-d 'nagios-common' \
		-d 'nagios-plugins' \
		-d 'nagios-plugins-dig' \
		-d 'nagios-plugins-dns' \
		-d 'nagios-plugins-http' \
		-d 'nagios-plugins-ircd' \
		-d 'nagios-plugins-ldap' \
		-d 'nagios-plugins-ntp' \
		-d 'nagios-plugins-perl' \
		-d 'nagios-plugins-ping' \
		-d 'nagios-plugins-rpc' \
		-d 'nagios-plugins-tcp' \
		-d 'net-snmp = 1:5.7.2' \
		-d 'net-snmp-utils = 1:5.7.2' \
		-d 'net-tools >= 2.0' \
		-d 'nmap >= 2:6.40' \
		-d 'openssl >= 1.0.1e' \
		-d 'openssl-devel' \
		-d 'patch' \
		-d 'patch >= 2.7.1'\
		-d 'pcre-devel' \
		-d 'perl-Digest-MD5 >= 2.52' \
		-d 'perl-Time-HiRes >= 4:1.9725' \
		-d 'protobuf-python' \
		-d 'python >= 2.7.5' \
		-d 'python-kerberos = 1.1' \
		-d 'rabbitmq-server = 3.3.5' \
		-d 'redis >= 3.2.12'\
		-d 'rsync' \
		-d 'shadow-utils >= 2:4.1.5.1' \
		-d 'sudo >= 1.8.6' \
		-d 'sysstat' \
		-d 'tar' \
		-d 'wget' \
		-d 'xorg-x11-fonts-Type1' \
		-a $(PLATFORM) \
		-m '$(MAINTAINER)' \
		--iteration $(ITERATION) \
		--rpm-user root \
		--rpm-group root \
		--vendor '$(VENDOR)' \
		--url '$(URL)' \
		--category $(CATEGORY) \
		.
