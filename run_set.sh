#!/bin/bash

#This is set in the argument of individual test set
TIMES=0
#This should be the same as the program loop size
LOOP_SIZE=$((1000 * 1000))
#These three are color code in terminal
GREEN="\033[1;32m"
BLUE="\033[1;36m"
NC="\033[0;00m"
TEST_SET=./test_set
DEFAULT_NATIVE_ISA_FILE=amdhsa001.isa
#This file would be aotomatically removed after preparing hsail code
HSAIL_TEMP_FILE=./.hsail_tmp_file

main() {
    if [ ! "$1" == "" ]; then
        # Override the directory name
        TEST_SET="$1"
    fi
    mkdir -p output isa
    FILES=$(cd ${TEST_SET} && find ./)
    for file in ${FILES}; do
        path="${TEST_SET}/${file}"
        # Skip parsing directories
        if [ -d ${path} ]; then
            # Here, $file is a directory (name)
            # Create directories in output folder for putting output files in the same order
            mkdir -p ./output/${file};
            mkdir -p ./isa/${file};
            continue;
        fi
        TIMES=0
        clean_redundant_files
        prepare_hsail ${path}
        # Occur some errors while preparing test file
        if [ "$?" != "0" ]; then
            continue;
        fi
        make_n_execute
        # Occur some errors while making/executing
        if [ "$?" != "0" ]; then
            continue;
        fi
        cp ${DEFAULT_NATIVE_ISA_FILE} isa/${file}.isa
        parse_result ./output/${file}
        clean_redundant_files
    done
}

single_test() {
    mkdir -p output isa
    file=$1
    if [ -f $file ]; then
        TIMES=0
        clean_redundant_files
        prepare_hsail ${file}
        # Occur some errors while preparing test file
        if [ "$?" != "0" ]; then
            return -1;
        fi
        make_n_execute
        cp ${DEFAULT_NATIVE_ISA_FILE} isa/$(basename ${file}).isa
        parse_result ./output/$(basename ${file})
        clean_redundant_files
    else
        echo "Could not locate file $1"
    fi
}

prepare_hsail() {
    echo "preparing hsail for ${1}";
    #Get arguments from files
    TIMES="$(grep "TIMES" ${1} | awk '{print $2}')"
    if [ "${TIMES}" == "" ]; then 
        echo "Missing argument TIMES in the test set - ${1}. Skipped";
        return -1;
    fi;
    #Get the line number of TAG in file
    LINE=$(grep -n "TAG_REPLACEMENT" sample_hsail | awk '{print $1}')
    #Remove redundant :
    LINE=$(echo ${LINE} | sed -e "s/://g")

    [[ -f ${HSAIL_TEMP_FILE} ]] && rm ${HSAIL_TEMP_FILE}
    for (( i=0; i<$((${TIMES})); i++ ));
    do
        cat ${1} >> ${HSAIL_TEMP_FILE}
    done

    sed ''${LINE}'r '${HSAIL_TEMP_FILE}'' sample_hsail > vector_copy.hsail
    [[ -f ${HSAIL_TEMP_FILE} ]] && rm ${HSAIL_TEMP_FILE}

    return 0;
}

make_n_execute() {
    echo "Make and execute"
    make dump -s
    if [ "$?" != "0" ]; then
        echo "Fail to build. Skipped"
        return -1;
    fi
}

parse_result() {
    T=$(cat ./result.log | awk '{print $3}')
    #This result is in nano seconds
    T=$(echo "scale=3; 1000 * 1000 * (${T}-194.3) / ${TIMES} / ${LOOP_SIZE}" | bc)
    #Add 0 to the start of the string if 0 is missing
    if [[ ${T:0:1} == "." ]] ; then T="0${T}"; fi
    echo "${T} ns" > ${1}.out
    echo -e "${GREEN}$(basename ${1})${NC} takes ${BLUE}${T} ns${NC}"
}

clean_redundant_files() {
    if [ -f result.log ]; then rm result.log; fi
}

if [ "$1" == "" ] || [ -d "$1" ]; then
    main "$1"
else
    single_test $1
fi

