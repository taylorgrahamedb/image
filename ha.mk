BUILDER=buildah
BUILDER_CONFIG=config
BUILDER_ARGS=bud
NOCACHE_ARG=
BUILD_FLAG=build-arg

# import config.
# You can change the default configd with `make cnf="config_special.env" build`
cnf ?= config.env
include $(cnf)
export $(shell sed 's/=.*//' $(cnf))

# HELP
# This will output the help me again for each task
# thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help build_container push-contain ser

help: ## This helpsasf me s.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

ubiv12: POSTGRESQL_VERSION=12
ubiv12: ubi

ubiv11: POSTGRESQL_VERSION=11
ubiv11: ubi

ubiv10: POSTGRESQL_VERSION=10
ubiv10: ubi

ubi: EXT=ubi
ubi: OS=ubi7/ubi
ubi: OS_VERSION=latest
ubi: TAG=ubi7
ubi: release-as release-pg

ubitools: EXT=ubi
ubitools: OS=latest
ubitools: OS_VERSION=latest
ubitools: OS_NAME=ubi7/ubi
ubitools: TAG=ubi7
ubitools: release-stolon release-actions release-exporter

ociv12: POSTGRESQL_VERSION=12
ociv12: oci

ociv11: POSTGRESQL_VERSION=11
ociv11: oci

ociv10: POSTGRESQL_VERSION=10
ociv10: oci

oci: EXT=oci
oci: OS=centos
oci: TAG=centos7
oci: OS_VERSION=centos7
oci: release-as release-pg

ocitools: EXT=oci
ocitools: OS=centos7
ocitools: TAG=centos7
ocitools: OS_NAME=centos
ocitools: OS_VERSION=centos7
ocitools: release-stolon release-actions release-exporter


release-stolon: build-stolon push-stolon

release-actions: build-actions push-actions

release-exporter: build-exporter push-exporter

release-pg: DISTRO=pg
release-pg: build_container_pg push-container_pg
	@echo 'Built EDB Standard Edition v$(POSTGRESQL_VERSION) for image type $(EXT) for $(OS):$(OS_VERSION)'

release-as: DISTRO=as
release-as: build_container_as push-container_as
	@echo 'Built EDB Advanced Server v$(POSTGRESQL_VERSION) for image type $(EXT) for $(OS):$(OS_VERSION)'


build_container_as build_container_pg:
			$(BUILDER) $(BUILDER_ARGS) \
			--build-arg EXT=$(EXT) \
			--build-arg TAG=$(TAG) \
			--build-arg EDB_STOLON=edb-stolon \
			--build-arg POSTGRESQL_VERSION=$(POSTGRESQL_VERSION) \
			--build-arg DOCKER_REPO=$(DOCKER_REPO) \
			--build-arg DISTRO=$(DISTRO) \
			-t edb-$(DISTRO)-keeper-v$(POSTGRESQL_VERSION).$(EXT) \
			-f ha/Dockerfile-keeper .
			$(BUILDER) tag edb-$(DISTRO)-keeper-v$(POSTGRESQL_VERSION).$(EXT)  $(DOCKER_REPO)/edb-$(DISTRO)-keeper-$(TAG).$(EXT):v$(POSTGRESQL_VERSION)

push-container_as push-container_pg:
			$(BUILDER) push -f v2s2 $(DOCKER_REPO)/edb-$(DISTRO)-keeper-$(TAG).$(EXT):v$(POSTGRESQL_VERSION)

build-stolon: builder
			$(BUILDER) $(BUILDER_ARGS) \
			--build-arg EXT=$(EXT) \
			--build-arg TAG=$(TAG) \
			--build-arg OS_NAME=$(OS_NAME) \
			--build-arg OS_VERSION=$(OS) \
			-t edb-stolon-v1.$(EXT) \
			-f ha/Dockerfile-stolon .
			$(BUILDER) tag edb-stolon-v1.$(EXT) $(DOCKER_REPO)/edb-stolon.$(EXT):v1
			$(BUILDER) tag edb-stolon-v1.$(EXT) $(DOCKER_REPO)/edb-stolon.$(EXT):latest

push-stolon:
			$(BUILDER) push -f v2s2 $(DOCKER_REPO)/edb-stolon.$(EXT):v1
			$(BUILDER) push -f v2s2 $(DOCKER_REPO)/edb-stolon.$(EXT):latest

build-actions: builder
			$(BUILDER) $(BUILDER_ARGS) \
			--build-arg EXT=$(EXT) \
			--build-arg TAG=$(TAG) \
			--build-arg OS_NAME=$(OS_NAME) \
			--build-arg OS_VERSION=$(OS) \
			-t dbtaskrunner-v1.$(EXT) \
			-f actions/Dockerfile-taskrunner .
			$(BUILDER) tag dbtaskrunner-v1.$(EXT) $(DOCKER_REPO)/dbtaskrunner-v1.$(EXT):v1
			$(BUILDER) tag dbtaskrunner-v1.$(EXT) $(DOCKER_REPO)/dbtaskrunner-v1.$(EXT):latest

push-actions:
			$(BUILDER) push -f v2s2 $(DOCKER_REPO)/dbtaskrunner-v1.$(EXT):v1
			$(BUILDER) push -f v2s2 $(DOCKER_REPO)/dbtaskrunner-v1.$(EXT):latest

build-exporter: builder
			$(BUILDER) $(BUILDER_ARGS) \
			--build-arg EXT=$(EXT) \
			--build-arg TAG=$(TAG) \
			--build-arg OS_NAME=$(OS_NAME) \
			--build-arg OS_VERSION=$(OS) \
			-t pgx_exporter-v1.$(EXT) \
			-f exporter/Dockerfile-exporter .
			$(BUILDER) tag pgx_exporter-v1.$(EXT) $(DOCKER_REPO)/pgx_exporter-v1.$(EXT):v1
			$(BUILDER) tag pgx_exporter-v1.$(EXT) $(DOCKER_REPO)/pgx_exporter-v1.$(EXT):latest

push-exporter:
			$(BUILDER) push -f v2s2 $(DOCKER_REPO)/pgx_exporter-v1.$(EXT):v1
			$(BUILDER) push -f v2s2 $(DOCKER_REPO)/pgx_exporter-v1.$(EXT):latest

builder:
			$(BUILDER) $(BUILDER_ARGS) \
			--build-arg STOLON_REPO=$(STOLON_REPO) \
			--build-arg ACTION_REPO=$(ACTION_REPO) \
			--build-arg PGXX_REPO=$(PGXX_REPO) \
			--build-arg OS_NAME=$(OS_NAME) \
			--build-arg OS_VERSION=$(OS) \
			-t edb-stolon-builder.$(EXT) \
			-f ha/Dockerfile-builder .
			$(BUILDER) tag edb-stolon-builder.$(EXT) \
			$(DOCKER_REPO)/edb-stolon-builder.$(EXT):latest
			$(BUILDER) push $(DOCKER_REPO)/edb-stolon-builder.$(EXT):latest


clean:
			podman image rm -a -f

check-makefile:
	cat -e -t -v ha.mk
