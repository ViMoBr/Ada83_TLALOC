#!/bin/bash
./a83.sh ./ ./_STANDRD.ADA W
./a83.sh ./ ./SYSTEM.ADA W
./a83.sh ./ ./CALENDAR.ADA W
./a83.sh ./ ./UNCHECKED_DEALLOCATION.ADA W
./a83.sh ./ ./UNCHECKED_CONVERSION.ADA W
./a83.sh ./ ./IO_EXCEPTIONS.ADA W
./a83.sh ./ ./TEXT_IO.ADA W
./a83.sh ./ ./SEQUENTIAL_IO.ADA W
./a83.sh ./ ./DIRECT_IO.ADA W
#--------------------------------------------------
#	API
#--------------------------------------------------
./a83.sh ./ ../../Ada-83-Kalinda/src/hide/dispatch.ads W
./a83.sh ./ ../../Ada-83-Kalinda/src/api/types.ads W
./a83.sh ./ ../../Ada-83-Kalinda/src/api_bdy/types.adb W
./a83.sh ./ ../../Ada-83-Kalinda/src/api/memory.ads W
./a83.sh ./ ../../Ada-83-Kalinda/src/api/kalinda.ads W
./a83.sh ./ ../../Ada-83-Kalinda/src/api_bdy/memory.adb W
./a83.sh ./ ../../Ada-83-Kalinda/src/api_bdy/kalinda.adb W
./a83.sh ./ ../../Ada-83-Kalinda/src/api_bdy/kalinda-noyau.adb W
./a83.sh ./ ../../Ada-83-Kalinda/src/api_bdy/kalinda-devices.adb W
./a83.sh ./ ../../Ada-83-Kalinda/src/api_bdy/kalinda-draw.adb W
./a83.sh ./ ../../Ada-83-Kalinda/src/api_bdy/kalinda-fonts.adb W
./a83.sh ./ ../../Ada-83-Kalinda/src/api_bdy/kalinda-events.adb W
./a83.sh ./ ../../Ada-83-Kalinda/src/api_bdy/kalinda-tool_utils.adb W
./a83.sh ./ ../../Ada-83-Kalinda/src/api_bdy/kalinda-windows.adb W
./a83.sh ./ ../../Ada-83-Kalinda/src/api_bdy/kalinda-controls.adb W
./a83.sh ./ ../../Ada-83-Kalinda/src/api_bdy/kalinda-menus.adb W
./a83.sh ./ ../../Ada-83-Kalinda/src/api_bdy/kalinda-text_edit.adb W
./a83.sh ./ ../../Ada-83-Kalinda/src/api_bdy/kalinda-dialogs.adb W
./a83.sh ./ ../../Ada-83-Kalinda/src/api_bdy/kalinda-files.adb W
./a83.sh ./ ../../Ada-83-Kalinda/src/api_bdy/kalinda-resources.adb W
./a83.sh ./ ../../Ada-83-Kalinda/src/api_bdy/kalinda-disk_init.adb W
#--------------------------------------------------
#	IMPL_SYS
#--------------------------------------------------
./a83.sh ./ ../../Ada-83-Kalinda/src/x86_64_linux/dependances_machine.ads W
./a83.sh ./ ../../Ada-83-Kalinda/src/impl_sys/memory-impl.adb W
./a83.sh ./ ../../Ada-83-Kalinda/src/hide/video_drvr.ads W
./a83.sh ./ ../../Ada-83-Kalinda/src/hide/globales.ads W
./a83.sh ./ ../../Ada-83-Kalinda/src/hide/asm_code.ads W
./a83.sh ./ ../../Ada-83-Kalinda/src/impl_sys/kalinda-noyau-impl.adb W
./a83.sh ./ ../../Ada-83-Kalinda/src/impl_sys/kalinda-devices-impl.adb W
./a83.sh ./ ../../Ada-83-Kalinda/src/impl_sys/kalinda-draw-impl.adb W
./a83.sh ./ ../../Ada-83-Kalinda/src/impl_sys/kalinda-draw-impl-std_procs.adb W
./a83.sh ./ ../../Ada-83-Kalinda/src/impl_sys/kalinda-draw-impl-draw_rgns.adb W
./a83.sh ./ ../../Ada-83-Kalinda/src/impl_sys/kalinda-fonts-impl.adb W
./a83.sh ./ ../../Ada-83-Kalinda/src/hide/mouse_drvr.ads W
./a83.sh ./ ../../Ada-83-Kalinda/src/impl_sys/kalinda-events-impl.adb W
./a83.sh ./ ../../Ada-83-Kalinda/src/impl_sys/kalinda-tool_utils-impl.adb W
./a83.sh ./ ../../Ada-83-Kalinda/src/impl_sys/kalinda-windows-impl.adb W
./a83.sh ./ ../../Ada-83-Kalinda/src/impl_sys/kalinda-controls-impl.adb W
./a83.sh ./ ../../Ada-83-Kalinda/src/impl_sys/kalinda-menus-impl.adb W
#./a83.sh ./ ../../Ada-83-Kalinda/src/impl_sys/kalinda-dialogs-impl.adb W

