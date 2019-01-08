**vim-rfc** allows querying the [RFC](https://en.wikipedia.org/wiki/Request_for_Comments) database and opening any RFC/STD document in
Vim.

![vim-rfc in action](https://github.com/mhinz/vim-rfc/raw/master/rfc-demo.gif)

- Includes a modified version of [vim-scripts/rfc-syntax](https://github.com/vim-scripts/rfc-syntax) for RFC syntax highlighting.

## Installation

Use your favorite plugin manager.

Using [vim-plug](https://github.com/junegunn/vim-plug):

    Plug 'mhinz/vim-rfc'

Restart Vim and `:PlugInstall`, then have a look at the docs: `:h rfc`.

## Dependencies

This plugin requires Ruby support compiled into Vim: `:echo has('ruby')`

Additionaly, nokogiri is used as XML parser:

    $ gem install nokogiri

## Usage

List documents:

```
:RFC [regexp]
```

Rebuild cache and list documents:

```
:RFC! [regexp]
```

A new window with all matches will be shown. Use `<cr>` to open an entry or `q`
to quit.

Examples: `:RFC`, `:RFC 100`, `:RFC http/2`, `:RFC ipv4 addresses`.

## Configuration

There are no options, but you can change the default colors used in the window
opened by `:RFC`. See `:h rfc-colors`.

## Internals

If you use this plugin for the first time it downloads an index file from the
internet. To parse that XML file a SAX parser, nokogiri, is used which is a
event-driven XML parser written in C.

The parse tree is saved in a Ruby hash and written to a cachefile in YAML
format. The file is located in `~/.vim-rfc.yml`.

If you issue a query, the cachefile will be used for the lookup. The resulting
hash will be provided back to the Vim environment.

At the end the index file will be removed, since it's not needed anymore.

If you use the plugin for the second time, the cachefile will be used right away
and downloading the 8 MiB index will be omitted.

## Author and Feedback

If you like my plugins, please star them on Github. It's a great way of getting
feedback. Same goes for issues reports or feature requests.
