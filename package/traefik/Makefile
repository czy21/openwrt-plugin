# SPDX-License-Identifier: MIT

include $(TOPDIR)/rules.mk

PKG_NAME:=traefik
PKG_VERSION:=3.4.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/traefik/traefik/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=a15979c1593ba2d09e4210d698f6fc82bb1cbe9f856180ba7671d6d2b45cf5ba

PKG_LICENSE=MIT
PKG_LICENSE_FILES:=LICENSE.md
PKG_MAINTAINER:=Bruce Chen <a805899926@gmail.com>

PKG_BUILD_DEPENDS:=golang/host node/host node-yarn/host
PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=no-mips16

TRAEFIK_BUILD_CODENAME:=chaource
TRAEFIK_BUILD_DATE:=$(shell date -d @$(SOURCE_DATE_EPOCH) +%FT%TZ%z)

GO_PKG:=github.com/traefik/traefik/v3
GO_PKG_LDFLAGS:=-w -s
GO_PKG_LDFLAGS_X:=$(GO_PKG)/pkg/version.Version=$(PKG_VERSION) \
		$(GO_PKG)/pkg/version.Codename=$(TRAEFIK_BUILD_CODENAME) \
		$(GO_PKG)/pkg/version.BuildDate=$(TRAEFIK_BUILD_DATE)

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/golang/golang-package.mk

define Package/traefik
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Traefik web server
  URL:=https://github.com/traefik/traefik
  DEPENDS:=@(aarch64||arm||i386||i686||riscv64||x86_64) +ca-bundle
endef

define Package/traefik/conffiles
/etc/traefik/
endef

define Package/traefik/description
  Traefik is a modern HTTP reverse proxy and load balancer made to deploy microservices with ease.
endef

define Build/Compile
	( \
		pushd $(PKG_BUILD_DIR) ; \
		yarn --cwd $(PKG_BUILD_DIR)/webui install ; \
		yarn --cwd $(PKG_BUILD_DIR)/webui build ; \
		popd ; \
		$(call GoPackage/Build/Compile) ; \
	)
endef

define Package/traefik/install
	$(call GoPackage/Package/Install/Bin,$(1))
	$(INSTALL_DIR) $(1)/etc/traefik
endef

$(eval $(call GoBinPackage,traefik))
$(eval $(call BuildPackage,traefik))
