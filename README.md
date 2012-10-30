Description
===========

Query RFC database and download RFCs from within Vim.

How does it work?
=================

Without cachefile
-----------------

    1.  download RFC index file (XML)
    2.  build cachefile from XML (YAML)
    3.  build hash from cachefile
    4.  provide hash to Vim
    5.  delete index file

With cachefile
--------------

    1.  build hash from cachefile
    2.  provide hash to Vim
    3.  (delete index file if existing)

Dependencies
============

The Ruby script depends on a SAX parser provided by nokogiri, which itself is
written in C. Thus you will need libxml2-dev and libxslt-dev, too.

    gem install nokogiri

Usage
=====

There are only two commands defined: RQ and RG for querying and getting
respectively.

Query the RFC database:

    :RQ http

Loading the RFC into a buffer:

    :RG 2818

    :2818RG

Author
======

Marco Hinz
