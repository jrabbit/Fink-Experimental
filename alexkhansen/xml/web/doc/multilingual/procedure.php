<?
$title = "i18n - Update Procedure.";
$cvs_author = 'Author: alexkhansen';
$cvs_date = 'Date: 2004/03/04 19:13:52';

$metatags = '<link rel="contents" href="index.php" title="i18n Contents"><link rel="next" href="resources.php" title="Additional Resources."><link rel="prev" href="files.php" title="The Documentation Files">';

include "header.inc";
?>

<h1>i18n - 3 Procedure for Updating Documents</h1>
    
    
    
      <p>In order that things go smoothly, the following procedure should be followed..
</p>
    
    <h2><a name="english">3.1 Update English Documentation</a></h2>
      
      <p>Since the English documentation is the baseline, it must be updated first.  Such an update may come from a member of the i18n team (e.g. the English Documentarians) or directly from the core developers.</p>
      <p>There are a couple of classifications for documentation updates:</p>
      <ol>
        <li>
          <b>Urgent (security, bugfixes, etc.):</b>  The base English documentation gets updated immediately, and translators update their individual documents and get them online as soon as  possible.</li>
        <li>
          <b>Not urgent:</b>  In this case, the basic English documentation is updated, but not put online immediately.  All translators do their work and get their version online within a day or two, then all versions get put online at the same time.</li>
      </ol>
    
    <h2><a name="call-to-translate">3.2 Call to Translate</a></h2>
      
      <p>Once the English files are done, a message will be posted to the fink-18n list informing all translators of the fact.  The message will contain the following:</p>
      <ul>
        <li>A note in the subject line indicating that this is a request for translation, e.g. "[translation]", or "[translation-urgent]" for items where the English documentation is going online immediately.
</li>
        <li>In addition, the filename of the base file should be included somewhere in the message.</li>
        <li>A full diff (e.g. <code>diff -Nru3 -r<b>last_revision</b> r<b>head</b>
          </code>) to show the modifications in context.</li>
      </ul>
      <p>Note:  since committing the XML file automatically produces a message 
on fink-commits that meets all of these criteria, an easy thing to do is to 
redirect such a message and re-title the subject.</p>
    
    <h2><a name="translate">3.3 Translation</a></h2>
      
      <p>Now the actual work of translation proceeds.  When all of the 
documents for a language are done, the files should be committed, 
and a message sent to fink-i18n saying that the translation for that 
language is done.</p>
    
    <h2><a name="activation">3.4 Activating the Changes</a></h2>
      
      <p>There are two options for activating changes:</p>
      <ol>
        <li>For urgent changes, immediately after a language gets done, its 
changes get activated.</li>
        <li>For non-urgent changes, the changes will be activated after all 
languages are finished.
  </li>
      </ol>
    
  <p align="right">
Next: <a href="resources.php">4 Additional Resources.</a></p>


<?
include "footer.inc";
?>

