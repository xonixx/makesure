#!/usr/bin/env bash

#echo \
#"A c
#a b
#a c
#a d
#b c
#c e
#e f" | awk -f rtsort.awk

#echo \
#"a b
#a c
#a d
#b c
#c e
#e f
#f a" | awk -f rtsort.awk

#echo \
#"a b
#b c
#c a
#d e
#e d" | awk -f rtsort.awk

#echo \
#"a b
#A b
#b c
#c d" | awk -f rtsort.awk

#echo \
#"a b
#b c
#c a" | awk -f rtsort.awk

#echo \
#"a b
#b c
#b d
#c d" | awk -f rtsort.awk
#
#a-b-c-d
#  |___|

echo | awk -f rtsort1.awk