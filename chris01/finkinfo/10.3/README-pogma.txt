Pogma: thanks for looking into it.

Things you would need to do:

1.
Make sure an older svn is installed. E.g. 0.33.1

2.
copy the info and patch files from apache2-ssl, apr-ssl and svn-ssl to your
local tree.

3.
fink update svn-ssl
This will install bdb4.2 and updated apache2-ssl and apr-ssl, that link
to bdb4.2

4.
What goes wrong:

Compiling svn will fail during the tests, since it links to the old libraries
(At least that is what i think.)

Thanks, Chris.