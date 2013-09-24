web2py_devenv
=============

**web2py_devenv** is a tool to help you create a professional [Web2py](http://web2py.com) development environment using Virtualenv or Vagrant.

By default, Web2py gives you a scaffolding application, called Welcome. It's a really good starting point and you can go further with web2py_devenv, using your own custom scaffolding application. All you need is configure it and publish it as a zip file, a git repository or a simple directory in your computer.

You can use your own .gitignore, too. We have a default one, but why worrying about copying it every time you start a new project?

We automate all this configuration process and initialize a git repo for you, with a suggested directory structure.

**Note:** currently, this configuration options are only available in Vagrant version. Virtualenv option are work in progress.

**TODO:**

1. Allow virtualenv script to behave like the vagrant one.
1. Create bootstrap.sh for Vagrant.
