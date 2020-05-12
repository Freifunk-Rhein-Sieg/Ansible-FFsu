#!/usr/bin/perl

use strict;
use warnings;

$^I = '.bak'; # create a backup copy

while (<>) {
   # 50798131901, 7217050523
   s/50798131901/50.798131901/g; # add site_code to empty records
   s/7217050523/7.217050523/g;
   print; # print to the modified file
}

