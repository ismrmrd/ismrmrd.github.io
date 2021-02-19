#!/bin/bash

set -e

# Settings
sourceRepo="https://github.com/ismrmrd/ismrmrd.git"
SCRIPT=`realpath $0`
SCRIPTPATH=`dirname $SCRIPT`

usage() {
    echo "update_api_docs.sh  --source-repo <repository>"
}


# Parse command line arguments
while [ "$1" != "" ]; do
    case $1 in
        -r | --repo | --source-repo)                shift
                                                    sourceRepo=$1
                                                    ;;
        -h | --help )                               usage
                                                    exit
                                                    ;;
        * )                                         usage
                                                    exit 1
    esac
    shift
done

rm -rf ismrmrd
git clone $sourceRepo
cd ismrmrd

ISMRMRD_VERSION_MAJOR=$(grep -E -o 'ISMRMRD_VERSION_MAJOR [0-9]+' CMakeLists.txt | grep -E -o '[0-9]+')
ISMRMRD_VERSION_MINOR=$(grep -E -o 'ISMRMRD_VERSION_MINOR [0-9]+' CMakeLists.txt | grep -E -o '[0-9]+')
ISMRMRD_VERSION_PATCH=$(grep -E -o 'ISMRMRD_VERSION_PATCH [0-9]+' CMakeLists.txt | grep -E -o '[0-9]+')
ISMRMRD_VERSION_STRING="${ISMRMRD_VERSION_MAJOR}.${ISMRMRD_VERSION_MINOR}.${ISMRMRD_VERSION_PATCH}"
ISMRMRD_SHA1=$(git rev-parse HEAD)

echo "Detected version of ISMRMRD  :  $ISMRMRD_VERSION_STRING"
echo "Detected SHA1 hash of ISMRMRD:  $ISMRMRD_SHA1"

# Let's see if we need to do anything
docsfolder="${SCRIPTPATH}/../apidocs/${ISMRMRD_VERSION_STRING}"
if [ -d "$docsfolder" ] && [ -f "$docsfolder/ismrmrd-hash" ]; then
    if [ "$(cat $docsfolder/ismrmrd-hash)" == "$ISMRMRD_SHA1" ]; then
        echo "Documentation already exists for this version. Nothing to do."
        exit 0
    fi
fi

echo "Documentation not up to date for this version. Will update..."

# Make the docsfolder and clean it out
mkdir -p $docsfolder
rm -rf $docsfolder/*

#Install dependencies if needed
sudo apt-get -y install doxygen git-core graphviz libhdf5-serial-dev

mkdir -p build
cd build
cmake ../
cmake --build . --target doc
cp -r doc/html/api/* $docsfolder/

# Update index.html (if needed)
${SCRIPTPATH}/update-index-html.sh apidocs/${ISMRMRD_VERSION_STRING}

# Tag it with the latest SHA1
echo $ISMRMRD_SHA1 >> $docsfolder/ismrmrd-hash