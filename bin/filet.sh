echo "COMPILE PREDEF"

./comp_predef_units.sh

echo "          -----------------"
echo "          COMPILE ENUM_TEST"
echo "          -----------------"

./a83.sh ./ ./enum_test.adb W
./a83.sh ./ ./enum_test.adb B
cd ./ADA__LIB
./fasmg ENUM_TEST.fas ENUM_TEST
chmod u+x ENUM_TEST
./ENUM_TEST rouge
cd ..

echo "          ----------------------"
echo "          COMPILE DIRECT_IO_TEST"
echo "          ----------------------"
./a83.sh ./ ./direct_io_test.adb W
./a83.sh ./ ./direct_io_test.adb B
cd ./ADA__LIB
./fasmg DIRECT_IO_TEST.fas DIRECT_IO_TEST
chmod u+x DIRECT_IO_TEST
./DIRECT_IO_TEST
cd ..

echo "          -------------------"
echo "          COMPILE SEQ_IO_TEST"
echo "          -------------------"
./a83.sh ./ ./seq_io_test.adb W
./a83.sh ./ ./seq_io_test.adb B
cd ./ADA__LIB
./fasmg SEQ_IO_TEST.fas SEQ_IO_TEST
chmod u+x SEQ_IO_TEST
./SEQ_IO_TEST
cd ..

echo "          ---------------------"
echo "          COMPILE TEST_CALENDAR"
echo "          ---------------------"
./a83.sh ./ ./test_calendar.adb W
./a83.sh ./ ./test_calendar.adb B
cd ./ADA__LIB
./fasmg TEST_CALENDAR.fas TEST_CALENDAR
chmod u+x TEST_CALENDAR
./TEST_CALENDAR
cd ..

echo "          ---------------------------"
echo "          COMPILE FLOAT_TEST"
echo "          ---------------------------"
./a83.sh ./ ./float_test.adb W
./a83.sh ./ ./float_test.adb B
cd ./ADA__LIB
./fasmg FLOAT_TEST.fas FLOAT_TEST
chmod u+x FLOAT_TEST
./FLOAT_TEST
cd ..

echo "          ---------------------------"
echo "          COMPILE FLOAT_FIXED_IO_TEST"
echo "          ---------------------------"
./a83.sh ./ ./float_fixed_io_test.adb W
./a83.sh ./ ./float_fixed_io_test.adb B
cd ./ADA__LIB
./fasmg FLOAT_FIXED_IO_TEST.fas FLOAT_FIXED_IO_TEST
chmod u+x FLOAT_FIXED_IO_TEST
./FLOAT_FIXED_IO_TEST
cd ..

echo "          -------------------"
echo "          COMPILE ARRAY_TEST1"
echo "          -------------------"
./a83.sh ./ ./array_test1.ada W
./a83.sh ./ ./array_test1.ada B
cd ./ADA__LIB
./fasmg ARRAY_TEST1.fas ARRAY_TEST1
chmod u+x ARRAY_TEST1
./ARRAY_TEST1
cd ..

echo "          -------------------"
echo "          COMPILE ARRAY_TEST2"
echo "          -------------------"
./a83.sh ./ ./array_test2.ada W
./a83.sh ./ ./array_test2.ada B
cd ./ADA__LIB
./fasmg ARRAY_TEST2.fas ARRAY_TEST2
chmod u+x ARRAY_TEST2
./ARRAY_TEST2
cd ..

echo "          -------------------"
echo "          COMPILE ARRAY_TEST3"
echo "          -------------------"
./a83.sh ./ ./array_test3.ada W
./a83.sh ./ ./array_test3.ada B
cd ./ADA__LIB
./fasmg ARRAY_TEST3.fas ARRAY_TEST3
chmod u+x ARRAY_TEST3
./ARRAY_TEST3
cd ..

echo "          --------------------"
echo "          COMPILE REC_ARR_TEST"
echo "          --------------------"
./a83.sh ./ ./rec_pack.ads W
./a83.sh ./ ./rec_pack.adb W
./a83.sh ./ ./rec_arr_test.adb W
./a83.sh ./ ./rec_arr_test.adb B
cd ./ADA__LIB
./fasmg REC_ARR_TEST.fas REC_ARR_TEST
chmod u+x REC_ARR_TEST
./REC_ARR_TEST
cd ..

echo "          -----------------"
echo "          COMPILE GOTO_TEST"
echo "          -----------------"
./a83.sh ./ ./goto_test.adb W
./a83.sh ./ ./goto_test.adb B
cd ./ADA__LIB
./fasmg GOTO_TEST.fas GOTO_TEST
chmod u+x GOTO_TEST
./GOTO_TEST
cd ..

echo "          -----------------"
echo "          COMPILE CONV_DER1"
echo "          -----------------"
./a83.sh ./ ./conv_der1.adb W
./a83.sh ./ ./conv_der1.adb B
cd ./ADA__LIB
./fasmg CONV_DER1.fas CONV_DER1
chmod u+x CONV_DER1
./CONV_DER1
cd ..

