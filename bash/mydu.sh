#!/bin/bash


function entryusedmemory {
    local blocksamt=$( stat -c %b $1 )
    local blocksize=$( stat -c %B $1 )
    let "usedmemory = blocksamt * blocksize / 1024"
    echo $usedmemory
}

function sizeinfo {
    echo -e "${2}\t${1}"
}

function traverse {
    local entrysize=$( entryusedmemory $1 )
    for file in $( ls $1 -1 ); do
        local childentry="${1}/${file}"
        if [[ ! -L $childentry ]]; then
            if [[ -d $childentry ]]; then
                local childentrysize=$( traverse $childentry )
            else 
                local childentrysize=$( entryusedmemory $childentry )
            fi
        else
            local childentrysize=0
        fi
        let "entrysize = $childentrysize + $entrysize"
    done
    if [[ 0 != $childentrysize && -d $childentry ]]; then
        sizeinfo $childentry $childentrysize >&2
    fi
    echo $entrysize
}

function main {
    IFS=$'\n'
    if [[ -d $1 ]]; then
        local entrysize=$( traverse $1 )
    else
        local entrysize=$( entryusedmemory $1 )
    fi
    sizeinfo $1 $entrysize
    unset IFS
}

main $@

