#!/bin/bash

build_path=$1
document_name=$2

document_path="$build_path/$document_name.pdf"

if [ ! -f "$document_path" ]; then
    echo "Document not found: $document_path"
    exit 1
fi

echo "All tests passed!"
exit 0