echo "          -----------------"
echo "          COMPILE CASE_ST1"
echo "          -----------------"
./a83.sh ./ ./case_st1.adb W
./a83.sh ./ ./case_st1.adb B
cd ./ADA__LIB
./fasmg CASE_ST1.fas CASE_ST1
chmod u+x CASE_ST1
./CASE_ST1
cd ..

echo "          ---------------"
echo "          COMPILE ARRINI1"
echo "          ---------------"
./a83.sh ./ ./arrini1.adb W
./a83.sh ./ ./arrini1.adb B
cd ./ADA__LIB
./fasmg ARRINI1.fas ARRINI1
chmod u+x ARRINI1
./ARRINI1
cd ..

echo "          --------------"
echo "          COMPILE SLICE1"
echo "          --------------"
./a83.sh ./ ./slice1.adb W
./a83.sh ./ ./slice1.adb B
cd ./ADA__LIB
./fasmg SLICE1.fas SLICE1
chmod u+x SLICE1
./SLICE1
cd ..

echo "          --------------"
echo "          COMPILE INSTF1"
echo "          --------------"
./a83.sh ./ ./instf1.adb W
./a83.sh ./ ./instf1.adb B
cd ./ADA__LIB
./fasmg INSTF1.fas INSTF1
chmod u+x INSTF1
./INSTF1
cd ..

echo "          ----------------"
echo "          COMPILE ADDR_OV1"
echo "          ----------------"
./a83.sh ./ ./addr_ov1.adb W
./a83.sh ./ ./addr_ov1.adb B
cd ./ADA__LIB
./fasmg ADDR_OV1.fas ADDR_OV1
chmod u+x ADDR_OV1
./ADDR_OV1
cd ..

echo "          ----------------"
echo "          COMPILE SLCONV1"
echo "          ----------------"
./a83.sh ./ ./slconv1.adb W
./a83.sh ./ ./slconv1.adb B
cd ./ADA__LIB
./fasmg SLCONV1.fas SLCONV1
chmod u+x SLCONV1
./SLCONV1
cd ..

echo "          ----------------"
echo "          COMPILE LITAFF1"
echo "          ----------------"
./a83.sh ./ ./litaff1.adb W
./a83.sh ./ ./litaff1.adb B
cd ./ADA__LIB
./fasmg LITAFF1.fas LITAFF1
chmod u+x LITAFF1
./LITAFF1
cd ..

echo "          ----------------"
echo "          COMPILE RETPKG1"
echo "          ----------------"
./a83.sh ./ ./retpkg1.ada W
./a83.sh ./ ./retpkg1.ada B
cd ./ADA__LIB
./fasmg RETPKG1.fas RETPKG1
chmod u+x RETPKG1
./RETPKG1
cd ..

echo "          -------------------"
echo "          COMPILE AGGSTR_TEST"
echo "          -------------------"
./a83.sh ./ ./aggstr_test.adb W
./a83.sh ./ ./aggstr_test.adb B
cd ./ADA__LIB
./fasmg AGGSTR_TEST.fas AGGSTR_TEST
chmod u+x AGGSTR_TEST
./AGGSTR_TEST
cd ..

echo "          ------------------"
echo "          COMPILE OPDEF_TEST"
echo "          ------------------"
./a83.sh ./ ./opdef_test.adb W
./a83.sh ./ ./opdef_test.adb B
cd ./ADA__LIB
./fasmg OPDEF_TEST.fas OPDEF_TEST
chmod u+x OPDEF_TEST
./OPDEF_TEST
cd ..

echo "          ------------------"
echo "          COMPILE PACKV_TEST"
echo "          ------------------"
./a83.sh ./ ./packv_test.adb W
./a83.sh ./ ./packv_test.adb B
cd ./ADA__LIB
./fasmg PACKV_TEST.fas PACKV_TEST
chmod u+x PACKV_TEST
./PACKV_TEST
cd ..

echo "          ----------------"
echo "          COMPILE OPB_TEST"
echo "          ----------------"
./a83.sh ./ ./opb_test.adb W
./a83.sh ./ ./opb_test.adb B
cd ./ADA__LIB
./fasmg OPB_TEST.fas OPB_TEST
chmod u+x OPB_TEST
./OPB_TEST
cd ..

echo "          ------------------------"
echo "          COMPILE GOTO_SELARG_TEST"
echo "          ------------------------"
./a83.sh ./ ./goto_selarg_test.adb W
./a83.sh ./ ./goto_selarg_test.adb B
cd ./ADA__LIB
./fasmg GOTO_SELARG_TEST.fas GOTO_SELARG_TEST
chmod u+x GOTO_SELARG_TEST
./GOTO_SELARG_TEST
cd ..

echo "          -------------------"
echo "          COMPILE INDARG_TEST"
echo "          -------------------"
./a83.sh ./ ./indarg_test.adb W
./a83.sh ./ ./indarg_test.adb B
cd ./ADA__LIB
./fasmg INDARG_TEST.fas INDARG_TEST
chmod u+x INDARG_TEST
./INDARG_TEST
cd ..

echo "          --------------"
echo "          COMPILE TLALOC"
echo "          --------------"
./comp_ada_comp.sh A >out.txt


