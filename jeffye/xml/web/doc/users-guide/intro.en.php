<?
$title = "User's Guide - Introduction";
$cvs_author = 'Author: michga';
$cvs_date = 'Date: 2004/03/10 11:34:52';
$metatags = '<link rel="contents" href="index.php?phpLang=en" title="User\'s Guide Contents"><link rel="next" href="install.php?phpLang=en" title="First Time Installation"><link rel="prev" href="index.php?phpLang=en" title="User\'s Guide Contents">';

include_once "header.inc";
?>

<h1>User's Guide - 1 Introduction</h1>
    
    
    <h2><a name="what">1.1 What is Fink?</a></h2>
      
      <p>
Fink is a distribution of Unix Open Source software for Mac OS X and
Darwin.
It brings a wide range of free command-line and graphical software
developed for Linux and similar operating systems to your Mac.
</p>
    
    <h2><a name="req">1.2 Requirements</a></h2>
      
      <p>
In any case you will need:
</p>
      <ul>
        <li>
          <p>
An installed Mac OS X system, version 10.2 or later, or equivalent
Darwin releases.
Earlier versions of both will <b>not</b> work.
See below for more information about supported systems.
</p>
        </li>
        <li>
          <p>
Internet access.
Both source code and binary packages are downloaded from Internet
download sites.
</p>
        </li>
      </ul>
      <p>
If you intend to use the source distribution (see below), you will
also need:
</p>
      <ul>
        <li>
          <p>
Development tools.
On Mac OS X, install the Developer.pkg package from the Developer
Tools CD.
Note that the tools must match your Mac OS X version.
On Darwin, the tools should be present in the default install.
</p>
          <p>
It's a good idea to have the Developer Tools installed even if you
don't intend to build packages from source.
Some of the programs installed by the package are actually general
purpose command line tools.
Some packages may depend on those to run.
</p>
        </li>
        <li>
          <p>
Patience.
Compiling several big packages takes time.
I'm talking hours or even days here.
</p>
        </li>
      </ul>
    
    <h2><a name="supported-os">1.3 Supported Systems</a></h2>
      
      <p>
        <b>Mac OS X 10.3</b> is the operating system of choice for running
Fink.
All developers run it, and packages are tested on this system.
It is considered "fully supported and tested", although there may
still be stray compile problems with single packages.
</p>
<p><b>Mac OS X 10.2</b> is still supported, though some newer packages may not have 10.2 versions available.</p>
      <p>
        <b>Mac OS X 10.1</b> is still supported to some extent.
You must run Fink 0.4.1 and no later versions.
</p>
      <p>
Darwin 7.0.1 is the Darwin version corresponding to Mac OS X 10.3, and <b>Darwin 6.0.2</b> is the Darwin version corresponding to Mac OS X
10.2.
They should work in general, but are not as well tested as most people
just run Mac OS X proper instead.
You may run into problems with packages that use features specific to
Mac OS X - affected packages include XFree86 and possibly esound.
</p>
    
    <h2><a name="src-vs-bin">1.4 Source vs. Binary</a></h2>
      
      <p>
Software is written ("developed") in human-readable programming
languages; this form is called the "source code".
Before a computer can actually run a program, it must be transformed
into low-level machine code instructions (unreadable by most humans).
That process is called "compiling" and the resulting program is called
"executable" or "binary".
(The process is also referred to as "building", because it usually
involves more steps than just compiling.)
</p>
      <p>
When you buy commercial software you don't get to see the source code,
though - companies treat it as a trade secret.
You only get the ready-to-run executable, which means you have no way
to modify the program or even find out what it actually does when it's
run.
</p>
      <p>
Not so with <a href="http://www.opensource.org/">Open Source</a>
software.
As the name implies, the source code is open for anyone to see and
modify.
In fact, most Open Source software is only distributed as source code
by its authors, and you must compile it on your computer to get a
program that can be run.
</p>
      <p>
Fink lets you choose between the two models.
The "source" distribution will download the original source, adapt it
to Mac OS X and to Fink's policy, and compile it on your computer.
That process is fully automated, but takes some time.
The "binary" distribution on the other hand will download pre-compiled
packages from the Fink site and install those, saving you the time for
compiling.
It is actually possible to mix the two models at will.
The rest of this manual will show you how.
</p>
    
  <p align="right">
Next: <a href="install.php?phpLang=en">2 First Time Installation</a></p>

<? include_once "footer.inc"; ?>
