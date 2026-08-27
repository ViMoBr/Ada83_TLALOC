#!/bin/bash

echo "          -----------------------"
echo "            COMPILE TARGET_CODE"
echo "          -----------------------"

./a83.sh ./ ../src/target_code/target_code.adb W
./a83.sh ./ ../src/target_code/target_code-lex.adb W
./a83.sh ./ ../src/target_code/target_code-symbols.adb W
./a83.sh ./ ../src/target_code/target_code-ir.adb W
./a83.sh ./ ../src/target_code/target_code-passes.adb W
./a83.sh ./ ../src/target_code/target_code-emits.adb W
./a83.sh ./ ../src/target_code/target_code-emits-x86_64_target.adb W
./a83.sh ./ ../src/target_code/target_code-emits-arm64_target.adb W
./a83.sh ./ ../src/target_code/target_code-emits-riscv64_target.adb W

./a83.sh ./ ../src/target_code/target_code.adb B

echo -e "\n"
echo "          -----------------------"
echo "            ASSEMBLE TARGET_CODE"
echo "          -----------------------"

cd ./ADA__LIB
./fasmg -p20 ./TARGET_CODE.fas ./TARGET_CODE
chmod u+x ./TARGET_CODE
./TARGET_CODE

./fasmg ./TC_TEST4.FAS ./TC_REF4
./fasmg ./TC_ARM04.FAS ./TC_ARM_REF4

./fasmg ./TC_TEST5.FAS ./TC_REF5
./fasmg ./TC_ARM05.FAS ./TC_ARM_REF5

./fasmg ./TC_TEST6.FAS ./TC_REF6
./fasmg ./TC_ARM06.FAS ./TC_ARM_REF6

./fasmg ./TC_TEST7.FAS ./TC_REF7
./fasmg ./TC_ARM07.FAS ./TC_ARM_REF7

./fasmg ./TC_TEST8.FAS ./TC_REF8
#ARM08 neant

./fasmg ./TC_TEST9.FAS ./TC_REF9
./fasmg ./TC_ARM09.FAS ./TC_ARM_REF9

./fasmg ./TC_TEST10.FAS ./TC_REF10
./fasmg ./TC_TEST11.FAS ./TC_REF11
./fasmg ./TC_TEST12.FAS ./TC_REF12
#PAS DE 13
./fasmg ./TC_TEST14.FAS ./TC_REF14
#PAS DE 15
./fasmg ./TC_TEST16.FAS ./TC_REF16
./fasmg ./TC_ARM16.FAS ./TC_ARM_REF16

./fasmg ./TC_TEST17.FAS ./TC_REF17

./fasmg ./TC_TEST21.FAS ./TC_REF21
./fasmg ./TC_ARM21.FAS ./TC_ARM_REF21

./fasmg ./TC_TEST23.FAS ./TC_REF23
./fasmg ./TC_TEST24.FAS ./TC_REF24
./fasmg ./TC_TEST25.FAS ./TC_REF25

chmod u+x ./TC_TEST4.BIN
chmod u+x ./TC_ARM04.BIN

chmod u+x ./TC_TEST5.BIN
chmod u+x ./TC_ARM05.BIN

chmod u+x ./TC_TEST6.BIN
chmod u+x ./TC_ARM06.BIN

chmod u+x ./TC_TEST7.BIN
chmod u+x ./TC_ARM07.BIN

chmod u+x ./TC_TEST8.BIN
#ARM08 neant

chmod u+x ./TC_TEST9.BIN
chmod u+x ./TC_ARM09.BIN

chmod u+x ./TC_TEST10.BIN
chmod u+x ./TC_TEST11.BIN
chmod u+x ./TC_TEST12.BIN
chmod u+x ./TC_TEST14.BIN

chmod u+x ./TC_TEST16.BIN
chmod u+x ./TC_ARM16.BIN

chmod u+x ./TC_TEST17.BIN

chmod u+x ./TC_TEST21.BIN
chmod u+x ./TC_ARM21.BIN

