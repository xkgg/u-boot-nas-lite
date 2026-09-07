#!/usr/bin/env bash

# Keep the legacy NAS Lite U-Boot buildable with GCC 13 and newer.
function post_config_uboot_target__nas_lite_gcc13_compat() {
	[[ "${BOARD}" == "nas-lite" ]] || return 0

	local gcc_major_version
	gcc_major_version=$("${UBOOT_COMPILER}gcc" -dumpversion | cut -d. -f1)

	if [[ "${gcc_major_version}" -ge 13 ]]; then
		display_alert "${BOARD}" "Adding GCC 13 compatibility flags for legacy U-Boot" "info"
		uboot_cflags_array+=(
			"-Wno-error=enum-int-mismatch"
			"-Wno-error=address"
		)
	fi
}
