ALL_CONFLICTS=$(ls "${XCASSET_FILES[@]}" | grep 'imageset$' | sort -r | uniq -d)
for CONFLICT in ${ALL_CONFLICTS[@]};do
echo "error: below images use same name !!!"
find . -name ${CONFLICT}
done

if [ ${#ALL_CONFLICTS[@]} -eq 0 ]; then
echo "approved"
else
exit 1
fi
