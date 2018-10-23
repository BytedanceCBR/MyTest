#!/bin/bash

src_root=$1
workspace_path=$2
ld_map_file_path=$3
BASEDIR=$(dirname $0)

if [[ $# < 3 ]]; then
    echo 'not enough Args'
    echo 'usage: sh analyse_and_map.sh project_src_root workspace_name ld_map_file_path'
    exit 2
fi

mkdir "${BASEDIR}/link_map_temp"
python "${BASEDIR}/linkmap.py" "${ld_map_file_path}" >> "${BASEDIR}/link_map_temp/linkmap_analysis.txt"
python "${BASEDIR}/linkmap.py" "${ld_map_file_path}" -g >> "${BASEDIR}/link_map_temp/linkmap_analysis_group.txt"
ruby "${BASEDIR}/get_all_groups.rb" "${src_root}" "${workspace_path}" "${BASEDIR}/link_map_temp/linkmap_analysis.txt" "${BASEDIR}/link_map_temp/linkmap_analysis_group.txt" >> "${BASEDIR}/link_map_temp/reversed_result.txt"
tail -r "${BASEDIR}/link_map_temp/reversed_result.txt"
rm -rf "${BASEDIR}/link_map_temp"