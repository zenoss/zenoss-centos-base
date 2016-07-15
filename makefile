#
# RPM builder for Zenoss base depenencies
#

NAME    ?= zenoss-centos-deps
IMAGENAME = zenoss-centos-base
VERSION ?= 1.2.1-dev
TAG = zenoss/$(IMAGENAME):$(VERSION)
ITERATION ?= 1
PLATFORM = x86_64
RPMVERSION := $(subst -,_,$(VERSION))
RPM =  $(NAME)-$(RPMVERSION)-$(ITERATION).$(PLATFORM).rpm
PYDEPS = pydeps-5.2.0-el7-4
JSBUILDER = JSBuilder2


default: build

# Clean staged files and produced packages
.PHONY: clean
clean:
	-docker rmi $(TAG)
	rm -f Dockerfile zenoss_env_init.sh && (cd rpm && make clean)

# Make an RPM so that downstream attempts to override packages for this image will trigger
# version dependency warnings from yum/rpm
rpm/pkgroot/$(RPM):
	cd rpm && make rpm VERSION=$(VERSION) NAME=$(NAME) ITERATION=$(ITERATION) PLATFORM=$(PLATFORM) RPM=$(RPM)

Dockerfile:
	sed -e 's/%RPM%/$(RPM)/g' Dockerfile.in > Dockerfile

zenoss_env_init.sh:
	sed -e 's/%PYDEPS%/$(PYDEPS)/g' -e 's/%RPM%/$(RPM)/g' -e 's/%JSBUILDER%/$(JSBUILDER)/g' zenoss_env_init.sh.in > zenoss_env_init.sh

# Make image for building RPM
build: rpm/pkgroot/$(RPM) Dockerfile zenoss_env_init.sh
	docker build -t $(TAG) .

push:
	docker push $(TAG)

# Generate a make failure if the VERSION string contains "-<some letters>"
verifyVersion:
	@./verifyVersion.sh $(VERSION)

# Generate a make failure if the image(s) already exist
verifyImage:
	@./verifyImage.sh zenoss/$(IMAGENAME) $(VERSION)

# Do not release if the image version is invalid
# This target is intended for use when trying to build/publish images from the master branch
release: verifyVersion verifyImage clean build push
