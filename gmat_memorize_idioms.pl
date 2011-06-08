#!/usr/bin/perl -T
# Filename:         gmat_memorize_idioms.pl
# Version:          0.1
# Description:
#   This is the memorization program that I wrote for myself in 2010 to
#   memorize English idioms for the GMAT. I'm putting it out there, as it may
#   be helpful to others. It helped me score a 780.
#   You can use the program directly at http://huyz.us/gmat/
#
# Platforms:        anywhere where perl runs, e.g. Linux, Mac OS X, Windows
# Depends:          Term::Menu, Term::ANSIScreen (from CPAN)
# Source:           https://github.com/huyz/gmat-training
# Author:           Huy Z, http://huyz.us/
# Created on:       huyz 2010-05-01
#
# How this works
# --------------
# It works similarly to flash cards. You are presented with an English
# sentence example, and you need to answer whether the capitalized idiom is
# considered right, wrong, or suspect, as defined by the Manhattan GMAT. The
# program tracks your incorrect answers through all the idioms that it knows,
# and then it starts another round with all the examples that you missed, and
# so on through multiple rounds until you have properly judged all the idioms.
# Going through all the rounds may take around an hour or more, as the
# selected idioms are quite difficult and often counter-intuitive.
# 
# What has worked for me is to train a few times at least a week from the
# test date, and then again the day before.
#
# This tool is a companion to the excellent Manhattan GMAT Sentence Correction
# preparation guide, that you can find at:
# http://www.amazon.com/gp/product/0982423861/ref=as_li_tf_tl?ie=UTF8&tag=huyzus-20&linkCode=as2&camp=217153&creative=399353&creativeASIN=0982423861
# Using this tool will not be of much benefit to you until you buy and read
# the guide first to get context about idioms.  An absolute must-have for the
# GMAT.
#
# Installation
# ------------
# First, install the perl module dependencies from CPAN.
#
# You then need a file containing the list of idiom exercises.
# Create a file with the same name as this script but with the extension "txt",
# i.e. "gmat_memorize_idioms.txt".
# The format of each line is:
# (RIGHT|WRONG|SUSPECT): idiom example *without* parentheses.
# with an optional note at the end delimited by an opening parenthesis or
# the text "Note:"
#
# Examples
# --------
# *SUSPECT: The bay ACTED LIKE a funnel for the tide.
# RIGHT: The bay ACTED AS a funnel for the tide.
# RIGHT: My friend ACTED LIKE a fool.
#
# (The optional star at the begining of each line is just a note to myself
# that this particular example is counter-intuitive; it doesn't affect
# the execution of the program.)
#
# Pre-constructed exercise list
# -----------------------------
# If you'd like a copy of my idiom exercises, shoot me an email at
# huy-gmat-pub circled-a huyz.us


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

### CONFIG

# Only test up to this many idioms out of the file.  Comment out to disable.
# Set to -1 for all
our $MAX_IDIOMS = -1;
#our $MAX_IDIOMS = 3;

### END CONFIG

use strict;
use vars;

# So that we can prompt
use Term::Menu;
my $menu = new Term::Menu (
  beforetext => "Evaluate the capitalized IDIOM according to the GMAT:",
  aftertext => "Enter the letter and press <Enter>: ",
  tries => 999, # Bug in Term::Menu, 0 is not unlimited
);

# So that we can clear the screen
use Term::ANSIScreen;
my $console = Term::ANSIScreen->new;

my %score;
my %num;
my $idiom_count;

my $IDIOMFILE;
($IDIOMFILE = $0) =~ s/\.[^.]*?$//;
$IDIOMFILE .= ".txt";

sub read_lines {
    open(INPUT, $IDIOMFILE) or die "Can't open file $IDIOMFILE";
    my @lines = <INPUT>;
    close INPUT;
    $idiom_count = @lines;
    if ($MAX_IDIOMS > 0 && $idiom_count > $MAX_IDIOMS) {
        $idiom_count = $MAX_IDIOMS;
    }
    return @lines;
}

sub clear() {
    $console->Cls();            # unbuffered
    $console->Cursor(0, 0);     # same as locate(1, 1)
    print "GMAT - Memorize $idiom_count Idiom Exercises\n\n";
}

# fisher_yates_shuffle( \@array ) : generate a random permutation
# of @array in place
# http://docstore.mik.ua/orelly/perl3/cookbook/ch04_18.htm
sub fisher_yates_shuffle {
    my $array = shift;
    my $i;
    for ($i = @$array; --$i; ) {
        my $j = int rand ($i+1);
        next if $i == $j;
        @$array[$i,$j] = @$array[$j,$i];
    }
}

