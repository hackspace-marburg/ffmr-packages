include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-ffmr-yolokey-client
PKG_VERSION:=1
PKG_RELEASE:=1


PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/gluon-ffmr-yolokey-client
  SECTION:=gluon
  CATEGORY:=Gluon
  TITLE:=Automatic deployment of fastd public keys.
  DEPENDS:=+fastd
endef

define Package/gluon-ffmr-yolokey-client/description
	Automatic deployment of fastd public keys:
	An on-connect script for fastd uploads the public key to the gateway.
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/gluon-ffmr-yolokey-client/install
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,gluon-ffmr-yolokey-client))
