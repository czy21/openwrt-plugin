# SPDX-License-Identifier: GPL-3.0-only
#
# Copyright (C) 2021 ImmortalWrt.org

include $(TOPDIR)/rules.mk

PKG_NAME:=dnsproxy
PKG_VERSION:=0.76.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/AdguardTeam/dnsproxy/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=e11c0b67aa8784a9d1e8baf2724fe438dfe06a12f928eba8f1530b7aeb47f7db

PKG_MAINTAINER:=Tianling Shen <cnsztl@immortalwrt.org>
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=no-mips16

GO_PKG:=github.com/AdguardTeam/dnsproxy
GO_PKG_LDFLAGS_X:=$(GO_PKG)/internal/version.version=v$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/golang/golang-package.mk

define Package/dnsproxy
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=IP Addresses and Names
  TITLE:=Simple DNS proxy with DoH, DoT, DoQ and DNSCrypt support
  URL:=https://github.com/AdguardTeam/dnsproxy
  DEPENDS:=$(GO_ARCH_DEPENDS) +ca-bundle
  
endef

define Package/dnsproxy/description
  A simple DNS proxy server that supports all existing DNS protocols including
  DNS-over-TLS, DNS-over-HTTPS, DNSCrypt, and DNS-over-QUIC.Moreover, it can
  work as a DNS-over-HTTPS, DNS-over-TLS or DNS-over-QUIC server.
endef




define Package/dnsproxy/install 
	$(call GoPackage/Package/Install/Bin,$(1)) 

	$(INSTALL_DIR) $(1)/etc/dnsproxy 

	$(INSTALL_DIR) $(1)/etc/init.d 
	$(INSTALL_BIN) ./files/dnsproxy.init $(1)/etc/init.d/dnsproxy 

	$(INSTALL_DIR) $(1)/etc/config 
	$(INSTALL_DATA) ./files/dnsproxy.config $(1)/etc/config/dnsproxy 
endef 

define Package/dnsproxy/conffiles
/etc/dnsproxy/
/etc/config/dnsproxy
endef

$(eval $(call GoBinPackage,dnsproxy))
$(eval $(call BuildPackage,dnsproxy))
