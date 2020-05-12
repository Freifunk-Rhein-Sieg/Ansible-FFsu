#!/usr/bin/perl

use strict;
use warnings;

$^I = '.bak'; # create a backup copy

while (<>) {
   s/\"system\"\:\{\}/\"system\"\:\{\"site_code\"\:\"flu\"\}/g; # add site_code to empty records
   s/\"site_code\"\:\"flu\"/\"domain_code\"\:\"flu\",\"site_code\"\:\"flu\"/g; # do the replacement
   print; # print to the modified file
}

