# The Silver Searcher AG

## よく使うオプション

```bash
# ディレクトリ階層の深さ指定
     --depth NUM          Search up to NUM directories deep (Default: 25)
# (マッチした)ファイル名のみを出力
  -l --files-with-matches Only print filenames that contain matches
                          (dont print the matching lines)
# マッチしなかったファイル名を表示
  -L --files-without-matches
                          Only print filenames that dont contain matches
# ファイル名にマッチしたものを出力
  -g PATTERN              Print filenames matching PATTERN
# 行番号を非表示
     --[no]numbers        Print line numbers. Default is to omit line numbers
                          when searching streams
# 隠しファイルも検索
     --hidden             Search hidden files (obeys .*ignore files)
# 全ファイルを検索(隠しファイル、無視指定ファイル含め検索)

  -u --unrestricted       Search all files (ignore .agignore, .gitignore, etc.;
                          searches binary and hidden files as well)
# 大文字小文字区別
  -s --case-sensitive     Match case sensitively
# 大文字を含んでいれば、大文字小文字区別
  -S --smart-case         Match case insensitively unless PATTERN contains
                          uppercase characters (Enabled by default)
# ファイル名を正規表現指定で制限検索(ex. ag -G '\.(c|h)' pattern)
  -G --file-search-regex  PATTERN Limit search to filenames matching PATTERN
```

