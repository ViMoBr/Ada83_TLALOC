#!/bin/bash
./a83.sh ./ ./_standrd.ads w
./a83.sh ./ ./system.ads w
./a83.sh ./ ./calendar.ads w
./a83.sh ./ ./unchecked_deallocation.ads w
./a83.sh ./ ./unchecked_conversion.ads w
./a83.sh ./ ./io_exceptions.ads w
./a83.sh ./ ./text_io.ads w
./a83.sh ./ ./sequential_io.ads w
./a83.sh ./ ./direct_io.ads w
#--------------------------------------------------
#	API
#--------------------------------------------------
./a83.sh ./ ../../ada-83-kalinda/src/hide/dispatch.ads w
./a83.sh ./ ../../ada-83-kalinda/src/api/types.ads w
./a83.sh ./ ../../ada-83-kalinda/src/api_bdy/types.adb w
./a83.sh ./ ../../ada-83-kalinda/src/api/memory.ads w
./a83.sh ./ ../../ada-83-kalinda/src/api/kalinda.ads w
./a83.sh ./ ../../ada-83-kalinda/src/api_bdy/memory.adb w
./a83.sh ./ ../../ada-83-kalinda/src/api_bdy/kalinda.adb w
./a83.sh ./ ../../ada-83-kalinda/src/api_bdy/kalinda-noyau.adb w
./a83.sh ./ ../../ada-83-kalinda/src/api_bdy/kalinda-devices.adb w
./a83.sh ./ ../../ada-83-kalinda/src/api_bdy/kalinda-draw.adb w
./a83.sh ./ ../../ada-83-kalinda/src/api_bdy/kalinda-fonts.adb w
./a83.sh ./ ../../ada-83-kalinda/src/api_bdy/kalinda-events.adb w
./a83.sh ./ ../../ada-83-kalinda/src/api_bdy/kalinda-tool_utils.adb w
./a83.sh ./ ../../ada-83-kalinda/src/api_bdy/kalinda-windows.adb w
./a83.sh ./ ../../ada-83-kalinda/src/api_bdy/kalinda-controls.adb w
./a83.sh ./ ../../ada-83-kalinda/src/api_bdy/kalinda-menus.adb w
./a83.sh ./ ../../ada-83-kalinda/src/api_bdy/kalinda-text_edit.adb w
./a83.sh ./ ../../ada-83-kalinda/src/api_bdy/kalinda-dialogs.adb w
./a83.sh ./ ../../ada-83-kalinda/src/api_bdy/kalinda-files.adb w
./a83.sh ./ ../../ada-83-kalinda/src/api_bdy/kalinda-resources.adb w
./a83.sh ./ ../../ada-83-kalinda/src/api_bdy/kalinda-disk_init.adb w
#--------------------------------------------------
#	IMPL_SYS
#--------------------------------------------------
./a83.sh ./ ../../ada-83-kalinda/src/x86_64_linux/dependances_machine.ads w
./a83.sh ./ ../../ada-83-kalinda/src/impl_sys/memory-impl.adb w
./a83.sh ./ ../../ada-83-kalinda/src/hide/video_drvr.ads w
./a83.sh ./ ../../ada-83-kalinda/src/hide/globales.ads w
./a83.sh ./ ../../ada-83-kalinda/src/hide/asm_code.ads w
./a83.sh ./ ../../ada-83-kalinda/src/impl_sys/kalinda-noyau-impl.adb w
./a83.sh ./ ../../ada-83-kalinda/src/impl_sys/kalinda-devices-impl.adb w
./a83.sh ./ ../../ada-83-kalinda/src/impl_sys/kalinda-draw-impl.adb w
./a83.sh ./ ../../ada-83-kalinda/src/impl_sys/kalinda-draw-impl-std_procs.adb w
./a83.sh ./ ../../ada-83-kalinda/src/impl_sys/kalinda-draw-impl-draw_rgns.adb w
./a83.sh ./ ../../ada-83-kalinda/src/impl_sys/kalinda-fonts-impl.adb w
./a83.sh ./ ../../ada-83-kalinda/src/hide/mouse_drvr.ads w
./a83.sh ./ ../../ada-83-kalinda/src/impl_sys/kalinda-events-impl.adb w
./a83.sh ./ ../../ada-83-kalinda/src/impl_sys/kalinda-tool_utils-impl.adb w
./a83.sh ./ ../../ada-83-kalinda/src/impl_sys/kalinda-windows-impl.adb w
./a83.sh ./ ../../ada-83-kalinda/src/impl_sys/kalinda-controls-impl.adb w
./a83.sh ./ ../../ada-83-kalinda/src/impl_sys/kalinda-menus-impl.adb w
./a83.sh ./ ../../ada-83-kalinda/src/impl_sys/kalinda-dialogs-impl.adb w

