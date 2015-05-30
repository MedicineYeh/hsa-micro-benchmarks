#!/bin/bash

#This is set in the argument of individual test set
TIMES=0
#This should be the same as the program loop size
LOOP_SIZE=$((1000 * 10000))
#These three are color code in terminal
GREEN="\033[1;32m"
BLUE="\033[1;36m"
NC="\033[0;00m"

main() {
    mkdir -p output
    FILES=$(ls ./test_set/)
    for file in ${FILES}; do
        TIMES=0
        clean_redundant_files
        prepare_hsail ./test_set/${file}
        # Occur some errors while preparing test file
        if [ "$?" != "0" ]; then
            continue;
        fi
        make_n_execute
        # Occur some errors while preparing test file
        if [ "$?" != "0" ]; then
            continue;
        fi
        parse_result ./output/${file}
        clean_redundant_files
    done
}

single_test() {
    mkdir -p output
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
    sed ''${LINE}'r '${1}'' sample_hsail > vector_copy.hsail
    for (( i=0; i<$((${TIMES}-1)); i++ ));
    do
        sed -i ''${LINE}'r '${1}'' vector_copy.hsail
    done

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
    T=$(echo "scale=3; 1000 * 1000 * ${T} / ${TIMES} / ${LOOP_SIZE}" | bc)
    #Add 0 to the start of the string if 0 is missing
    if [[ ${T:0:1} == "." ]] ; then T="0${T}"; fi
    echo "${T} ns" > ${1}.out
    echo -e "${GREEN}$(basename ${1})${NC} takes ${BLUE}${T} ns${NC}"
}

clean_redundant_files() {
    if [ -f result.log ]; then rm result.log; fi
}

if [ "$1" == "" ]; then
    main
else
    single_test $1
fi

