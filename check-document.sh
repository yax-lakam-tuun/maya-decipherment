#!/bin/bash

document_exists() {
    document_path=$1
    echo -n "Looking for document $document_path....."

    if [ -f "$document_path" ]; then
        echo "OK"
    else
        echo "FAILED"
        echo "       Document not found: $document_path"
        exit 1
    fi

}

build_path=$1
document_name=$2
document_path="$build_path/$document_name.pdf"

document_exists "$document_path"

echo "All tests passed!"
exit 0