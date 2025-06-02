./a83.sh ./ ./dis_bonjour.adb W
cd ./ADA__LIB
./fasmg DIS_BONJOUR.fas
./DIS_BONJOUR
cd ..
echo "Ok"

./a83.sh ./ ./lis_caractere.adb W
cd ./ADA__LIB
./fasmg LIS_CARACTERE.fas
./LIS_CARACTERE
cd ..
echo "Ok"

./a83.sh ./ ./string_test.adb W
cd ./ADA__LIB
./fasmg STRING_TEST.fas
./STRING_TEST
cd ..
echo "Ok"

./a83.sh ./ ./array_test.adb W
cd ./ADA__LIB
./fasmg ARRAY_TEST.fas
./ARRAY_TEST
cd ..
echo "Ok"

echo "FIN DE TEST"
