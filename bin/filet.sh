echo "COMPILE PREDEF"

./comp_predef_units.sh

echo "          -----------------"
echo "          COMPILE ENUM_TEST"
echo "          -----------------"

./T1 ./ ./enum_test.adb W
./T1 ./ ./enum_test.adb B
cd ./ADA__LIB
./fasmg ENUM_TEST.fas ENUM_TEST
chmod u+x ENUM_TEST
./ENUM_TEST rouge
cd ..

echo "          ----------------------"
echo "          COMPILE DIRECT_IO_TEST"
echo "          ----------------------"
./T1 ./ ./direct_io_test.adb W
./T1 ./ ./direct_io_test.adb B
cd ./ADA__LIB
./fasmg DIRECT_IO_TEST.fas DIRECT_IO_TEST
chmod u+x DIRECT_IO_TEST
./DIRECT_IO_TEST
cd ..

echo "          -------------------"
echo "          COMPILE SEQ_IO_TEST"
echo "          -------------------"
./T1 ./ ./seq_io_test.adb W
./T1 ./ ./seq_io_test.adb B
cd ./ADA__LIB
./fasmg SEQ_IO_TEST.fas SEQ_IO_TEST
chmod u+x SEQ_IO_TEST
./SEQ_IO_TEST
cd ..

echo "          ---------------------"
echo "          COMPILE TEST_CALENDAR"
echo "          ---------------------"
./T1 ./ ./test_calendar.adb W
./T1 ./ ./test_calendar.adb B
cd ./ADA__LIB
./fasmg TEST_CALENDAR.fas TEST_CALENDAR
chmod u+x TEST_CALENDAR
./TEST_CALENDAR
cd ..

echo "          ---------------------------"
echo "          COMPILE FLOAT_TEST"
echo "          ---------------------------"
./T1 ./ ./float_test.adb W
./T1 ./ ./float_test.adb B
cd ./ADA__LIB
./fasmg FLOAT_TEST.fas FLOAT_TEST
chmod u+x FLOAT_TEST
./FLOAT_TEST
cd ..

echo "          ---------------------------"
echo "          COMPILE FLOAT_FIXED_IO_TEST"
echo "          ---------------------------"
./T1 ./ ./float_fixed_io_test.adb W
./T1 ./ ./float_fixed_io_test.adb B
cd ./ADA__LIB
./fasmg FLOAT_FIXED_IO_TEST.fas FLOAT_FIXED_IO_TEST
chmod u+x FLOAT_FIXED_IO_TEST
./FLOAT_FIXED_IO_TEST
cd ..

echo "          -------------------"
echo "          COMPILE ARRAY_TEST1"
echo "          -------------------"
./T1 ./ ./array_test1.ada W
./T1 ./ ./array_test1.ada B
cd ./ADA__LIB
./fasmg ARRAY_TEST1.fas ARRAY_TEST1
chmod u+x ARRAY_TEST1
./ARRAY_TEST1
cd ..

echo "          -------------------"
echo "          COMPILE ARRAY_TEST2"
echo "          -------------------"
./T1 ./ ./array_test2.ada W
./T1 ./ ./array_test2.ada B
cd ./ADA__LIB
./fasmg ARRAY_TEST2.fas ARRAY_TEST2
chmod u+x ARRAY_TEST2
./ARRAY_TEST2
cd ..

echo "          -------------------"
echo "          COMPILE ARRAY_TEST3"
echo "          -------------------"
./T1 ./ ./array_test3.ada W
./T1 ./ ./array_test3.ada B
cd ./ADA__LIB
./fasmg ARRAY_TEST3.fas ARRAY_TEST3
chmod u+x ARRAY_TEST3
./ARRAY_TEST3
cd ..

echo "          --------------------"
echo "          COMPILE REC_ARR_TEST"
echo "          --------------------"
./T1 ./ ./rec_pack.ads W
./T1 ./ ./rec_pack.adb W
./T1 ./ ./rec_arr_test.adb W
./T1 ./ ./rec_arr_test.adb B
cd ./ADA__LIB
./fasmg REC_ARR_TEST.fas REC_ARR_TEST
chmod u+x REC_ARR_TEST
./REC_ARR_TEST
cd ..

echo "          -----------------"
echo "          COMPILE GOTO_TEST"
echo "          -----------------"
./T1 ./ ./goto_test.adb W
./T1 ./ ./goto_test.adb B
cd ./ADA__LIB
./fasmg GOTO_TEST.fas GOTO_TEST
chmod u+x GOTO_TEST
./GOTO_TEST
cd ..

echo "          -----------------"
echo "          COMPILE CONV_DER1"
echo "          -----------------"
./T1 ./ ./conv_der1.adb W
./T1 ./ ./conv_der1.adb B
cd ./ADA__LIB
./fasmg CONV_DER1.fas CONV_DER1
chmod u+x CONV_DER1
./CONV_DER1
cd ..

