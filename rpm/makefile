#
# RPM builder for Zenoss base depenencies
#

NAME          ?=
VERSION       ?=
PLATFORM      ?=
ITERATION     ?=
RPM           ?=
MAINTAINER    = Zenoss CM <cm@zenoss.com>
PKGROOT       = pkgroot
VENDOR        = Zenoss, Inc.
URL           = http://zenoss.com/
CATEGORY      = admin
PWD	      = $(shell pwd)
DUID         ?= $(shell id -u)
DGID         ?= $(shell id -g)

PKG_VERSION = $(VERSION)
FULL_NAME=$(NAME)

.PHONY: all clean rpm
.SILENT: desc

all: desc

desc:
	echo "Usage: make rpm. $(FULL_NAME)-$(PKG_VERSION)."

# Clean staged files and produced packages
.PHONY: clean
clean: 
	rm -rf $(PKGROOT)

.PHONY: mrclean
mrclean: clean

$(PKGROOT):
	mkdir -p $@

# Make image for building RPM
image:
	docker build -t zenoss-fpm .

# Make an RPM
rpm: image 
	docker run -v ${PWD}/$(PKGROOT):/pkg -it --rm zenoss-fpm bash -c "fpm \
		--verbose \
		-t rpm \
		-s dir \
		-C . \
		-p /pkg \
		-n $(FULL_NAME) \
		-v $(PKG_VERSION) \
		-d shadow-utils \
		-d dmidecode \
		-d gnupg \
		-d gzip \
		-d hiredis \
		-d krb5-workstation \
		-d libcap \
		-d libsmi \
		-d 'libxslt >= 1.1' \
		-d mariadb-server \
		-d 'nagios-plugins >= 1.4.15' \
		-d 'nagios-plugins-dig  >= 1.4.15' \
		-d 'nagios-plugins-dns  >= 1.4.15' \
		-d 'nagios-plugins-http >= 1.4.15' \
		-d 'nagios-plugins-ircd >= 1.4.15' \
		-d 'nagios-plugins-ldap >= 1.4.15' \
		-d 'nagios-plugins-ntp  >= 1.4.15' \
		-d 'nagios-plugins-ping >= 1.4.15' \
		-d 'nagios-plugins-rpc  >= 1.4.15' \
		-d 'nagios-plugins-tcp  >= 1.4.15' \
		-d 'net-snmp-utils >= 5.3.2.2-9' \
		-d net-tools \
		-d nmap \
		-d openssl \
		-d patch \
		-d patch \
		-d 'python >= 2.7.0' \
		-d python-kerberos \
		-d 'rabbitmq-server >= 2.8.6' \
		-d readline \
		-d redis \
		-d rsync \
		-d sysstat \
		-d 'sudo >= 1.7.0' \
		-d supervisor \
		-d tar \
		-d wget \
		-a $(PLATFORM) \
		-m '$(MAINTAINER)' \
		--iteration $(ITERATION) \
		--rpm-user root \
		--rpm-group root \
		--vendor '$(VENDOR)' \
		--url '$(URL)' \
		--category $(CATEGORY) \
		. && chown -R $(DUID):$(DGID) /pkg"

