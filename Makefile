VERSION_FILE := VERSION
VERSION := $(shell cat $(VERSION_FILE))
WORKDIR := .build
UNAME := $(shell uname)
MT_VERSION := v0.7.0

default: dockerfiles docker push

dockerfiles:
	@mkdir -p $(WORKDIR)
	@cat Dockerfile.template | sed -e 's/{{VERSION}}/$(VERSION)/g' -e 's/{{ARCH}}/amd64/g' -e 's;^FROM;FROM alpine:3.6;' > $(WORKDIR)/Dockerfile.amd64
	@cat Dockerfile.template | sed -e 's/{{VERSION}}/$(VERSION)/g' -e 's/{{ARCH}}/arm/g' -e 's;^FROM;FROM multiarch/alpine:armhf-v3.6;' > $(WORKDIR)/Dockerfile.arm
	@cat Dockerfile.template | sed -e 's/{{VERSION}}/$(VERSION)/g' -e 's/{{ARCH}}/arm64/g' -e 's;^FROM;FROM multiarch/alpine:arm64-v3.6;' > $(WORKDIR)/Dockerfile.arm64
	@cat manifest.yml | sed -e 's/{{VERSION}}/$(VERSION)/g' -e 's/VERSION/$(VERSION)/g' > $(WORKDIR)/manifest.yml 

docker: dockerfiles
	docker run --rm --privileged multiarch/qemu-user-static:register --reset
	docker build --no-cache -t thenatureofsoftware/consul-amd64:$(VERSION) -f $(WORKDIR)/Dockerfile.amd64 .
	docker build --no-cache -t thenatureofsoftware/consul-arm:$(VERSION) -f $(WORKDIR)/Dockerfile.arm .
	docker build --no-cache -t thenatureofsoftware/consul-arm64:$(VERSION) -f $(WORKDIR)/Dockerfile.arm64 .
	docker tag thenatureofsoftware/consul-amd64:$(VERSION) thenatureofsoftware/consul-amd64:latest
	docker tag thenatureofsoftware/consul-arm:$(VERSION) thenatureofsoftware/consul-arm:latest
	docker tag thenatureofsoftware/consul-arm64:$(VERSION) thenatureofsoftware/consul-arm64:latest

push: docker manifest-tool
	docker push thenatureofsoftware/consul-arm:$(VERSION)
	docker push thenatureofsoftware/consul-arm64:$(VERSION)
	docker push thenatureofsoftware/consul-amd64:$(VERSION)
	@$(WORKDIR)/manifest-tool --username $(DOCKER_USER) --password $(DOCKER_PASS) push from-spec $(WORKDIR)/manifest.yml

manifest-tool: manifest-tool-url
ifeq ("$(wildcard $(WORKDIR)/manifest-tool)","")
	@mkdir -p $(WORKDIR)
	@wget -q -O $(WORKDIR)/manifest-tool $(MT_URL)
	@chmod +x $(WORKDIR)/manifest-tool
endif
	@cat manifest.yml | sed -e 's/VERSION/$(VERSION)/g' > $(WORKDIR)/manifest.yml

manifest-tool-url:
ifeq ($(UNAME), Darwin)
	@echo "downloading manifest-tool for OSX ..."
MT_URL="https://github.com/estesp/manifest-tool/releases/download/$(MT_VERSION)/manifest-tool-darwin-amd64"
else
	@echo "downloading manifest-tool for Linux ..."
MT_URL="https://github.com/estesp/manifest-tool/releases/download/$(MT_VERSION)/manifest-tool-linux-amd64"
endif

