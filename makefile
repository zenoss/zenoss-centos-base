#
# RPM builder for Zenoss base depenencies
#

NAME       ?= zenoss-centos-deps
IMAGENAME  := zenoss-centos-base
VERSION    ?= 1.2.26
TAG        := zenoss/$(IMAGENAME):$(VERSION)
DEV_TAG    := zenoss/$(IMAGENAME):$(VERSION).devtools
ITERATION  ?= 1
PLATFORM   := x86_64
RPMVERSION := $(subst -,_,$(VERSION))
RPM_DEPS   := $(NAME)-$(RPMVERSION)-$(ITERATION).$(PLATFORM).rpm
PYDEPS     := pydeps-5.6.3-el7-1
JSBUILDER  := JSBuilder2
PHANTOMJS  := 1.9.7
RPM_LIBSMI := libsmi-0.5.0-1.el7.x86_64.rpm

default: build

.PHONY: clean clean-devbase build build-base build-devbase

# Clean staged files and produced packages
clean: clean-devbase
	-docker rmi $(TAG)
	cd rpm && make clean
	cd libsmi && make clean
	rm -f Dockerfile zenoss_env_init.sh

clean-devbase:
	-docker rmi $(DEV_TAG)
	rm -f Dockerfile-devbase

# Build libsmi 0.5.0, which is not currently available from the CentOS distro.
# This can be removed when CentOS ships libsmi 0.5.0
libsmi/$(RPM_LIBSMI):
	cd libsmi && make

# Make an RPM so that downstream attempts to override packages for this image will trigger
# version dependency warnings from yum/rpm
rpm/pkgroot/$(RPM_DEPS):
	cd rpm && make rpm VERSION=$(VERSION) NAME=$(NAME) ITERATION=$(ITERATION) PLATFORM=$(PLATFORM) RPM=$(RPM_DEPS)

Dockerfile: Dockerfile.in
	sed \
		-e 's/%RPM_DEPS%/$(RPM_DEPS)/g' \
		-e 's/%RPM_LIBSMI%/$(RPM_LIBSMI)/g' \
		$< > $@

zenoss_env_init.sh: zenoss_env_init.sh.in
	sed \
		-e 's/%PYDEPS%/$(PYDEPS)/g' \
		-e 's/%RPM_DEPS%/$(RPM_DEPS)/g' \
		-e 's/%RPM_LIBSMI%/$(RPM_LIBSMI)/g' \
		-e 's/%JSBUILDER%/$(JSBUILDER)/g' \
		-e 's/%PHANTOMJS%/$(PHANTOMJS)/g' \
		$< > $@

build: build-base build-devbase

# Make image for building RPM
build-base: rpm/pkgroot/$(RPM_DEPS) libsmi/$(RPM_LIBSMI) Dockerfile zenoss_env_init.sh
	docker build -f Dockerfile -t $(TAG) .

# Make the image for zendev
build-devbase: build-base Dockerfile-devbase
	docker build -f Dockerfile-devbase -t $(DEV_TAG) .

Dockerfile-devbase: Dockerfile-devbase.in
	sed -e 's/%VERSION%/$(VERSION)/g' $< >$@

push:
	docker push $(TAG)
	docker push $(DEV_TAG)

# Generate a make failure if the VERSION string contains "-<some letters>"
verifyVersion:
	@./verifyVersion.sh $(VERSION)

# Generate a make failure if the image(s) already exist
verifyImage:
	@./verifyImage.sh zenoss/$(IMAGENAME) $(VERSION)

# Do not release if the image version is invalid
# This target is intended for use when trying to build/publish images from the master branch
release: verifyVersion verifyImage clean build push