chmod u+x ./TC_TEST23.BIN
chmod u+x ./TC_TEST24.BIN
chmod u+x ./TC_TEST25.BIN

chmod u+x ./TC_REF4
chmod u+x ./TC_ARM_REF4

chmod u+x ./TC_REF5
chmod u+x ./TC_ARM_REF5

chmod u+x ./TC_REF6
chmod u+x ./TC_ARM_REF6

chmod u+x ./TC_REF7
chmod u+x ./TC_ARM_REF7

chmod u+x ./TC_REF8
#ARM8 neant

chmod u+x ./TC_REF9
chmod u+x ./TC_ARM_REF9

chmod u+x ./TC_REF10
chmod u+x ./TC_REF11
chmod u+x ./TC_REF12
chmod u+x ./TC_REF14

chmod u+x ./TC_REF16
chmod u+x ./TC_ARM_REF16

chmod u+x ./TC_REF17

chmod u+x ./TC_REF21
chmod u+x ./TC_ARM_REF21

chmod u+x ./TC_REF23
chmod u+x ./TC_REF24
chmod u+x ./TC_REF25


echo -e "\n"
echo "          -----------------------"
echo "            COMPARE REFx TESTx"
echo "          -----------------------"

if cmp -s ./TC_REF4 ./TC_TEST4.BIN ; then
  echo " TC_REF4 = TC_TEST4.BIN"
fi
if cmp -s ./TC_ARM_REF4 ./TC_ARM04.BIN ; then
  echo " TC_ARM_REF4 = TC_ARM04.BIN"
fi

if cmp -s ./TC_REF5 ./TC_TEST5.BIN ; then
  echo " TC_REF5 = TC_TEST5.BIN"
fi
if cmp -s ./TC_ARM_REF5 ./TC_ARM05.BIN ; then
  echo " TC_ARM_REF5 = TC_ARM05.BIN"
fi

if cmp -s ./TC_REF6 ./TC_TEST6.BIN ; then
  echo " TC_REF6 = TC_TEST6.BIN"
fi
if cmp -s ./TC_ARM_REF6 ./TC_ARM06.BIN ; then
  echo " TC_ARM_REF6 = TC_ARM06.BIN"
fi

if cmp -s ./TC_REF7 ./TC_TEST7.BIN ; then
  echo " TC_REF7 = TC_TEST7.BIN"
fi
if cmp -s ./TC_ARM_REF7 ./TC_ARM07.BIN ; then
  echo " TC_ARM_REF7 = TC_ARM07.BIN"
fi

if cmp -s ./TC_REF8 ./TC_TEST8.BIN ; then
  echo " TC_REF8 = TC_TEST8.BIN"
fi

if cmp -s ./TC_REF9 ./TC_TEST9.BIN ; then
  echo " TC_REF9 = TC_TEST9.BIN"
fi
if cmp -s ./TC_ARM_REF9 ./TC_ARM09.BIN ; then
  echo " TC_ARM_REF9 = TC_ARM09.BIN"
fi

if cmp -s ./TC_REF10 ./TC_TEST10.BIN ; then
  echo " TC_REF10 = TC_TEST10.BIN"
fi
if cmp -s ./TC_REF11 ./TC_TEST11.BIN ; then
  echo " TC_REF11 = TC_TEST11.BIN"
fi
if cmp -s ./TC_REF12 ./TC_TEST12.BIN ; then
  echo " TC_REF12 = TC_TEST12.BIN"
fi
if cmp -s ./TC_REF14 ./TC_TEST14.BIN ; then
  echo " TC_REF14 = TC_TEST14.BIN"
fi
if cmp -s ./TC_REF16 ./TC_TEST16.BIN ; then
  echo " TC_REF16 = TC_TEST16.BIN"
fi
if cmp -s ./TC_ARM_REF16 ./TC_ARM16.BIN ; then
  echo " TC_ARM_REF16 = TC_ARM16.BIN"
fi

if cmp -s ./TC_REF17 ./TC_TEST17.BIN ; then
  echo " TC_REF17 = TC_TEST17.BIN"
fi

