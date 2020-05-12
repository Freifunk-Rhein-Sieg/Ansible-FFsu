#!/usr/bin/perl

use strict;
use warnings;
use JSON::Parse 'json_file_to_perl';
use Data::Dumper;
use DateTime;
#use Date::Manip;

# define default runtime vars
my $filename = $ARGV[0];

# my $filename = "nodes.json";

if ( ! $filename ) {
                print "USAGE: ./jsondump.pl <filename>\n";
                exit 0;
        }

# test, if file exist
if ( -f $filename ){

# Parse JSON data
 # Read JSON data from FILE
        my $content = json_file_to_perl ($filename);
        print Dumper($content);


} else {
                        print "ERROR: file ".$filename." does not exist.\n";
}


exit 0;


