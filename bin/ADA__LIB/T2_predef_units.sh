#!/bin/bash
rm -f ./ADA__LIB/*.DCL
rm -f ./ADA__LIB/*.BDY
rm -f ./ADA__LIB/*.SUB
rm -f ./ADA__LIB/*.FINC

./T2 ./ ../_standrd.ads W
./T2 ./ ../system.ads W
./T2 ./ ../machine_code.ads W
./T2 ./ ../calendar.ads W
./T2 ./ ../io_exceptions.ads W
./T2 ./ ../text_io.ads W
./T2 ./ ../direct_io.ads W
./T2 ./ ../sequential_io.ads W
./T2 ./ ../unchecked_conversion.ads W
./T2 ./ ../unchecked_deallocation.ads W

./T2 ./ ../_standrd.adb W
./T2 ./ ../calendar.adb W
./T2 ./ ../text_io.adb W
./T2 ./ ../direct_io.adb W
./T2 ./ ../sequential_io.adb W
#./a83.sh ./ unchecked_conversion.adb W		intrinsèque expander ne pas compiler !
#./a83.sh ./ unchecked_deallocation.adb W	A VOIR
