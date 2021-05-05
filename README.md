**vim-rfc** lists all existing [RFCs](https://en.wikipedia.org/wiki/Request_for_Comments) and opens the selected one in a new buffer.

Works in Vim and Nvim, but it requires python3 support: `:echo has('python3')`

![vim-rfc in action](./demo.svg)

- Includes a modified version of [vim-scripts/rfc-syntax](https://github.com/vim-scripts/rfc-syntax) for RFC syntax highlighting.

## Installation

Use your favorite plugin manager.

Using [vim-plug](https://github.com/junegunn/vim-plug):

    Plug 'mhinz/vim-rfc'

Restart Vim and `:PlugInstall`, then have a look at the docs: `:h rfc`.

## Usage

List documents:

```
:RFC [vim regexp]
```

Rebuild cache and list documents:

```
:RFC! [vim regexp]
```

Use `<cr>` to open an entry or `q` to quit.

Examples: `:RFC`, `:RFC 100`, `:RFC http/2`, `:RFC ipv4 addresses`.

Within a RFC document, if you are on a line from the table of contents,
`<c-]>`/`<cr>` will jump to the referenced section. On a string like `STD 10` or
`RFC 1234` (which should also be highlighted), it opens the referenced document
instead. Use `<c-o>` to jump back.

## Configuration

There are no options, but you can change the default colors used in the window
opened by `:RFC`. See `:h rfc-colors`.

## Implementation

This first time this plugin is used, it takes a few seconds to download an index
file containing all existing RFC documents (~12 MB). That XML file is parsed and
all RFC and STD entries get stored in a cache file.

The second time this plugin is used, the cache file will be used right away.

If you select an entry, it gets downloaded and immediately put into a new
buffer. There is no temporary file created on the disk.

Default cache file locations:

- `$XDG_CACHE_HOME/vim/vim-rfc.txt` for Vim
- `$XDG_CACHE_HOME/nvim/vim-rfc.txt` for Nvim

If `$XDG_CACHE_HOME` is not set, it defaults to `~/.cache`.

## Author and Feedback

If you like my plugins, please star them on Github. It's a great way of getting
feedback. Same goes for issues reports or feature requests.
