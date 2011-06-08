#!/bin/zsh
# Filename:         gmat_memorize_math.zsh
# Version:          0.1
# Description:
#   This is a simple memorization program that I wrote for myself in 2010 to
#   memorize some math computations.  I'm putting it out there, as it may
#   be helpful to others.
#
# Platforms:        anywhere where zsh runs, e.g. Linux, Mac OS X, Cygwin
# Source:           https://github.com/huyz/gmat-training
# Author:           Huy Z, http://huyz.us/
# Created on:       huyz 2010-05-01
#
# How this works
# --------------
# It works similarly to flash cards.  It prompts you for a computation.
# You speak the answer out loud (the program will ignore you), then hit
# <ENTER> to see the answer.
#
# TODO:
# - write a program to list all the primes to 101
# - test for some pythagorean triples

# Copyright (C) 2011 Huy Z
# 
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

a=(
"sqrt(2)"
"sqrt(3)"
"sqrt(5)"
"sqrt(6)"
"sqrt(7)"
"sqrt(8)"
"sqrt(10)"
"sqrt(169)"
"sqrt(196)"
"sqrt(225)"
"sqrt(256)"
"sqrt(289)"
"sqrt(324)"
"sqrt(361)"
"sqrt(625)"
"root(27,3)"
"root(64,3)"
"root(125,3)"
"root(216,3)"
"13^2"
"14^2"
"15^2"
"16^2"
"17^2"
"18^2"
"19^2"
"25^2"
"3^3"
"4^3"
"5^3"
"6^3"
"1/6 *100"
"1/7 *100"
"1/8 *100"
"1/9 *100"
"factorial(3)"
"factorial(4)"
"factorial(5)"
"factorial(6)"
)

j=dummy
while true; do
	i=${a[$(($RANDOM % ($#a + 1)))]}
	[[ $i = $j ]] && continue
	clear
	echo $i

	#sleep 2
        echo -n "Hit enter:"
        read an

	echo -n "= "
	printf '%1.02f' $(echo "scale=20; $i" | bc -l) | sed 's/\.0*$//'
	sleep 1
	j=$i
done
