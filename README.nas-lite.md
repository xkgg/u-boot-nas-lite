# U-Boot 2026.07 NAS Lite port

This directory is based on the official U-Boot `v2026.07` release and carries
the RK3568 NAS Lite board support from the source tree in the parent directory.

## Ported board files

- `configs/rk3568-nas-lite_defconfig`
- `arch/arm/dts/rk3568-nas-lite.dts`
- `arch/arm/dts/rk3568-nas-lite-u-boot.dtsi`
- `drivers/mtd/nand/raw/rockchip_nand_v9.c`
- `drivers/mtd/nand/raw/rockchip_nand_spl_v9.c`

The defconfig keeps U-Boot's `TARGET_EVB_RK3568` machine target because the
2026.07 RK3568 board code is shared by the EVB-compatible board family; the
NAS Lite-specific hardware selection is provided by the custom device tree.

The device tree now uses the 2026.07 Linux-upstream RK356x base description and
the current `bootph-*` phase annotations.  The legacy OP-TEE client is kept
disabled because the parent tree documents a boot panic when no compatible
BL32/OP-TEE image is present.

RK3568's `rockchip,rk-nandc` V9 controller is not covered by the generic
2026.07 Rockchip NFC driver, so the board's V9 driver is carried locally and
wired into the 2026.07 NAND Kconfig.  The NAND controller and chip nodes are
also restored in the board device tree.  The default defconfig now enables the
lightweight Raw NAND path in SPL (`CONFIG_SPL_MTD` and
`CONFIG_SPL_NAND_SUPPORT`) while retaining the normal eMMC/SPI boot flow.

The parent tree's optional DG/vendor display adaptation is not included in the
default NAS Lite build because `rk3568-nas-lite.dts` does not reference it.  Its
original files remain available in the parent tree for a separate display
adaptation port.

## Build on a Linux/AArch64 host

Provide the Rockchip RK3568 TPL/BL31 binaries expected by your board, then run:

```bash
export BL31=/path/to/rk3568_bl31.elf
export ROCKCHIP_TPL=/path/to/rk3568_ddr.bin
make rk3568-nas-lite_defconfig
make -j$(nproc)
```

The generated Rockchip image targets the same SPL/FIT boot flow as the parent
NAS Lite tree and includes the migrated RK3568 V9 Raw NAND SPL driver.
SATA/NVMe, USB, Ethernet, MMC, SPI-NOR, SPI-NAND and Android support are
enabled in the new defconfig where those features exist in U-Boot 2026.07.
Fastboot uses the MMC provider, matching the parent NAS Lite configuration;
2026.07 exposes NAND, SPI and block-device providers as mutually exclusive
alternatives.

## Validation note

The source was compiled successfully on the RK3568 build device at
`192.168.100.14` on September 8, 2026 with GCC `aarch64-linux-gnu-gcc`, BL31
`rk3568_bl31_v1.33.elf`, and TPL `rk3568_ddr_1560MHz_v1.13.bin`.  Binman emitted
only the expected optional-OP-TEE warning.  Booting the image on hardware still
requires a serial-console test before flashing.
