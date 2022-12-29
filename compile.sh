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

define_main() {
    if [ -z "$1" ]; then
        echo "$source_path/main"
    else
        echo "$1"
    fi
}

replace_long_options() {
    args=( )
    for arg; do
        case "$arg" in
            --help)           args+=( -h ) ;;
            --source-path)    args+=( -s ) ;;
            --build-path)     args+=( -b ) ;;
            --document-name)  args+=( -d ) ;;
            *)                args+=( "$arg" ) ;;
        esac
    done
    echo ${args[*]}
}

parse_arguments() {
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
    main_path=$(define_main $1)
}

args=$(replace_long_options $@)
parse_arguments $args

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
latexmk \
    -synctex=1 \
    -interaction=nonstopmode \
    -file-line-error \
    -pdf \
    -Werror \
    -jobname="$document_name" \
    -outdir="$build_path" \
    "$tex_file"
