# SPDX-License-Identifier: GPL-2.0-only

include $(TOPDIR)/rules.mk

PKG_NAME:=aliyun-cli
PKG_VERSION:=3.0.290
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/aliyun/aliyun-cli.git
PKG_SOURCE_VERSION:=v$(PKG_VERSION)
PKG_MIRROR_HASH:=8074f35cefe15ae85bc20444e653bde9620b2c3272f222a2a2699efdf3cd2bf3

PKG_LICENSE=Apache-2.0
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Bruce Chen <a805899926@gmail.com>

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=no-mips16

GO_PKG:=github.com/aliyun/aliyun-cli/v3
GO_PKG_LDFLAGS_X:=$(GO_PKG)/cli.Version=$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/golang/golang-package.mk

define Package/aliyun-cli
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Alibaba Cloud OpenAPI
  URL:=https://github.com/aliyun/aliyun-cli
  DEPENDS:=$(GO_ARCH_DEPENDS) +ca-bundle
endef

define Package/aliyun-cli/conffiles
/root/.aliyun/config.json
endef

define Package/aliyun-cli/description
  The Alibaba Cloud CLI is a tool to manage and use Alibaba Cloud resources through a command line interface.
endef

define Package/aliyun-cli/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(GO_PKG_BUILD_BIN_DIR)/main $(1)/usr/bin/aliyun
endef

$(eval $(call GoBinPackage,aliyun-cli))
$(eval $(call BuildPackage,aliyun-cli))
