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

rpm: image $(PKGROOT)/$(RPM)

# Make an RPM
.PHONY: $(PGKROOT)/$(RPM)
$(PKGROOT)/$(RPM):
	docker run -v "${PWD}/$(PKGROOT):/pkg" -i --rm zenoss-fpm bash -c "fpm \
		--verbose \
		-t rpm \
		-s dir \
		-C . \
		-p /pkg \
		-n $(FULL_NAME) \
		-v $(PKG_VERSION) \
		-d 'shadow-utils = 2:4.1.5.1' \
		-d 'dmidecode = 1:3.0' \
		-d 'gzip' \
		-d 'bzip2' \
		-d 'hiredis = 0.12.1' \
		-d 'krb5-workstation = 1.14.1' \
		-d 'libsmi = 0.4.8' \
		-d 'mariadb-server = 1:5.5.52' \
		-d 'memcached = 1.4.15' \
		-d 'MySQL-python = 1.2.5' \
		-d 'net-snmp = 1:5.7.2' \
		-d 'net-snmp-utils = 1:5.7.2' \
		-d 'net-tools = 2.0' \
		-d 'nmap = 2:6.40' \
		-d 'openssl >= 1.0.1e' \
		-d 'patch = 2.7.1'\
		-d 'perl-Digest-MD5 = 2.52' \
		-d 'perl-Time-HiRes = 4:1.9725' \
		-d 'python = 2.7.5' \
		-d 'python-kerberos = 1.1' \
		-d 'rabbitmq-server = 3.3.5' \
		-d 'redis = 3.2.3'\
		-d 'rsync' \
		-d sysstat \
		-d 'sudo >= 1.8.6' \
		-d 'tar' \
		-d 'wget' \
		-a $(PLATFORM) \
		-m '$(MAINTAINER)' \
		--iteration $(ITERATION) \
		--rpm-user root \
		--rpm-group root \
		--vendor '$(VENDOR)' \
		--url '$(URL)' \
		--category $(CATEGORY) \
		. && chown -R $(DUID):$(DGID) /pkg"
