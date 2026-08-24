#!/bin/bash
rm -f ./ADA__LIB/*.DCL
rm -f ./ADA__LIB/*.BDY
rm -f ./ADA__LIB/*.SUB
rm -f ./ADA__LIB/*.FINC

./a83.sh ./ _standrd.ads W
./a83.sh ./ system.ads W
./a83.sh ./ machine_code.ads W
./a83.sh ./ calendar.ads W
./a83.sh ./ io_exceptions.ads W
./a83.sh ./ text_io.ads W
./a83.sh ./ direct_io.ads W
./a83.sh ./ sequential_io.ads W
./a83.sh ./ unchecked_conversion.ads W
./a83.sh ./ unchecked_deallocation.ads W

./a83.sh ./ _standrd.adb W
./a83.sh ./ calendar.adb W
./a83.sh ./ text_io.adb W
./a83.sh ./ direct_io.adb W
./a83.sh ./ sequential_io.adb W
#./a83.sh ./ unchecked_conversion.adb W		intrinsèque expander ne pas compiler !
#./a83.sh ./ unchecked_deallocation.adb W	A VOIR
