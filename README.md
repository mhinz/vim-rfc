Description
===========

Query RFC database and load document into a Vim buffer. A query looks for STD and
RFC, but omits FYI and BCP.

    :RQ cidr

![Example: RQ cidr](https://github.com/mhinz/vim-rfc/raw/master/rfc.png)

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

There are only three commands defined: RQ, RG and RGS for querying the database,
getting a RFC and getting a STD respectively.

Query the database:

    :RQ http

Loading a RFC into a buffer:

    :RG 2818

    :2818RG

Loading a STD into a buffer:

    :RGS 1

    :1RGS

Author
======

Marco Hinz
