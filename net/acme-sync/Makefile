#
# Copyright (C) 2010-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=acme-sync
PKG_VERSION:=1.0.0
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk

define Package/acme-sync
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+acme
  TITLE:=Acme Sync Tool
  MAINTAINER:=Bruce CHEN <a805899926@gmail.com>
  PKGARCH:=all
endef

define Package/acme-sync/description
  Acme Sync Tool
endef

define Build/Compile
endef

define Package/acme-sync/install
	$(INSTALL_DIR) $(1)/etc/acme
	$(INSTALL_BIN) ./files/sync.sh $(1)/etc/acme/
	$(INSTALL_BIN) ./files/post.sh $(1)/etc/acme/
endef

$(eval $(call BuildPackage,acme-sync))
