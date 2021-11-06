#
# Copyright (C) 2015-2020 The Open GApps Team
# Copyright (C) 2021 TheHitMan7
#
# The BiTGApps scripts are free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# These scripts are distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#

TOPDIR := .
BUILD_SYSTEM := $(TOPDIR)/scripts
BUILD_GAPPS := $(BUILD_SYSTEM)/build_gapps.sh
BUILD_MICROG := $(BUILD_SYSTEM)/build_microg.sh
BUILD_ADDON_V1 := $(BUILD_SYSTEM)/build_addonv1.sh
BUILD_ADDON_V2 := $(BUILD_SYSTEM)/build_addonv2.sh
BUILD_ADDON_V3 := $(BUILD_SYSTEM)/build_addonv3.sh
BUILD_ADDON_V4 := $(BUILD_SYSTEM)/build_addonv4.sh
APIS := 25 26 27 28 29 30 31
PLATFORMS := arm arm64
LOWEST_API_arm := 25
LOWEST_API_arm64 := 25
VARIANTS := assistant bromite calculator calendar chrome contacts deskclock dialer dps gboard gearhead launcher maps markup messages photos soundpicker tts vancedmicrog vancedroot vancednonroot wellbeing

GAPPS := gapps
MICROG := microg
ADDON := addon

BUILDDIR := $(TOPDIR)/build
OUTDIR := $(TOPDIR)/out

define make-gapps
# We first define 'all' so that this is the primary make target
all:: $1

# It will execute the build script with the platform, api as parameter,
# meanwhile ensuring the minimum api for the platform that is selected
$1:
	$(platform = $(firstword $(subst -, ,$1)))
	$(api = $(word 2, $(subst -, ,$1)))
	$(gapps = $(word 3, $(subst -, ,$1)))
	@if [ "$(api)" -ge "$(LOWEST_API_$(platform))" ] ; then\
		$(BUILD_GAPPS) $(platform) $(api) $(gapps) 2>&1;\
	else\
		echo "Illegal combination of Platform and API";\
	fi;\
	exit 0
endef

define make-microg
# We first define 'all' so that this is the primary make target
all:: $1

# It will execute the build script with the platform, api as parameter,
# meanwhile ensuring the minimum api for the platform that is selected
$1:
	$(platform = $(firstword $(subst -, ,$1)))
	$(api = $(word 2, $(subst -, ,$1)))
	$(microg = $(word 3, $(subst -, ,$1)))
	@if [ "$(api)" -ge "$(LOWEST_API_$(platform))" ] ; then\
		$(BUILD_MICROG) $(platform) $(api) $(microg) 2>&1;\
	else\
		echo "Illegal combination of Platform and API";\
	fi;\
	exit 0
endef

define make-addons
# We first define 'all' so that this is the primary make target
all:: $1

# It will execute the build script with the platform as parameter
# API independent
$1:
	$(platform = $(firstword $(subst -, ,$1)))
	$(addon = $(word 2, $(subst -, ,$1)))
	@if [ "$(LOWEST_API_$(platform))" ] ; then\
		$(BUILD_ADDON_V1) $(platform) $(addon) 2>&1;\
	else\
		echo "Illegal Platform";\
	fi;\
	exit 0
endef

define make-variants
# We first define 'all' so that this is the primary make target
all:: $1

# It will execute the build script with the variant as parameter,
# Platform independent
$1:
	$(variant = $(firstword $(subst -, ,$1)))
	@if [ -n "$(variant)" ] ; then\
		$(BUILD_ADDON_V2) $(variant) 2>&1;\
		$(BUILD_ADDON_V3) $(variant) 2>&1;\
		$(BUILD_ADDON_V4) $(variant) 2>&1;\
	else\
		echo "Illegal Variant";\
	fi;\
	exit 0
endef

$(foreach platform,$(PLATFORMS),\
$(foreach api,$(APIS),\
$(foreach gapps,$(GAPPS),\
$(eval $(call make-gapps,$(platform)-$(api)-$(gapps)))\
)))

$(foreach platform,$(PLATFORMS),\
$(foreach api,$(APIS),\
$(foreach microg,$(MICROG),\
$(eval $(call make-microg,$(platform)-$(api)-$(microg)))\
)))

$(foreach platform,$(PLATFORMS),\
$(foreach addon,$(ADDON),\
$(eval $(call make-addons,$(platform)-$(addon)))\
))

$(foreach variant,$(VARIANTS),\
$(eval $(call make-variants,$(variant)))\
)

clean:
	@-rm -fr "$(BUILDDIR)"
	@-rm -fr "$(OUTDIR)"
	@echo 'Build & Output directory removed'

help:
	@echo 'Buildable Packages  : BiTGApps, MicroG'
	@echo 'Buildable Platforms : arm, arm64'
	@echo 'Buildable APIs      : 25, 26, 27, 28, 29, 30, 31'
	@echo 'Buildable Variants  : assistant, bromite, calculator,'
	@echo '                      calendar, chrome, contacts,'
	@echo '                      deskclock, dialer, dps,'
	@echo '                      gboard, gearhead, launcher,'
	@echo '                      maps, markup, messages, photos,'
	@echo '                      soundpicker, tts, vancedmicrog,'
	@echo '                      vancedroot, vancednonroot, wellbeing'
	@echo ''
