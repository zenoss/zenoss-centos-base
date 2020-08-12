#
# RPM builder for Zenoss base depenencies
#

include versions.mk

# zenoss-centos-base Docker image
PROJECT   := zenoss
NAME      := zenoss-centos-base
IMAGE     := $(PROJECT)/$(NAME):$(VERSION)
IMAGE_DEV := $(PROJECT)/$(NAME):$(VERSION).devtools

IMAGE_EXISTS = $(shell docker image list --format '{{.Tag}}' $(IMAGE))
IMAGE_DEV_EXISTS = $(shell docker image list --format '{{.Tag}}' $(IMAGE_DEV))

# zenoss-centos-deps RPM
ZDEPS_NAME ?= zenoss-centos-deps
ITERATION  ?= 1
PLATFORM   := x86_64
RPMVERSION := $(subst -,_,$(VERSION))
RPM_DEPS   := $(ZDEPS_NAME)-$(RPMVERSION)-$(ITERATION).$(PLATFORM).rpm

# pydeps package
PYDEPS := pydeps-$(PYDEPS_VERSION)-el7-1.tar.gz

# jsbuilder archive
JSBUILDER := JSBuilder2.zip

# phantomjs
PHANTOMJS := phantomjs-$(PHANTOMJS_VERSION)-linux-x86_64.tar.bz2

# libsmi package
RPM_LIBSMI := libsmi-$(LIBSMI_VERSION).el7.x86_64.rpm

.PHONY: clean clean-devbase build build-image build-dev-image build-deps default push

default: build

# Clean staged files and produced packages
clean: clean-image clean-devbase
	rm -f $(RPM_LIBSMI) $(PYDEPS) $(JSBUILDER) $(PHANTOMJS)
	make -C rpm clean

clean-image:
ifneq ($(IMAGE_EXISTS),)
	-docker image rm $(IMAGE)
	IMAGE_EXISTS=
endif
	rm -f Dockerfile

clean-devbase:
ifneq ($(IMAGE_DEV_EXISTS),)
	-docker image rm $(IMAGE_DEV)
	IMAGE_DEV_EXISTS=
endif
	rm -f Dockerfile-devbase

$(RPM_LIBSMI) $(PYDEPS) $(JSBUILDER) $(PHANTOMJS):
	wget http://zenpip.zenoss.eng/packages/$@ -O $@

# Make an RPM so that downstream attempts to override packages for this image will trigger
# version dependency warnings from yum/rpm
rpm/dest/$(RPM_DEPS):
	make -C rpm rpm VERSION=$(VERSION) NAME=$(ZDEPS_NAME) ITERATION=$(ITERATION) PLATFORM=$(PLATFORM) RPM=$(RPM_DEPS)

Dockerfile: Dockerfile.in versions.mk
	@sed \
		-e 's/%BASE_VERSION%/$(BASE_VERSION)/g' \
		-e 's/%RPM_DEPS%/$(RPM_DEPS)/g' \
		-e 's/%RPM_LIBSMI%/$(RPM_LIBSMI)/g' \
		-e 's/%PYDEPS%/$(PYDEPS)/g' \
		-e 's/%JSBUILDER%/$(JSBUILDER)/g' \
		-e 's/%PHANTOMJS%/$(PHANTOMJS)/g' \
		$< > $@

Dockerfile-devbase: Dockerfile-devbase.in versions.mk
	sed -e 's/%VERSION%/$(VERSION)/g' $< > $@

build-deps: rpm/dest/$(RPM_DEPS)

build: build-image build-dev-image

# Build the zenoss-centos-base image
build-image: $(RPM_LIBSMI) $(PYDEPS) $(JSBUILDER) $(PHANTOMJS) 
build-image: rpm/dest/$(RPM_DEPS) Dockerfile
	@echo Building zenoss-centos-base image...
	@docker build -f Dockerfile -t $(IMAGE) .

# Build the zendev version of the zenoss-centos-base image
build-dev-image: build-image Dockerfile-devbase
	@echo Building zendev zenoss-centos-base image...
	@docker build -f Dockerfile-devbase -t $(IMAGE_DEV) .

push:
	docker push $(IMAGE)
	docker push $(IMAGE_DEV)

# Generate a make failure if the VERSION string contains "-<some letters>"
verifyVersion:
	@./verifyVersion.sh $(VERSION)

# Generate a make failure if the image(s) already exist
verifyImage:
	@./verifyImage.sh $(IMAGE) $(VERSION)

# Do not release if the image version is invalid
# This target is intended for use when trying to build/publish images from the master branch
release: verifyVersion verifyImage clean build push