echo "          -----------------"
echo "          COMPILE CASE_ST1"
echo "          -----------------"
./T1 ./ ./case_st1.adb W
./T1 ./ ./case_st1.adb B
cd ./ADA__LIB
./fasmg CASE_ST1.fas CASE_ST1
chmod u+x CASE_ST1
./CASE_ST1
cd ..

echo "          ---------------"
echo "          COMPILE ARRINI1"
echo "          ---------------"
./T1 ./ ./arrini1.adb W
./T1 ./ ./arrini1.adb B
cd ./ADA__LIB
./fasmg ARRINI1.fas ARRINI1
chmod u+x ARRINI1
./ARRINI1
cd ..

echo "          --------------"
echo "          COMPILE SLICE1"
echo "          --------------"
./T1 ./ ./slice1.adb W
./T1 ./ ./slice1.adb B
cd ./ADA__LIB
./fasmg SLICE1.fas SLICE1
chmod u+x SLICE1
./SLICE1
cd ..

echo "          --------------"
echo "          COMPILE INSTF1"
echo "          --------------"
./T1 ./ ./instf1.adb W
./T1 ./ ./instf1.adb B
cd ./ADA__LIB
./fasmg INSTF1.fas INSTF1
chmod u+x INSTF1
./INSTF1
cd ..

echo "          ----------------"
echo "          COMPILE ADDR_OV1"
echo "          ----------------"
./T1 ./ ./addr_ov1.adb W
./T1 ./ ./addr_ov1.adb B
cd ./ADA__LIB
./fasmg ADDR_OV1.fas ADDR_OV1
chmod u+x ADDR_OV1
./ADDR_OV1
cd ..

echo "          ----------------"
echo "          COMPILE SLCONV1"
echo "          ----------------"
./T1 ./ ./slconv1.adb W
./T1 ./ ./slconv1.adb B
cd ./ADA__LIB
./fasmg SLCONV1.fas SLCONV1
chmod u+x SLCONV1
./SLCONV1
cd ..

echo "          ----------------"
echo "          COMPILE LITAFF1"
echo "          ----------------"
./T1 ./ ./litaff1.adb W
./T1 ./ ./litaff1.adb B
cd ./ADA__LIB
./fasmg LITAFF1.fas LITAFF1
chmod u+x LITAFF1
./LITAFF1
cd ..

echo "          ----------------"
echo "          COMPILE RETPKG1"
echo "          ----------------"
./T1 ./ ./retpkg1.ada W
./T1 ./ ./retpkg1.ada B
cd ./ADA__LIB
./fasmg RETPKG1.fas RETPKG1
chmod u+x RETPKG1
./RETPKG1
cd ..

echo "          -------------------"
echo "          COMPILE AGGSTR_TEST"
echo "          -------------------"
./T1 ./ ./aggstr_test.adb W
./T1 ./ ./aggstr_test.adb B
cd ./ADA__LIB
./fasmg AGGSTR_TEST.fas AGGSTR_TEST
chmod u+x AGGSTR_TEST
./AGGSTR_TEST
cd ..

echo "          ------------------"
echo "          COMPILE OPDEF_TEST"
echo "          ------------------"
./T1 ./ ./opdef_test.adb W
./T1 ./ ./opdef_test.adb B
cd ./ADA__LIB
./fasmg OPDEF_TEST.fas OPDEF_TEST
chmod u+x OPDEF_TEST
./OPDEF_TEST
cd ..

echo "          ------------------"
echo "          COMPILE PACKV_TEST"
echo "          ------------------"
./T1 ./ ./packv_test.adb W
./T1 ./ ./packv_test.adb B
cd ./ADA__LIB
./fasmg PACKV_TEST.fas PACKV_TEST
chmod u+x PACKV_TEST
./PACKV_TEST
cd ..

echo "          ----------------"
echo "          COMPILE OPB_TEST"
echo "          ----------------"
./T1 ./ ./opb_test.adb W
./T1 ./ ./opb_test.adb B
cd ./ADA__LIB
./fasmg OPB_TEST.fas OPB_TEST
chmod u+x OPB_TEST
./OPB_TEST
cd ..

echo "          ------------------------"
echo "          COMPILE GOTO_SELARG_TEST"
echo "          ------------------------"
./T1 ./ ./goto_selarg_test.adb W
./T1 ./ ./goto_selarg_test.adb B
cd ./ADA__LIB
./fasmg GOTO_SELARG_TEST.fas GOTO_SELARG_TEST
chmod u+x GOTO_SELARG_TEST
./GOTO_SELARG_TEST
cd ..

echo "          -------------------"
echo "          COMPILE INDARG_TEST"
echo "          -------------------"
./T1 ./ ./indarg_test.adb W
./T1 ./ ./indarg_test.adb B
cd ./ADA__LIB
./fasmg INDARG_TEST.fas INDARG_TEST
chmod u+x INDARG_TEST
./INDARG_TEST
cd ..

echo "          --------------"
echo "          COMPILE TLALOC"
echo "          --------------"
./comp_T2 A >out.txt


