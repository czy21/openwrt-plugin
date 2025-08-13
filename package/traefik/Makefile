# SPDX-License-Identifier: MIT

include $(TOPDIR)/rules.mk

PKG_NAME:=traefik
PKG_VERSION:=3.4.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-v$(PKG_VERSION).src.tar.gz
PKG_SOURCE_URL:=https://github.com/traefik/traefik/releases/download/v$(PKG_VERSION)/
PKG_HASH:=8d971571725057b2e8bdcc2441f9612f75fa3780cff62cfd52fbe3872786ca29

PKG_LICENSE=MIT
PKG_LICENSE_FILES:=LICENSE.md
PKG_MAINTAINER:=Bruce Chen <a805899926@gmail.com>

PKG_BUILD_DEPENDS:=golang/host
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

TAR_CMD=$(HOST_TAR) -C $(1) $(TAR_OPTIONS)

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

define Package/traefik/install
	$(INSTALL_DIR) $(1)/usr/bin/
	$(INSTALL_BIN) $(GO_PKG_BUILD_BIN_DIR)/traefik $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/etc/traefik
	$(INSTALL_DIR) $(1)/etc/traefik/conf.d
	$(INSTALL_CONF) ./files/traefik.yml $(1)/etc/traefik/traefik.yml
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/traefik.init $(1)/etc/init.d/traefik
endef

$(eval $(call GoBinPackage,traefik))
$(eval $(call BuildPackage,traefik))
