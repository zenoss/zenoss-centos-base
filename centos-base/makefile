IMAGENAME  = centos-base
VERSION   ?= 1.0.1

.PHONY: build
build:
	docker export $$(docker run -d $$(docker build -q -t foo . 2>/dev/null | awk '/Successfully built/{print $$NF}') echo) | docker import - zenoss/$(IMAGENAME):$(VERSION)