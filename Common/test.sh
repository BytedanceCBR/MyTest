filelist=`find . -name '*.m'`
for file in $filelist
do
    cp $file /new_projects/bytedance/tmp/ 
done

