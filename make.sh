#!/bin/bash

# choose the latex program to compile sources
# because of mixing languages (russian, czech, german...), xelatex is the easiest option 
TEX=xelatex

find `pwd`/pisnicky/*.tex > list.tex
sed -i 's/^/\\input\{/g' list.tex
sed -i 's/$/\}/g' list.tex

#echo building chord table
#./chords2tex.sh

# make pdf
$TEX zpevnik.tex
./songidx songindex.sxd songindex.sbx
./songidx authorindex.sxd authorindex.sbx
$TEX zpevnik.tex

evince zpevnik.pdf


