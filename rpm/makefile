#
# RPM builder for Zenoss base depenencies
#

NAME       ?=
VERSION    ?=
PLATFORM   ?=
ITERATION  ?=
RPM        ?=

DEST  = dest

PWD   = $(shell pwd)
UID  ?= $(shell id -u)
GID  ?= $(shell id -g)

FPM_IMAGE_EXISTS = $(shell docker image list --format '{{.Tag}}' zenoss-fpm)

.PHONY: all clean rpm
.SILENT: desc

all: desc

desc:
	echo "Usage: make rpm. $(NAME)-$(VERSION)."

# Clean staged files and produced packages
.PHONY: clean
clean:
	rm -rf $(DEST) Dockerfile

.PHONY: mrclean
mrclean: clean

# Make image for building RPM
.PHONY: image
image: Dockerfile
ifeq ($(FPM_IMAGE_EXISTS),)
	docker build -t zenoss-fpm .
endif

rpm: image $(DEST)/$(RPM)

$(DEST):
	mkdir -p $@

Dockerfile: Dockerfile.in
	@sed -e "s/%GID%/$(GID)/g" -e "s/%UID%/$(UID)/g" $< > $@

$(DEST)/$(RPM): | $(DEST)
$(DEST)/$(RPM): Dockerfile
	docker run \
		-v "$(PWD)/$(DEST):/pkg" \
		-v "$(PWD):/work" \
		-w "/work" \
		-e RPM=$(RPM) \
		-e NAME=$(NAME) \
		-e VERSION=$(VERSION) \
		-e PLATFORM=$(PLATFORM) \
		-e ITERATION=$(ITERATION) \
		-i \
		--rm \
		zenoss-fpm \
		make -f rpm.mk $(DEST)/$(RPM)
