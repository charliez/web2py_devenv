#!/usr/bin/env bash

# Create a new Web2py development environment from source, using a
# custom scaffolding app, not necessarily welcome.w2p.
#
# Planned to be used inside a recently created virtualenv.
#
# by @viniciusban

# ---------- internals (don't touch)
web2py_trunk_filename="web2py-master.zip"
web2py_dirname_from_trunk="web2py-master"
# ---------- end internals

# Your application name is the parameter.
appname=$1

# Directory where web2py_src.zip, _gitignore and your scaffolding app are.
sourcedir="${HOME}/bin/web2py.dir"

# Name of web2py zipped source code.
sourcefile=${web2py_trunk_filename}

# Your scaffolding application. By default, Web2py uses welcome.w2p, but you
# can modify it and use the name you want. But keep it tar gzipped.
scaffoldingapp="my_welcome.tar.gz"

if [ -z "${appname}" ]; then
    echo "Tell me the name of your application, please."
    echo "Usage: $(basename $0) <appname>"
    exit 1
fi

echo -e "\nSo, let's create a brand new Web2py environment to ${appname}.\n"

echo -e "Installing local py.test..."
pip install --no-index ../_downloads/py-1.4.13.tar.gz
pip install --no-index ../_downloads/pytest-2.3.5.tar.gz

echo -e "Installing local ipython..."
pip install --no-index ../_downloads/ipython-0.13.2.tar.gz

echo -n "Installing Web2py from source... "
if [ -d "web2py" ]; then
    echo "FAILED"
    echo "A previous Web2py installation already exists."
    exit 1;
fi

unzip ${sourcedir}/${sourcefile} 1>/dev/null
if [ "${web2py_trunk_filename}" == "${sourcefile}" ]; then
    # fix web2py dir name when installing from trunk
    mv -T ${web2py_dirname_from_trunk} web2py 2>/dev/null
fi
echo "OK."


echo -n "Creating project tree for ${appname}... "
mkdir --parent ${appname}/src/web2py/${appname}
mkdir --parent ${appname}/doc
echo "${appname}" > ${appname}/README
touch ${appname}/doc/DUMMY
echo "OK"


echo -n "Creating scaffolding app ${appname}... "

cd ${appname}/src/web2py/${appname}
cp ${sourcedir}/${scaffoldingapp} ./
tar -xzf ${scaffoldingapp}
rm ${scaffoldingapp}
cd - 1>/dev/null
ln -s ${PWD}/${appname}/src/web2py/${appname} web2py/applications/${appname}
echo "OK"

tree --noreport -d ${appname}

echo -n "Initializing your git repo... "
git init ${appname}/ 1>/dev/null
cp ${sourcedir}/_gitignore ${appname}/.gitignore
cd ${appname}/ 1>/dev/null
git add . 1>/dev/null
git commit -m 'Just created the project' 1>/dev/null
cd - 1>/dev/null
echo "OK"

echo "Notes:"
echo "1) Your project root dir is ${appname}/ and it's a git repo. I already issued your 1st commit for you"
echo "2) Customize ${appname}/.gitignore to your needs"
echo "3) Put your documentation in ${appname}/doc/"
echo "4) Web2py will execute your application from ${appname}/src/web2py/${appname}/"
echo -e "\nGo ahead! Start coding for ${appname} ;-)\n"
