#!/bin/bash

rm -rf tmp
mkdir tmp

#abstract是php关键字，临时替换成tt_abstract
sed -i '' 's/abstract/tt_abstract/' ../*.proto

sed -i '' 's/^package.*//' ../*.proto

echo -e "\033[32m start parsing proto files to php files \033[0m"
php parsePbToPhp.php .. $PWD/tmp
mv ../pb_proto_common.php tmp
mv ../pb_proto_enum_type.php tmp
rm -rf output
mkdir output

echo -e "\033[32 parsing php files to FRApiModel.{h,m} \033[0m"
php parsePhpToOc.php tmp output

#tt_abstract替换回abstract
sed -i '' 's/tt_abstract/abstract/' ../*.proto
sed -i '' 's/tt_abstract/abstract/' ./output/*

mv -f output/*.h ../../Classes/
mv -f output/*.m ../../Classes/

rm -rf tmp
rm -rf output

