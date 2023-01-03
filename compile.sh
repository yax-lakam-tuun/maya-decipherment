#!/bin/bash

document_name="document"
source_path="."
build_path="$source_path/build"

usage() { 
    echo "See '$0' --help" 1>&2; 
}

help() {
    echo "Usage:  $0 [OPTIONS] [TEX_FILE]"
    echo ""
    echo "Compiles tex project into pdf"
    echo ""
    echo "Options:"
    echo "  -b, --build-path           Path to output folder"
    echo "  -d, --document-path        Name of the final document"
    echo "  -m, --main-path            Path to main tex file"
    echo "  -s, --source-path          Path to source folder"
}

# replace long options with short equivalents
args=( )
for arg in "$@"; do
    case "$arg" in
        --help)           args+=( -h ) ;;
        --source-path)    args+=( -s ) ;;
        --build-path)     args+=( -b ) ;;
        --document-name)  args+=( -d ) ;;
        *)                args+=( "$arg" ) ;;
    esac
done
set -- "${args[@]}"

# parse arguments
while getopts "hs:b:d:" OPTION; do
    : "$OPTION" "$OPTARG"
    case $OPTION in
    h)  help; exit 0;;
    s)  source_path="$OPTARG";;
    b)  build_path="$OPTARG";;
    d)  document_name="$OPTARG";;
    *)  usage; exit 1;;
    esac
done
shift $(( OPTIND - 1 ))
if [ -z "$1" ]; then
    main_path="$source_path/main"
else
    main_path="$1"
fi

# print summary
echo "Compiling to $build_path/$document_name.pdf"
echo ""
echo "Settings:"
echo "  Name of document: $document_name"
echo "  Source path:      $source_path"
echo "  Build_path:       $build_path"
echo "  Path to tex file  $main_path"
echo ""
echo "Invoking latexmk..."
echo ""

# go!
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
cd $SCRIPT_DIR
latexmk \
    -synctex=1 \
    -interaction=nonstopmode \
    -file-line-error \
    -pdf \
    -Werror \
    -jobname="$document_name" \
    -outdir="$build_path" \
    "$main_path"