if cmp -s ./TC_REF21 ./TC_TEST21.BIN ; then
  echo " TC_REF21 = TC_TEST21.BIN"
fi
if cmp -s ./TC_ARM_REF21 ./TC_ARM21.BIN ; then
  echo " TC_ARM_REF21 = TC_ARM21.BIN"
fi

if cmp -s ./TC_REF23 ./TC_TEST23.BIN ; then
  echo " TC_REF23 = TC_TEST23.BIN"
fi
if cmp -s ./TC_REF24 ./TC_TEST24.BIN ; then
  echo " TC_REF24 = TC_TEST24.BIN"
fi
if cmp -s ./TC_REF25 ./TC_TEST25.BIN ; then
  echo " TC_REF25 = TC_TEST25.BIN"
fi

echo -e "\n"
echo "          -----------------------"
echo "            EXEC REFx TESTx"
echo "          -----------------------"

echo -e "REF4\n"
./TC_REF4
echo -e "TEST4\n"
./TC_TEST4.BIN
# exécuter sur Orange Pi 3B ARM
#echo -e "ARM_REF4\n"
#./TC_ARM_REF4
#echo -e "ARM04\n"
#./TC_ARM04.BIN

echo -e "REF5\n"
./TC_REF5
echo -e "TEST5\n"
./TC_TEST5.BIN
# exécuter sur Orange Pi 3B ARM
#echo -e "ARM_REF5\n"
#./TC_ARM_REF5
#echo -e "ARM05\n"
#./TC_ARM05.BIN

echo -e "REF6\n"
./TC_REF6
echo -e "TEST6\n"
./TC_TEST6.BIN
# exécuter sur Orange Pi 3B ARM
#echo -e "ARM_REF6\n"
#./TC_ARM_REF6
#echo -e "ARM06\n"
#./TC_ARM06.BIN

echo -e "REF7\n"
./TC_REF7
echo -e "TEST7\n"
./TC_TEST7.BIN
# exécuter sur Orange Pi 3B ARM
#echo -e "ARM_REF7\n"
#./TC_ARM_REF7
#echo -e "ARM07\n"
#./TC_ARM07.BIN

echo -e "REF8"
./TC_REF8
echo -e "TEST8\n"
./TC_TEST8.BIN

echo -e "REF9"
./TC_REF9
echo -e "TEST9\n"
./TC_TEST9.BIN
# exécuter sur Orange Pi 3B ARM
#echo -e "ARM_REF9\n"
#./TC_ARM_REF9
#echo -e "ARM09\n"
#./TC_ARM09.BIN

echo -e "REF10"
./TC_REF10
echo -e "TEST10\n"
./TC_TEST10.BIN

echo -e "REF11"
./TC_REF11
echo -e "TEST11\n"
./TC_TEST11.BIN

echo -e "REF12"
./TC_REF12
echo -e "TEST12\n"
./TC_TEST12.BIN

echo -e "REF14"
./TC_REF14
echo -e "TEST14\n"
./TC_TEST14.BIN

echo -e "REF16"
./TC_REF16
echo -e "TEST16\n"
./TC_TEST16.BIN
# exécuter sur Orange Pi 3B ARM
#echo -e "ARM_REF16\n"
#./TC_ARM_REF16
#echo -e "ARM16\n"
#./TC_ARM16.BIN


echo -e "REF17"
./TC_REF17
echo -e "TEST17\n"
./TC_TEST17.BIN

echo -e "REF21"
./TC_REF21
echo -e "TEST21\n"
./TC_TEST21.BIN
# exécuter sur Orange Pi 3B ARM
#echo -e "ARM_REF21\n"
#./TC_ARM_REF21
#echo -e "ARM21\n"
#./TC_ARM21.BIN

echo -e "REF23"
./TC_REF23
echo -e "TEST23\n"
./TC_TEST23.BIN

echo -e "REF24"
./TC_REF24
echo -e "TEST24\n"
./TC_TEST24.BIN

echo -e "REF25"
./TC_REF25
echo -e "TEST25\n"
./TC_TEST25.BIN
