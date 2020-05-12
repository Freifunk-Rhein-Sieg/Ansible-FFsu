#!/usr/bin/perl

use strict;
use warnings;

$^I = '.bak'; # create a backup copy

while (<>) {
   s/\"system\"\:\{\}/\"system\"\:\{\"site_code\"\:\"inn\"\}/g; # add site_code to empty records
   s/\"site_code\"\:\"inn\"/\"domain_code\"\:\"inn\",\"site_code\"\:\"inn\"/g; # do the replacement
   print; # print to the modified file
}
