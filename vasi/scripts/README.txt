===== MY FINK SCRIPTS =====

* bfink is a wrapper around fink. Usually it does the same thing as fink, except that 'bfink install foo' also adds foo to the debfoster keepers, and 'bfink remove foo' also removes foo from the keepers. Also, after bfink runs fink, it runs rmorphans2.

* rmorphans2 removes all packages that are not required by a keeper. It requires packages expect-pm581 and debfoster. (NB: It's a good idea to edit PREFIX/etc/debfoster.conf, and set "RemoveCmd = apt-get remove", so you don't always lose your ConfFiles.)

* missing_keepers prints any keepers that are not currently installed.

* list_nonessential prints any non-essential packages installed. Some packages are exempted (apt, ccache-default, debfoster), which you can change inside the script.

* flocate is like dlocate, letting you search the contents of packages. But it also can search uninstalled packages, since it indexes the .deb files themselves.

* fink-tree switches between separate installations of fink, for testing purposes. This way all my trees can be in the same prefix, and use the same debs, so I don't have to rebuild things for testing.


===== HOW TO USE =====

Putting them together, here's my fink usage pattern:

Usually, I just do 'bfink install ...', 'bfink update-all', etc. This saves space and makes sure I never have any BuildDependsOnly packages installed (which helps to catch other people's packaging errors). I also have anacron set up to run "flocate --index" daily.

When I'm testing a package "foo" for dependencies, I do this:

fink scanpackages
apt-get remove `list_nonessential`
fink rebuild foo		# Here's where you'll find BuildDepends problems
apt-get remove `list_nonessential`
fink install foo
< test the package's functionality >	# Here's where you'll notice Depends problems
apt-get install `missing_keepers` # Restores the old settings

During the build phase, when there's a missing BuildDepends it usually manifests itself by some sort of "file not found" error. I run 'flocate filename' to find what package needs to be added to BuildDepends to account for that file.


====== OTHER USEFUL SCRIPTS =====

* undmg extracts .dmg files as safely as possible. See the 'extractors' package in fink unstable.

* mydebs find debs by developer. Modify it so it uses your name.

* update-source-dir prunes my source dir to a specified size, keeping only the most recent sources.

* findinfo finds the .info file for a package.

* revdeps finds reverse dependencies for a package. Not heavily tested, and takes a long time to run (~45 seconds).

* debsizes finds the sizes of all installed packages on your system, if you need to save space, use this.

* bot allows nice disassembly of Obj-C programs. Basically a faster, perl version of the 'bot' here http://www.afront.be/lib.html

* rmpkg removes an OS X .pkg file. I've never encountered a problem with this, but I can't guarantee you won't either, so be careful.