## Install For Windows
- [The Silver Searcher windows port](http://blog.kowalczyk.info/software/the-silver-searcher-for-windows.html)
- [ag.zip](https://kjkpub.s3.amazonaws.com/software/the_silver_searcher/rel/0.29.1-1641/ag.zip)

### Install For msys2
```sh
pacman -S mingw-w64-x86_64-ag
```

## help
```help
Usage: ag [FILE-TYPE] [OPTIONS] PATTERN [PATH]

  Recursively search for PATTERN in PATH.
  Like grep or ack, but faster.

Example:
  ag -i foo /bar/

Output Options:
     --ackmate            Print results in AckMate-parseable format
  -A --after [LINES]      Print lines after match (Default: 2)
  -B --before [LINES]     Print lines before match (Default: 2)
     --[no]break          Print newlines between matches in different files
                          (Enabled by default)
  -c --count              Only print the number of matches in each file.
                          (This often differs from the number of matching lines)
     --[no]color          Print color codes in results (Enabled by default)
     --color-line-number  Color codes for line numbers (Default: 1;33)
     --color-match        Color codes for result match numbers (Default: 30;43)
     --color-path         Color codes for path names (Default: 1;32)
     --column             Print column numbers in results
     --[no]filename       Print file names (Enabled unless searching a single file)
  -H --[no]heading        Print file names before each file's matches
                          (Enabled by default)
  -C --context [LINES]    Print lines before and after matches (Default: 2)
     --[no]group          Same as --[no]break --[no]heading
  -g PATTERN              Print filenames matching PATTERN
  -l --files-with-matches Only print filenames that contain matches
                          (don't print the matching lines)
  -L --files-without-matches
                          Only print filenames that don't contain matches
     --[no]numbers        Print line numbers. Default is to omit line numbers
                          when searching streams
  -o --only-matching      Prints only the matching part of the lines
     --print-long-lines   Print matches on very long lines (Default: >2k characters)
     --passthrough        When searching a stream, print all lines even if they
                          don't match
     --silent             Suppress all log messages, including errors
     --stats              Print stats (files scanned, time taken, etc.)
     --vimgrep            Print results like vim's :vimgrep /pattern/g would
                          (it reports every match on the line)
  -0 --null --print0      Separate filenames with null (for 'xargs -0')

Search Options:
  -a --all-types          Search all files (doesn't include hidden files
                          or patterns from ignore files)
  -D --debug              Ridiculous debugging (probably not useful)
     --depth NUM          Search up to NUM directories deep (Default: 25)
  -f --follow             Follow symlinks
  -F --fixed-strings      Alias for --literal for compatibility with grep
  -G --file-search-regex  PATTERN Limit search to filenames matching PATTERN
     --hidden             Search hidden files (obeys .*ignore files)
  -i --ignore-case        Match case insensitively
     --ignore PATTERN     Ignore files/directories matching PATTERN
                          (literal file/directory names also allowed)
     --ignore-dir NAME    Alias for --ignore for compatibility with ack.
  -m --max-count NUM      Skip the rest of a file after NUM matches (Default: 10,000)
     --one-device         Don't follow links to other devices.
  -p --path-to-agignore STRING
                          Use .agignore file at STRING
  -Q --literal            Don't parse PATTERN as a regular expression
  -s --case-sensitive     Match case sensitively
  -S --smart-case         Match case insensitively unless PATTERN contains
                          uppercase characters (Enabled by default)
     --search-binary      Search binary files for matches
  -t --all-text           Search all text files (doesn't include hidden files)
  -u --unrestricted       Search all files (ignore .agignore, .gitignore, etc.;
                          searches binary and hidden files as well)
  -U --skip-vcs-ignores   Ignore VCS ignore files
                          (.gitignore, .hgignore, .svnignore; still obey .agignore)
  -v --invert-match
  -w --word-regexp        Only match whole words
  -z --search-zip         Search contents of compressed (e.g., gzip) files

File Types:
The search can be restricted to certain types of files. Example:
  ag --html needle
  - Searches for 'needle' in files with suffix .htm, .html, .shtml or .xhtml.

For a list of supported file types run:
  ag --list-file-types

-l, --files-with-matches
```

## list file type
`ag --list-file-types`

```help
The following file types are supported:
  --actionscript
      .as  .mxml

  --ada
      .ada  .adb  .ads

  --asm
      .asm  .s

  --batch
      .bat  .cmd

  --cc
      .c  .h  .xs

  --cfmx
      .cfc  .cfm  .cfml

  --clojure
      .clj  .cljs  .cljc  .cljx

  --coffee
      .coffee  .cjsx

  --cpp
      .cpp  .cc  .C  .cxx  .m  .hpp  .hh  .h  .H  .hxx

  --csharp
      .cs

  --css
      .css

  --delphi
      .pas  .int  .dfm  .nfm  .dof  .dpk  .dproj  .groupproj  .bdsgroup  .bdsproj

  --ebuild
      .ebuild  .eclass

  --elisp
      .el

  --elixir
      .ex  .exs

  --erlang
      .erl  .hrl

  --fortran
      .f  .f77  .f90  .f95  .f03  .for  .ftn  .fpp

  --fsharp
      .fs  .fsi  .fsx

  --gettext
      .po  .pot  .mo

  --go
      .go

  --groovy
      .groovy  .gtmpl  .gpp  .grunit

  --haml
      .haml

  --haskell
      .hs  .lhs

  --hh
      .h

  --html
      .htm  .html  .shtml  .xhtml

  --ini
      .ini

  --jade
      .jade

  --java
      .java  .properties

  --js
      .js  .jsx

  --json
      .json

  --jsp
      .jsp  .jspx  .jhtm  .jhtml

  --less
      .less

  --liquid
      .liquid

  --lisp
      .lisp  .lsp

  --lua
      .lua

  --m4
      .m4

  --make
      .Makefiles  .mk  .mak

  --mako
      .mako

  --markdown
      .markdown  .mdown  .mdwn  .mkdn  .mkd  .md

  --mason
      .mas  .mhtml  .mpl  .mtxt

  --matlab
      .m

  --mathematica
      .m  .wl

  --mercury
      .m  .moo

  --nim
      .nim

  --objc
      .m  .h

  --objcpp
      .mm  .h

  --ocaml
      .ml  .mli  .mll  .mly

  --octave
      .m

  --parrot
      .pir  .pasm  .pmc  .ops  .pod  .pg  .tg

  --perl
      .pl  .pm  .pm6  .pod  .t

  --php
      .php  .phpt  .php3  .php4  .php5  .phtml

  --pike
      .pike  .pmod

  --plone
      .pt  .cpt  .metadata  .cpy  .py

  --puppet
      .pp

  --python
      .py

  --racket
      .rkt  .ss  .scm

  --rake
      .Rakefiles

  --rs
      .rs

  --r
      .R  .Rmd  .Rnw  .Rtex  .Rrst

  --ruby
      .rb  .rhtml  .rjs  .rxml  .erb  .rake  .spec

  --rust
      .rs

  --salt
      .sls

  --sass
      .sass  .scss

  --scala
      .scala

  --scheme
      .scm  .ss

  --shell
      .sh  .bash  .csh  .tcsh  .ksh  .zsh

  --smalltalk
      .st

  --sml
      .sml  .fun  .mlb  .sig

  --sql
      .sql  .ctl

  --stylus
      .styl

  --swift
      .swift

  --tcl
      .tcl  .itcl  .itk

  --tex
      .tex  .cls  .sty

  --tt
      .tt  .tt2  .ttml

  --vala
      .vala  .vapi

  --vb
      .bas  .cls  .frm  .ctl  .vb  .resx

  --velocity
      .vm

  --verilog
      .v  .vh  .sv

  --vhdl
      .vhd  .vhdl

  --vim
      .vim

  --wsdl
      .wsdl

  --wadl
      .wadl

  --xml
      .xml  .dtd  .xsl  .xslt  .ent

  --yaml
      .yaml  .yml
```

