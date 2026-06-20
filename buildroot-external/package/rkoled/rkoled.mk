################################################################################
#
# rkoled
#
################################################################################

RKOLED_VERSION = v0.0.3

RKOLED_SITE = $(call github,solarflows,rkoled,$(RKOLED_VERSION))
# 不设置LICENSE，因为源仓库没有LICENSE文件
# 定义编译命令。Buildroot 使用交叉编译工具链，因此需显式指定 CC。
define RKOLED_BUILD_CMDS
    $(TARGET_MAKE_ENV) $(MAKE) CC="$(TARGET_CC)" CFLAGS="$(TARGET_CFLAGS)" -C $(@D)
endef

# 定义安装命令。
define RKOLED_INSTALL_TARGET_CMDS
    $(INSTALL) -D -m 0755 $(@D)/RTDevInfo $(TARGET_DIR)/usr/bin/RTDevInfo
    $(INSTALL) -D -m 0644 $(BR2_EXTERNAL_HAOS_PATH)/package/rkoled/rkoled.service $(TARGET_DIR)/usr/lib/systemd/system/rkoled.service
endef

# 将 rkoled 注册为一个通用软件包。
$(eval $(generic-package))

