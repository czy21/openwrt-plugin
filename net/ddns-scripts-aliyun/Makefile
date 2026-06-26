#
# Copyright (C) 2006-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=ddns-scripts-aliyun
PKG_VERSION:=1.0.0
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk

define Package/ddns-scripts-aliyun
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Extension for aliyun.com
  MAINTAINER:=Bruce CHEN <a805899926@gmail.com>
  SUBMENU:=IP Addresses and Names
  PKGARCH:=all
endef

define Package/ddns-scripts-aliyun/description
  Dynamic DNS Client scripts extension for aliyun.com
endef

define Build/Compile
endef

define Package/ddns-scripts-aliyun/install
	$(INSTALL_DIR) $(1)/usr/lib/ddns
	$(INSTALL_BIN) ./files/update_aliyun_com.sh $(1)/usr/lib/ddns/

	$(INSTALL_DIR) $(1)/usr/share/ddns/custom
	$(INSTALL_DATA) ./files/aliyun.com.json $(1)/usr/share/ddns/custom/
endef

$(eval $(call BuildPackage,ddns-scripts-aliyun))