sub scorepart($$) {
    my ($solution, $answer) = @_;

    my $result = $score{$solution}{$answer};
    $result .= " (" . int(100 * $score{$solution}{$answer} / $num{$solution}) . "%)" if $num{$solution};

    return $result;
}


RESTART:
my @lines = read_lines();
my @nextlines;

for (my $round = 1; ; $round++) {
    my $correct = 0;
    my $count = 1;
    %score = (
        'RIGHT' => { 'RIGHT' => 0, 'SUSPECT' => 0, 'WRONG' => 0 },
        'SUSPECT' => { 'RIGHT' => 0, 'SUSPECT' => 0, 'WRONG' => 0 },
        'WRONG' => { 'RIGHT' => 0, 'SUSPECT' => 0 , 'WRONG' => 0 },
    );

    fisher_yates_shuffle(\@lines);
    for my $line (@lines) {
        chomp($line);

        next unless my ($ans, $idiom, $note) = ($line =~ /^\*?([^:]*):\s+(.*?)((\(|(Note|NOTE):).*)?$/);

        clear();
        print "  Round $round   Current exercise $count/" . @lines . "  ";
        if ($count > 1) {
            print "Correct $correct (" . int(100 * $correct/($count - 1)) . "%)";
        }
        print "\n\n----------------------------------------------------\n";
        print "\n  EXERCISE: $idiom\n\n";

        my $answer;
        do {
            $answer = $menu->menu(
              RIGHT => ["Right", 'r'],
              SUSPECT => ["Suspect", 's'],
              WRONG => ["Wrong", 'w'],
              PASS  => ["Pass", 'p'],
            );
        } until defined($answer);

        print "\n----------------------------------------------------\n";
        if ($answer eq "PASS") {
          print "You've passed.\n";
          push @nextlines, $line;
        } elsif ($answer eq $ans) {
          print colored("CORRECT!\n", "green");
          $correct++;
        } else {
          print colored("INCORRECT", "red") . ", you answered that the example was \"$answer\"\n";
          push @nextlines, $line;
        }
        $score{$ans}{$answer}++;

        print "\nCorrect answer: \"$ans\"\n";
        print "        $note\n" if $note;

        print "\nPress enter to continue...";
        my $dummy = <STDIN>;

        $count++;
        if ($MAX_IDIOMS > 0) {
            last if $count > $MAX_IDIOMS;
        }
    }

    clear();
    print "  END OF Round $round with " . @lines . " idioms\n\n";
    if ($count > 1) {
        print "  Correct $correct (" . int(100 * $correct/($count - 1)) . "%)\n\n";

        $num{RIGHT} = $score{RIGHT}{RIGHT} + $score{RIGHT}{SUSPECT} + $score{RIGHT}{WRONG};
        $num{SUSPECT} = $score{SUSPECT}{RIGHT} + $score{SUSPECT}{SUSPECT} + $score{SUSPECT}{WRONG};
        $num{WRONG} = $score{WRONG}{RIGHT} + $score{WRONG}{SUSPECT} + $score{WRONG}{WRONG};

        printf "%20s%13s%13s%13s%13s\n", "Your answer:", "RIGHT", "SUSPECT", "WRONG", "TOTAL";
        printf "%20s%13s%13s%13s%13s\n", "Solution is RIGHT",
            scorepart("RIGHT", "RIGHT"),
            scorepart("RIGHT", "SUSPECT"),
            scorepart("RIGHT", "WRONG"),
            $num{RIGHT};
        printf "%20s%13s%13s%13s%13s\n", "Solution is SUSPECT",
            scorepart("SUSPECT", "RIGHT"),
            scorepart("SUSPECT", "SUSPECT"),
            scorepart("SUSPECT", "WRONG"),
            $num{SUSPECT};
        printf "%20s%13s%13s%13s%13s\n", "Solution is WRONG",
            scorepart("WRONG", "RIGHT"),
            scorepart("WRONG", "SUSPECT"),
            scorepart("WRONG", "WRONG"),
            $num{WRONG};
    }

    @lines = @nextlines;
    @nextlines = ();

    if (@lines) {
        print "\n\nPress enter to start a new round...\n";
        my $dummy = <STDIN>;
    } else {
        print "\n\n     CONGRATS!  You're done in $round rounds\n\n";
        print "Press enter to restart with all idioms...\n";
        my $dummy = <STDIN>;
        read_lines();
        goto RESTART;
    }
}

# vim:sw=4:ts=4:
