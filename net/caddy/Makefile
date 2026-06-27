# SPDX-License-Identifier: GPL-2.0-only

include $(TOPDIR)/rules.mk

PKG_NAME:=caddy
PKG_VERSION:=2.11.4
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/caddyserver/caddy/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=2c3d02078286a6282cdb4d1d8744077788d556659dac0b64d8ed5886a7e5aeb9

PKG_LICENSE=Apache-2.0
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Bruce Chen <a805899926@gmail.com>

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=no-mips16

GO_PKG:=github.com/caddyserver/caddy/v2
GO_PKG_TAGS:=nobadger,nomysql,nopgx
GO_PKG_LDFLAGS:=-w -s
GO_PKG_LDFLAGS_X:=$(GO_PKG).CustomVersion=$(PKG_VERSION)
GO_PKG_EXCLUDES:=caddytest/

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/golang/golang-package.mk

define Package/caddy
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Caddy web server
  URL:=https://github.com/caddyserver/caddy
  DEPENDS:=$(GO_ARCH_DEPENDS) +ca-bundle
endef

define Package/caddy/conffiles
/etc/caddy/
endef

define Package/caddy/description
  Caddy is an extensible server platform that uses TLS by default.
endef

define Package/caddy/install
	$(call GoPackage/Package/Install/Bin,$(1))
	$(INSTALL_DIR) $(1)/etc/caddy
	$(INSTALL_DIR) $(1)/etc/caddy/conf.d
	$(INSTALL_CONF) ./files/Caddyfile $(1)/etc/caddy/Caddyfile
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/caddy.init $(1)/etc/init.d/caddy
endef

$(eval $(call GoBinPackage,caddy))
$(eval $(call BuildPackage,caddy))
