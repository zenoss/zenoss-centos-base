#
# RPM builder for Zenoss base depenencies
#

NAME    ?= zenoss-centos-deps
IMAGENAME = zenoss-centos-base
VERSION ?= 1.2.12-dev
TAG = zenoss/$(IMAGENAME):$(VERSION)
DEV_TAG = zenoss/$(IMAGENAME):$(VERSION).devtools
ITERATION ?= 1
PLATFORM = x86_64
RPMVERSION := $(subst -,_,$(VERSION))
RPM =  $(NAME)-$(RPMVERSION)-$(ITERATION).$(PLATFORM).rpm
PYDEPS = pydeps-5.2.0-el7-12
JSBUILDER = JSBuilder2
PHANTOMJS = 1.9.7

default: build

.PHONY: clean clean-devbase build-base build-devbase build

# Clean staged files and produced packages
clean: clean-devbase
	-docker rmi $(TAG)
	rm -f Dockerfile zenoss_env_init.sh && (cd rpm && make clean)

clean-devbase:
	-docker rmi $(DEV_TAG)
	rm -f Dockerfile-devbase

# Make an RPM so that downstream attempts to override packages for this image will trigger
# version dependency warnings from yum/rpm
rpm/pkgroot/$(RPM):
	cd rpm && make rpm VERSION=$(VERSION) NAME=$(NAME) ITERATION=$(ITERATION) PLATFORM=$(PLATFORM) RPM=$(RPM)

Dockerfile:
	sed -e 's/%RPM%/$(RPM)/g' Dockerfile.in > $@

zenoss_env_init.sh:
	sed -e 's/%PYDEPS%/$(PYDEPS)/g' -e 's/%RPM%/$(RPM)/g' -e 's/%JSBUILDER%/$(JSBUILDER)/g' -e 's/%PHANTOMJS%/$(PHANTOMJS)/g'  zenoss_env_init.sh.in > zenoss_env_init.sh

build: build-base build-devbase

# Make image for building RPM
build-base: rpm/pkgroot/$(RPM) Dockerfile zenoss_env_init.sh
	docker build -f Dockerfile -t $(TAG) .

# Make the image for zendev
build-devbase: build-base Dockerfile-devbase
	docker build -f Dockerfile-devbase -t $(DEV_TAG) .

Dockerfile-devbase:
	sed -e 's/%VERSION%/$(VERSION)/g' Dockerfile-devbase.in >$@

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
