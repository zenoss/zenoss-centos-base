#
# RPM builder for Zenoss base depenencies
#

include versions.mk

# zenoss-centos-base Docker image
PROJECT   := zenoss
NAME      := zenoss-centos-base
IMAGE     := $(PROJECT)/$(NAME):$(VERSION)
IMAGE_DEV := $(PROJECT)/$(NAME):$(VERSION).devtools

# zenoss-centos-deps RPM
ZDEPS_NAME ?= zenoss-centos-deps
ITERATION  ?= 1
PLATFORM   := x86_64
RPMVERSION := $(subst -,_,$(VERSION))
RPM_DEPS   := $(ZDEPS_NAME)-$(RPMVERSION)-$(ITERATION).$(PLATFORM).rpm

# pydeps
PYDEPS := pydeps-$(PYDEPS_VERSION)-el7-1

# jsbuilder
JSBUILDER := JSBuilder2

# phantomjs
PHANTOMJS := phantomjs-$(PHANTOMJS_VERSION)-linux-x86_64

# libsmi
RPM_LIBSMI := libsmi-$(LIBSMI_VERSION).el7.x86_64.rpm

.PHONY: clean clean-devbase build build-base build-devbase default

default: build

# Clean staged files and produced packages
clean: clean-devbase
	-docker rmi $(IMAGE)
	rm -f Dockerfile zenoss_env_init.sh zenoss_deps_install.sh
	make -C rpm clean

clean-devbase:
	-docker rmi $(IMAGE_DEV)
	rm -f Dockerfile-devbase

$(RPM_LIBSMI):
	wget http://zenpip.zenoss.eng/packages/$(RPM_LIBSMI) -O $@

# Make an RPM so that downstream attempts to override packages for this image will trigger
# version dependency warnings from yum/rpm
rpm/pkgroot/$(RPM_DEPS):
	make -C rpm rpm VERSION=$(VERSION) NAME=$(ZDEPS_NAME) ITERATION=$(ITERATION) PLATFORM=$(PLATFORM) RPM=$(RPM_DEPS)

Dockerfile: Dockerfile.in
	sed \
		-e 's/%BASE_VERSION%/$(BASE_VERSION)/g' \
		-e 's/%RPM_DEPS%/$(RPM_DEPS)/g' \
		-e 's/%RPM_LIBSMI%/$(RPM_LIBSMI)/g' \
		$< > $@

zenoss_env_init.sh: zenoss_env_init.sh.in
	sed \
		-e 's/%RPM_DEPS%/$(RPM_DEPS)/g' \
		-e 's/%RPM_LIBSMI%/$(RPM_LIBSMI)/g' \
		$< > $@

zenoss_deps_install.sh: zenoss_deps_install.sh.in
	sed \
		-e 's/%PYDEPS%/$(PYDEPS)/g' \
		-e 's/%JSBUILDER%/$(JSBUILDER)/g' \
		-e 's/%PHANTOMJS%/$(PHANTOMJS)/g' \
		$< > $@

build: build-base build-devbase

# Make image for building RPM
build-base: rpm/pkgroot/$(RPM_DEPS) $(RPM_LIBSMI) Dockerfile zenoss_env_init.sh zenoss_deps_install.sh
	docker build -f Dockerfile -t $(IMAGE) .

# Make the image for zendev
build-devbase: build-base Dockerfile-devbase
	docker build -f Dockerfile-devbase -t $(IMAGE_DEV) .

Dockerfile-devbase: Dockerfile-devbase.in
	sed -e 's/%VERSION%/$(VERSION)/g' $< >$@

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
