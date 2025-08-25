#
# Copyright (C) 2010-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=openvpn-auth
PKG_VERSION:=1.0.0
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk

define Package/openvpn-auth
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+python3
  TITLE:=Open source VPN solution Auth
  MAINTAINER:=Bruce CHEN <a805899926@gmail.com>
  SUBMENU:=VPN
  PKGARCH:=all
endef

define Package/openvpn-auth/description
  Open source VPN solution Auth Module
endef

define Build/Compile
endef

define Package/openvpn-auth/install
	$(INSTALL_DIR) $(1)/etc/openvpn
	$(INSTALL_BIN) ./files/auth.sh $(1)/etc/openvpn/
	$(INSTALL_BIN) ./files/auth.py $(1)/etc/openvpn/
endef

$(eval $(call BuildPackage,openvpn-auth))
