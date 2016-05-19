#
# RPM builder for Zenoss base depenencies
#

NAME    ?= zenoss-centos-deps
IMAGENAME = zenoss-centos-base
VERSION ?= 1.1.4_dev
ITERATION ?= 1
PLATFORM = x86_64
RPM =  $(NAME)-$(VERSION)-$(ITERATION).$(PLATFORM).rpm
PYDEPS = pydeps-5.2.0-el7-2

default: build

# Clean staged files and produced packages
.PHONY: clean
clean: 
	rm -f Dockerfile && (cd rpm && make clean)

# Make an RPM
rpm/pkgroot/$(RPM):
	cd rpm && make rpm VERSION=$(VERSION) NAME=$(NAME) ITERATION=$(ITERATION) PLATFORM=$(PLATFORM) RPM=$(RPM)

Dockerfile: 
	sed -e 's/%PYDEPS%/$(PYDEPS)/g' -e 's/%RPM%/$(RPM)/g' Dockerfile.in > Dockerfile


# Make image for building RPM
build: rpm/pkgroot/$(RPM) Dockerfile
	docker build -t $(IMAGENAME):$(VERSION) .

push:
	docker push $(IMAGENAME):$(VERSION)
