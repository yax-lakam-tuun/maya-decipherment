#!/bin/bash

usage() { 
    echo "See '$0' --help" 1>&2; 
}

help() {
    echo "Usage:  $0 [OPTIONS] [TEX_FILE]"
    echo ""
    echo "Compiles tex project into pdf"
    echo ""
    echo "TEX_FILE: Path to main tex file."
    echo "          Must be relative to source path if specified."
    echo "          If source path is not specified, tex file must be relative to $0"
    echo ""
    echo "Options:"
    echo "  -b, --build-path           Path to output folder"
    echo "  -d, --document-name        Name of the final document"
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
    main_path="main"
else
    main_path="$1"
fi

# define final settings
if [ -z "$document_name" ]; then
    document_name="$(basename $main_path .tex)"
fi

if [ -z "$source_path" ]; then
    repo_root=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
    source_path="$repo_root"
fi

outdir_path=$build_path
if [ -z "$build_path" ]; then
    main_root="$(dirname $main_path)"
    build_path="$source_path/$main_root/build"
    outdir_path="build"
fi

# print summary
echo "Compiling to $build_path/$document_name.pdf"
echo ""
echo "Settings:"
echo "  Name of document: $document_name"
echo "  Source path:      $source_path"
echo "  Build_path:       $build_path"
echo "  Tex file:         $main_path"
echo ""
echo "Invoking latexmk..."
echo ""

# go !
cd "$source_path"
latexmk \
    -cd \
    -synctex=1 \
    -interaction=nonstopmode \
    -file-line-error \
    -pdf \
    -Werror \
    -jobname="$document_name" \
    -outdir="$outdir_path" \
    "$main_path"
