<?
$title = "i18n - Files";
$cvs_author = 'Author: alexkhansen';
$cvs_date = 'Date: 2004/03/05 15:41:34';

$metatags = '<link rel="contents" href="index.php" title="i18n Contents"><link rel="next" href="procedure.php" title="Procedure for Updating Documents"><link rel="prev" href="intro.php" title="Introduction">';

include "header.inc";
?>

<h1>i18n - 2 The Documentation Files</h1>
    
    
    
      <p>The puropse of this chapter is to introduce you to the Fink documentation files, how to access them, and how to send changes to the Fink website and activate them.	</p>
    
    <h2><a name="requirements">2.1 Requirements</a></h2>
      
      <p>To work on the documentation files as a member of a translation team, you need:</p>
      <ul>
        <li>A CVS client to allow you to download the documentation from the Fink web tree.</li>
        <li>A UTF-8 compatible text editor--a dedicated XML editor is a plus, since many of the files on the Fink website are generated from XML files.</li>
        <li>A checkout of the Fink web tree, as per the <a href="#acquiring">instructions</a> below.</li>
        <li>Working knowledge of Fink is also beneficial.</li>
      </ul>
      <p><b>Note:</b>"team member" is defined as someone who translates but is not ultimately responsible for uploading files to the Fink website.</p>
      <p>Team leaders must meet the above requirements, but should also have:</p>
      <ul>
        <li>A SourceForge account (free registration).</li>
        <li>Commit access to the Fink documentation tree.  To get this, send a message to the fink-18n mailing list, letting them know your SourceForge username. One of the i18n Core Team will make the arrangements for you to have CVS access to the documentation section.</li>
      </ul>
      <p><b>Note:  </b>a "team leader" is here defined as a person who is responsible for actually uploading changed files to the Fink website and activating those changes.</p>
    
    <h2><a name="setting-up">2.2 Environment Settings</a></h2>
      
      <p>To save yourself some typing, you will want to set up your environment to save you some typing later on.  The ensuing discussion assumes that you are using the builtin command-line tools on OSX or another Unix-like OS.</p>
      <ol>
        <li>Modify your login files to add the CVS_RSH environment variable.<ol>
            <li>If you are using <code>bash</code> or <code>zsh</code> add the following:<pre>export CVS_RSH=ssh</pre>to your <code>.profile</code>.</li>
            <li>If you're using <code>tcsh</code> add the following:<pre>setenv CVS_RSH ssh</pre>to your <code>.cshrc</code>.
          <p>This will tell <code>cvs</code> to use ssh to gain access to the files.  This is required.</p></li>
          </ol></li>
        <li>Create a file called .cvsrc in your home directory with the following line in it:<pre>cvs -z3</pre>By doing this, CVS will use level 3 compression by default (it's a good thing!)</li>
      </ol>
      <p>After these operations make sure to start a new terminal window to make sure your CVS_RSH environment is set.</p>
    
    <h2><a name="acquiring">2.3 Acquiring Files to Work on.</a></h2>
      
      <p>
For now, you must check out the xml branch of the web site:</p>
      <ol>
        <li>
Open a terminal</li>
        <li>Create a directory somewhere to contain the Fink web branch, e.g:
<pre>mkdir -p ~/Documents/Fink-i18n</pre></li>
        <li>
Move to that directory:
<pre>cd ~/Documents/Fink-i18n</pre></li>
        <li><b>For non-leader team members (or leaders awaiting access):  </b>Login to cvs.sourceforge.net anonymously:
<ol>
            <li>              <pre>cvs -d:pserver:anonymous@cvs.sourceforge.net:/cvsroot/fink login</pre>            </li>
            <li>
Push the enter key (no password, anonymous as default)</li>
            <li>
Check out the xml module:
<pre>cvs -d:pserver:anonymous@cvs.sourceforge.net:/cvsroot/fink co xml</pre>         </li>
          </ol><b>Team leaders:  </b>Check out using your username:<ol>
            <li>You don't have to do the login step above, but can go right to<pre>cvs -d:ext:yourusername@cvs.sourceforge.net:/cvsroot/fink co xml</pre>where <b>yourusername</b> is of course your SourceForge username.</li>
            <li>In this case you should enter your SourceForge passport at the prompt.</li>
          </ol></li>
      </ol>
    
    <h2><a name="file-standards">2.4 File Standards</a></h2>
      
      <p>There are two different file standards you will have to be concerned with as a translator:</p>
      <ol>
        <li>          <b>Static (PHP only)</b>          <p>These are documents whose organization (e.g. item numbering) isn't expected to change much on a day-to-day basis.  In this case the document just has a PHP file, which you will translate.</p>        </li>
        <li><b>Dynamic (XML generates PHP and HTML)</b>          <p>These documents (e.g. the FAQ) are updated and restructured more often, so they need the facility to be reorganized dynamically.  Such documents use an XML file as the basis by which PHP and HTML files are generated, via a script.  As a translator, your responsibility is to translate the XML file.</p></li>
      </ol>
    
    <h2><a name="updating">2.5 Update to latest revision</a></h2>
      
      <p>Since other translators will change some files (don't afraid about that, CVS can take good care of it) after you checked out the files, it is a good idea that update your working copy to the latest revision frequently. For updating, you can:</p>
      <ol>
        <li>Follow steps 4 - 6 above, login to CVS.</li>
        <li>Move to the directory that contains the files you checked out, e.g:
<pre>cd ~/Documents/Fink-i18n/xml</pre></li>
        <li>Update it, e.g:<pre>cvs -d:pserver:anonymous@cvs.sourceforge.net:/cvsroot/fink update</pre>for team members without commit access, or<pre>cvs update</pre>for team leaders.</li>
      </ol>
    
    <h2><a name="initial-translation">2.6 Initial Translation</a></h2>
      
      <p>The files to translate, in order of priority, are:</p>
      <p>Title (English version file)</p>
      <ol>
        <li>Constants file (<code>xml/web/constants.*.inc</code>)(see below)</li>
        <li>Static PHP files (e.g. <code>xml/web/*.en.php</code>)
  </li>
        <li>User's Guide (<code>xml/uguide.xml</code>)</li>
        <li>FAQ (<code>xml/faq.xml</code>)</li>
        <li>Running X11 (<code>xml/x11/x11.xml</code>)</li>
        <li>Document Index (<code>xml/doc/doc.xml</code>, but the PHP files for this  cannot be generated by running <code>make</code> due to remaining xslt problems)</li>
        <li>Packaging (<code>xml/packaging/packaging.xml</code>)</li>
        <li>Porting (<code>xml/porting/porting.xml</code>)</li>
        <li>News (<code>xml/news/news.xml</code>)</li>
      </ol>
      <p>The <code>constants.*.inc</code> files are intended to deal with hard coded items in the PHP include files.  They are mostly menu items and such, located on top and left of the pages.  You should separate them from the scripts and create a file like the sample file (English) below:</p>
      <pre>
/* The Sections.  Used in Menu Navigation Bar */
define (FINK_SECTION_HOME, 'Home');
define (FINK_SECTION_DOWNLOAD, 'Download');
define (FINK_SECTION_PACKAGE, 'Packages');
define (FINK_SECTION_HELP, 'Help');
define (FINK_SECTION_FAQ, 'F.A.Q.');
define (FINK_SECTION_DOCUMENTATION, 'Documentation');
define (FINK_SECTION_MAILING_LISTS, 'Mailing Lists');

/* The Home Subsections.  Used in Menu Navigation Bar */
define (FINK_SECTION_HOME_INDEX, 'Index');
define (FINK_SECTION_HOME_NEWS, 'News');
define (FINK_SECTION_HOME_ABOUT, 'About');
define (FINK_SECTION_HOME_CONTRIBUTORS, 'Contributors');
define (FINK_SECTION_HOME_LINKS, 'Links');

/* The word 'Sections'.  Used in Menu Navigation Bar */
define (FINK_SECTIONS, 'Sections');

/* Contents as Table of Contents.  Used in FAQ/Documentation Sections */
define (FINK_CONTENTS, 'Contents');
</pre>
      <p>When you translate, you normally follow the steps as below (suppose you 
are translating the Running X11 document into French):</p>
      <ol>
        <li>Copy the xml file
<pre>cp x11.en.xml x11.fr.xml</pre>
        </li>
        <li>Edit the line to declare it is French and its encoding is UTF-8
      <pre>&lt;?xml version='1.0' encoding='utf-8' ?&gt;
...
&lt;document filename="index" lang="fr" &gt;
...</pre>
        </li>
        <li>Save as UTF-8
Be aware that the encoding must be utf-8 and take care not to change
anything but true text.</li>
        <li>Once you are done, or just to test it, edit the <code>Makefile</code> to include your 
language as:
<pre>LANGUAGES = en ja fr
include $(basedir)/Makefile.i18n.common</pre>
          <p>then type <code>make</code> in the directory.  This should generate your PHP (and 
possibly some other) files  as well as English and Japanese.</p>
        </li>
      </ol>
      <p>Note:
If you see some misspelling or errors in the English
file, don't change it, but instead report it instead to the fink-i18n list, so
that the master English file is changed.
</p>
    
    <h2><a name="committing">2.7 Committing the Changes (Team Leaders)</a></h2>
      
      <p>Now you need to send your changes to the main server.  To do this you need to make sure that you have commits access.  You also should make sure that you are using the same version of XSLT as everyone else, which currently is <code>xslt-1.1.2-2</code> from Fink.</p>
      <p>The commits process is a bit different between the static and dynamic documents:</p>
      <ul>
        <li>  <b>Static:  </b>(PHP files only)To commit these documents do the following:<ol>
            <li>Open a terminal.</li>
            <li>Move to the directory that contains the file you want to check in, e.g:
<pre>cd ~/Documents/Fink-i18n/xml/web</pre>
              <p>if you created your <code>web</code> tree under <code>Documents/Fink-i18n/</code> in your home folder, and you want to commit a PHP file from the xml/web directory.</p>
            </li>
            <li>If the file is a new one that you've created, then you need to add it to the list of files, e,g.:<pre>cvs add -m "message" download.ru.php</pre>Where <b>message </b>is an informative message saying what you've done.  Give your SourceForge password at the prompt.  You may get a message about the DSA key of the server being unknown.  Go ahead and answer yes.
    <p>If the file already exists, you can skip to the next step.</p>
            </li>
            <li>Commit the file, e.g. in the prior example:<pre>cvs ci -m "message" download.ru.php</pre>where once again <b>message </b>should indicate what you've done.  Give your SourceForge password at the prompt.  You may get a message about the DSA key of the server being unknown.  Go ahead and answer yes.
    <p>Note:  you can commit multiple files at once, and use wildcards, too.</p></li>
          </ol></li>
        <li>          <b>Dynamic:  </b>(XML and PHP).  After you've modified the XML file, do the following:<ol>
            <li>Open a terminal</li>
            <li>Move to the directory that contains the file you've added or modified, e.g.<pre>cd ~/Documents/Fink-i18n/xml/faq</pre>if you've been working on the FAQ.</li>
            <li>Now run<pre>make check</pre>To ensure that the file is valid.
            </li>
            <li>If the XML file is a new one that you've created, then you need to add it to the list of files, e,g.:<pre>cvs add -m "message" faq.ru.xml</pre>
where <b>message </b>is a description about what you've done.  You'll need to give your SourceForge password.  You may get a message about the DSA key of the server.  Go ahead and answer yes.
    <p>If the file already exists, you can skip to the next step.</p>
            </li>
            <li>Commit the file, e.g.:<pre>cvs ci -m "message" faq.ru.xml</pre>
              <p>where <b>message</b> is a descriptive message about what you've done.  Enter your SourceForge Password at the prompt.  You may get a message about the DSA key of the server.  Go ahead and anwer yes.</p>
            </li>
            <li>Now run<pre>make &amp;&amp; make install</pre>
            </li>
            <li>Move to the directory that contains your copy of the Fink web tree, e.g:
<pre>cd ~/Documents/Fink-i18n</pre>
              <p>if you created your <code>xml</code> tree under <code>Documents/Fink-i18n/</code> in your home folder.</p>
            </li>
            <li>If the XML file was new, you'll need to do some more CVS adding.  For example, if you have been working on the FAQ, then, you'll want to run:<pre>cvs add xml/web/faq/* xml/scripts/installer/dmg/*</pre>
            </li>
            <li>Commit the whole web tree:<pre>cvs ci -m "message" web</pre>          <p>Where once again <b>message</b> is a descriptive log message (you may want to use the same one as when you committed the XML file). Enter your SourceForge Password at the prompt.  You may get a message about the DSA key of the server.  Go ahead and anwer yes.</p>
            </li>
          </ol>
        </li>
      </ul>
    
    <h2><a name="website">2.8 Update our website</a></h2>
      
      <p>Want to see your efforts from our website right now? Just do the following:</p>
      <ol>
        <li>Open a terminal</li>
        <li>log in web server via ssh:
<pre>ssh username@shell.sourceforge.net</pre>
You'll need to give your SourceForge password. You may get a message about the DSA key of the server. Go ahead and answer yes.</li>
        <li>Move to the dictory contains our web pages:
<pre>cd /home/groups/f/fi/fink/htdocs</pre></li>
        <li>update the website from CVS:
<pre>./update.sh</pre></li>
        <li>log out from web server:
<pre>exit</pre></li>
        <li>See your efforts:
<pre>open http://fink.sourceforge.net/</pre></li>
      </ol>
    
  <p align="right">
Next: <a href="procedure.php">3 Procedure for Updating Documents</a></p>


<?
include "footer.inc";
?>

