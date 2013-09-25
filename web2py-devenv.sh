#!/usr/bin/env bash

# Create a new Web2py development environment with:
# - custom welcome app
# - custom .gitignore for Vagrant
#
# Planned to be used inside a recently created virtualenv.
#
# by @viniciusban

# internal
basedir="$PWD"

# default options
gitignore_from="https://gist.github.com/6665812.git"
scaffold_from=""
scaffold_app_dir="_tmp/web2py/applications/welcome"

# --------------------------------------------------
# parse options.
# --------------------------------------------------

while [[ -n "$1" ]]; do
    case $1 in

        -i | --gitignore )
          shift
          gitignore_from=$1
          ;;

        -s | --scaffold )
          shift
          scaffold_from=$1
          ;;

        -h | --help )

          echo "Usage: `basename ${0}` [--options]"
          echo "Create a new web2py environment inside current dir."
          echo ""
          echo "You can use a custom scaffolding application of your own,"
          echo "or you can lay on default Web2py welcome application."
          echo ""
          echo "You can use a default .gitignore file created to work with"
          echo "Vagrant or you can use your own, too."
          echo ""
          echo "Your custom scaffolding app or your custom .gitignore file"
          echo "can be copied from your own machine, or from a remote git repo."
          echo ""
          echo "Options:"
          echo "  -h, --help"
          echo "     this help."
          echo ""
          echo "  -i, --gitignore {dirname, filename, git repository url}"
          echo "     Get .gitignore file from here."
          echo "     dirname: must end with slash and have a .gitignore file inside"
          echo "     filename: can be any filename, but will be copied as .gitignore"
          echo "     git repo url: must start with http or https"
          echo ""
          echo "  -s, --scaffold {stable, test, targz/zip filename, git repository url}"
          echo "     where to get your scaffold application from?"
          echo "     stable: get welcome app from latest Web2py stable version"
          echo "     test: get welcome app from latest Web2py test version"
          echo "     targz/zip filename: get welcome app from this archive"
          echo "     git repo url: must start with http or https"
          echo ""
          echo "Examples"
          echo ""
          echo "Create a new project with web2py stable welcome app and default .gitignore"
          echo "\$ $(basename ${0}) -s stable"
          echo ""
          echo "Create a project with a scaffolding app in a git repo and a .gitignore in your computer"
          echo "\$ $(basename ${0}) -s http://github.com/my_user/my_scaffolding_app_repo -i /home/user/me/my_gitignore"
          exit
          ;;

        * )
          break
          ;;

    esac
    shift
done


if [ -z "$scaffold_from" ]; then
    echo "Invalid source for scaffolding application"
    echo "Type $(basename ${0}) -h for help"
    exit 1
fi


echo -e "\nSo, let's create a brand new Web2py environment to work with Vagrant.\n"

mkdir _tmp

## get scaffolding application from indicated source.

if [ "$scaffold_from" == "stable" ]; then
    echo "Downloading scaffolding application from latest Web2py stable version..."
    cd _tmp
    wget http://web2py.com/examples/static/web2py_src.zip
    unzip web2py_src.zip >/dev/null
    echo -e "OK\n"
elif [ "$scaffold_from" == "test" ]; then
    echo "Downloading scaffolding application from Web2py test version..."
    cd _tmp
    wget http://web2py.com/examples/static/nightly/web2py_src.zip
    unzip web2py_src.zip >/dev/null
    echo -e "OK\n"
elif [[ "$scaffold_from" =~ ^http[s]? ]]; then
    echo "Downloading scaffolding application from ${scaffold_from}..."
    mkdir --parent ${scaffold_app_dir}
    git clone $scaffold_from ${scaffold_app_dir} > /dev/null 2>&1
    echo -e "OK\n"
else
    if [ ! -e "$scaffold_from" ]; then
        echo "$scaffold_from file not found"
        rm -rf _tmp
        exit 1;
    fi

    mkdir --parent ${scaffold_app_dir}
    if [ -d $scaffold_from ]; then
        echo "Copying your custom scaffolding application from ${scaffold_from}..."
        cp --recursive ${scaffold_from}/* $scaffold_app_dir
    else
        echo "Unpacking your custom scaffolding application from ${scaffold_from}..."
        cd ${scaffold_app_dir}
        cp ${scaffold_from} ./
        if [[ "$scaffold_from" =~ tar.gz$ ]]; then
            tar -xzf $(basename ${scaffold_from}) >/dev/null
        else
            unzip $(basename ${scaffold_from}) >/dev/null
        fi
        rm $(basename ${scaffold_from})
    fi
    echo -e "OK\n"
fi

cd $basedir


echo "Creating directories and README... "
mkdir {src,doc}
echo "Your project name and description goes here." > README
echo "Put your docs in this directory." > doc/README
echo -e "OK\n"


echo "Creating scaffolding app... "
cp --recursive ${scaffold_app_dir}/* src/


echo -e "OK\n"

cd _tmp

# configure .gitignore
if [[ $gitignore_from =~ ^http[s]? ]]; then
    echo "Downloading .gitignore to work with Vagrant... "
    git clone $gitignore_from gitignore > /dev/null 2>&1
    cp gitignore/.gitignore ${basedir}/.gitignore
    echo -e "OK\n"
else
    echo "Using .gitignore from ${gitignore_from}... "
    if [ -f $gitignore_from ]; then
        cp $gitignore_from ${basedir}/.gitignore
    elif [ -d $gitignore_from ]; then
        cp ${gitignore_from}.gitignore ${basedir}/.gitignore
    fi
    echo -e "OK\n"
fi
cd $basedir

echo "Initializing your git repo... "
git init . >/dev/null 2>&1
git add . >/dev/null 2>&1
git commit -m 'Just created the project' >/dev/null 2>&1
echo -e "OK\n"

echo -e "Finished!\n"

cd $basedir
rm -rf _tmp >/dev/null

tree --noreport -d $basedir

echo "Notes:"
echo "1) Your project root dir is a git repo and I already issued the 1st commit for you."
echo "2) Customize .gitignore to meet your needs"
echo "3) Put your documentation in doc/ directory."
echo "4) Web2py will execute your application from src/"
# TODO autoconfigure Vagrantfile to be provisioned by bootstrap.sh
echo -e "\nGo ahead! Start coding for your new project ;-)\n"
