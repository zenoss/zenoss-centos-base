IMAGENAME  = centos-base
VERSION   ?= 1.0.1
TAG = zenoss/$(IMAGENAME):$(VERSION)

.PHONY: build build-base build-java push clean

build: build-base build-java

build-base:
	@echo Building base image
	@if [ -z "$$(docker images zenoss/$(IMAGENAME) | awk '{print $$2}' | grep -e '^$(VERSION)$$')" ]; then  \
		export IMG=$$(docker build -q -t foo . 2>/dev/null | awk '/Successfully built/{print $$NF}'); \
		export CONTAINER=$$(docker run -d $$IMG echo); \
		docker export $${CONTAINER} | docker import - $(TAG); \
	 fi


build-java: build-base
	@echo Building java image
	@docker build -f Dockerfile.java -t zenoss/$(IMAGENAME):$(VERSION)-java .

push:
	docker push $(TAG)
	docker push $(TAG)-java

clean:
	docker rmi $(TAG) $(TAG)-java