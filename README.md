vim-rfc is a plugin to query the RFC database and loading RFC/STD documents into
a Vim buffer.

It is mostly written in Ruby.

![Example: RQ cidr](https://github.com/mhinz/vim-rfc/raw/master/rfc.png)

Dependencies
============

```
$ gem install nokogiri
```

Usage
=====

..is really simple.

Query the database: `:RFC <case-insensitive regexp>`

A new window with all found matches will be shown. Now you can simply use `<cr>`
to open the entry.

You can also open by RFC id. E.g. if one of the matches is "RFC123", you can
enter "123" to open it.

Internals
=========

If you use this plugin for the first time it downloads an index file from the
internet. To parse that XML file a SAX parser, nokogiri, is used which is a
event-driven XML parser written in C.

The parse tree is saved in a Ruby hash and written to a cachefile in YAML
format. The file is located in ~/.vim-rfc.yml.

If you issue a query, the cachefile will be used for the lookup. The resulting
hash will be provided back to the Vim environment.

At the end the index file will be removed, since it's not needed anymore.

If you use the plugin for the second time, the cachefile will be used right away
and downloading the 8 MiB index will be omitted.

Author and feedback
===================

If you like my plugins, please star them on Github. It's a great way of getting
feedback. Same goes for issues reports or feature requests.

*Names:* Marco Hinz, mhinz, mhi^, mhi

*Mail:* `<mh.codebro@gmail.com>`

*Twitter:* https://twitter.com/\_mhinz_[@\_mhinz_]

*Stackoverflow:* http://stackoverflow.com/users/1606959/mhinz[mhinz]

_Thank you for flying mhi airlines. Get your Vim on!_
