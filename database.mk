BUILDER=buildah
BUILDER_CONFIG=config
BUILDER_ARGS=bud
NOCACHE_ARG=
BUILD_FLAG=build-arg

# import config.
# You can change the default config with `make cnf="config_special.env" build`
cnf ?= config.env
include $(cnf)
export $(shell sed 's/=.*//' $(cnf))

# HELP
# This will output the help for each task
# thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help

help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

ubiv12: EXT=ubi
ubiv12: OS=ubi7/ubi
ubiv12: OS_VERSION=latest
ubiv12: TAG=ubi7
ubiv12: POSTGRESQL_VERSION=12
ubiv12: release-as release-pg

ubiv11: EXT=ubi
ubiv11: OS=ubi7/ubi
ubiv11: TAG=ubi7
ubiv11: OS_VERSION=latest
ubiv11: POSTGRESQL_VERSION=11
ubiv11: release-as release-pg

ubiv10: EXT=ubi
ubiv10: OS=ubi7/ubi
ubiv10: TAG=ubi7
ubiv10: OS_VERSION=latest
ubiv10: POSTGRESQL_VERSION=10
ubiv10: release-as release-pg

ociv12: EXT=oci
ociv12: OS=centos
ociv12: TAG=centos7
ociv12: OS_VERSION=centos7
ociv12: POSTGRESQL_VERSION=12
ociv12: release-as release-pg

ociv11: EXT=oci
ociv11: OS=centos
ociv11: TAG=centos7
ociv11: OS_VERSION=centos7
ociv11: POSTGRESQL_VERSION=11
ociv11: release-as release-pg

ociv10: EXT=oci
ociv10: OS=centos
ociv10: TAG=centos7
ociv10: OS_VERSION=centos7
ociv10: POSTGRESQL_VERSION=10
ociv10: release-as release-pg


release-pg: build-pg push-pg
	@echo 'Built EDB Standard Edition v$(POSTGRESQL_VERSION) for image type $(EXT) for $(OS):$(OS_VERSION)'

build-pg:
			$(BUILDER) $(BUILDER_ARGS) \
			--build-arg OS=$(OS) \
			--build-arg TAG=$(OS_VERSION) \
			--build-arg POSTGRESQL_VERSION=$(POSTGRESQL_VERSION) \
			--build-arg EDB_REPO_RPM_URL=$(EDB_REPO_RPM_URL) \
			--build-arg EDB_REPO=edbas$(POSTGRESQL_VERSION) \
			--build-arg EPAS_PACKAGE=edb-pg$(POSTGRESQL_VERSION) \
			-t edb-pgv$(POSTGRESQL_VERSION)-$(TAG).$(EXT) \
			-f database/Dockerfile-edb-pg .
			$(BUILDER) tag edb-pgv$(POSTGRESQL_VERSION)-$(TAG).$(EXT) \
			$(DOCKER_REPO)/edb-pgv$(POSTGRESQL_VERSION)-$(TAG).$(EXT):latest \
			$(DOCKER_REPO)/edb-pg-$(TAG).$(EXT):v$(POSTGRESQL_VERSION)

push-pg:
			$(BUILDER) push -f v2s2 $(DOCKER_REPO)/edb-pg-$(TAG).$(EXT):v$(POSTGRESQL_VERSION)

release-as: build-as push-as
	@echo 'Built EDB Advanced Server v$(POSTGRESQL_VERSION) for image type $(EXT) for $(OS):$(OS_VERSION)'

build-as:
			$(BUILDER) $(BUILDER_ARGS) \
			--build-arg OS=$(OS) \
			--build-arg TAG=$(OS_VERSION) \
			--build-arg POSTGRESQL_VERSION=$(POSTGRESQL_VERSION) \
			--build-arg EDB_REPO_RPM_URL=$(EDB_REPO_RPM_URL) \
			--build-arg EDB_REPO=edbas$(POSTGRESQL_VERSION) \
			--build-arg EDB_YUMUSERNAME=$(EDB_YUMUSERNAME) \
			--build-arg EDB_YUMPASSWORD=$(EDB_YUMPASSWORD) \
			--build-arg EPAS_PACKAGE=edb-as$(POSTGRESQL_VERSION) \
			--build-arg EPAS_VERSION=$(POSTGRESQL_VERSION) \
			-t edb-asv$(POSTGRESQL_VERSION)-$(TAG).${EXT} \
			-f database/Dockerfile-edb-as .
			$(BUILDER) tag edb-asv$(POSTGRESQL_VERSION)-$(TAG).${EXT} \
			$(DOCKER_REPO)/edb-asv$(POSTGRESQL_VERSION)-$(TAG).${EXT}:latest \
			$(DOCKER_REPO)/edb-as-$(TAG).${EXT}:v$(POSTGRESQL_VERSION)

push-as:
			$(BUILDER) push -f v2s2 $(DOCKER_REPO)/edb-as-$(TAG).${EXT}:v$(POSTGRESQL_VERSION)


clean:
			@echo "Remove force all images."
			$(BUILDER) rm --all

check-makefile:
	cat -e -t -v oci.mk
