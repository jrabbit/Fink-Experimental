<?
$title = "Running X11 - Other Stuff";
$cvs_author = 'Author: fingolfin';
$cvs_date = 'Date: 2004/02/29 22:31:42';
$metatags = '<link rel="contents" href="index.php?phpLang=en" title="Running X11 Contents"><link rel="next" href="trouble.php?phpLang=en" title="Troubleshooting XFree86"><link rel="prev" href="xtools.php?phpLang=en" title="Xtools">';

include_once "header.inc";
?>

<h1>Running X11 - 6 Other X11 Possibilities</h1>
    
    
    <h2><a name="vnc">6.1 VNC</a></h2>
      
      <p>
VNC is a network-capable graphics display system similar in design to
X11.
However, it works at a lower level, making implementation easier.
With the Xvnc server and a Mac OS X display client, it is possible to
run X11 applications with Mac OS X.
Jeff Whitaker's <a href="http://www.cdc.noaa.gov/~jsw/macosx_xvnc/">Xvnc page</a> has
more information on that.
</p>
    
    <h2><a name="wiredx">6.2 WiredX</a></h2>
      
      <p>
        <a href="http://www.jcraft.com/wiredx/">WiredX</a> is an X11
server written in Java.
It also supports rootless mode.
An Installer.app package is available at the web site.
</p>
    
    <h2><a name="exodus">6.3 eXodus</a></h2>
      
      <p>
According to the website, <a href="http://www.powerlan-usa.com/exodus/">eXodus 8</a> by Powerlan
USA runs natively on Mac OS X.
It is unknown what codebase it uses and whether/how it supports local
clients.
Because of this, there is no special support for eXodus in Fink.
If you have more info, please throw it our way.
</p>
    
  <p align="right">
Next: <a href="trouble.php?phpLang=en">7 Troubleshooting XFree86</a></p>

<? include_once "footer.inc"; ?>
