#!/usr/bin/perl

use strict;
use warnings;

$^I = '.bak'; # create a backup copy

while (<>) {
   s/\"system\"\:\{\}/\"system\"\:\{\"site_code\"\:\"tdf\"\}/g; # add site_code to empty records
   s/\"site_code\"\:\"tdf\"/\"domain_code\"\:\"tdf\",\"site_code\"\:\"tdf\"/g; # do the replacement
   print; # print to the modified file
}

