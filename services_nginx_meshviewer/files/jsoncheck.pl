#!/usr/bin/perl

use strict;
use warnings;
use JSON::Parse 'json_file_to_perl';
#use Data::Dumper;
use DateTime;
#use Date::Manip;

# define default runtime vars
my $filename = $ARGV[0];

# my $filename = "nodes.json";

if ( ! $filename ) {
                print "USAGE: ./jsoncheck.pl <filename>\n";
                exit 0;
        }

# test, if file exist
if ( -f $filename ){

        # Read JSON data from FILE
        my $content = json_file_to_perl ($filename);

        #print ref $content, "\n";

        foreach my $key ( keys %$content ) {
           #print $key, " => ", $content->{$key},"\n";
             if ( $key eq 'timestamp' ){
               print "timestamp found : ";
               my $created_on = $content->{$key};
               print $created_on."\n";

               # lets check date
               my $today = DateTime->now();
               print "current date: ".$today."\n";

               # lets convert timestamp string to DateTime-Format

                my $year = substr ($created_on,0,4);
                my $month = substr ($created_on,5,2);
                my $day = substr ($created_on,8,2);
                my $hour = substr ($created_on,11,2);
                my $minute = substr ($created_on,14,2);
                my $second = substr ($created_on,17,2);

               print "Date: ".$year."-".$month."-".$day." ".$hour.":".$minute.":".$second."\n";
                my $filedate = DateTime->new(
                        year      => $year,
                        month     => $month,
                        day       => $day,
                        hour      => $hour,
                        minute    => $minute,
                        second    => $second,
                        time_zone => 'local',
                );


               print "converted: ".$filedate."\n";


               my $days = $filedate->delta_days($today)->delta_days;

               print "Days difference: ".$days."\n";

               if ( $days > 1 ){
                        print "... sending alert...\n";
               }

           } # if key
        } # foreach
} else {
                        print "ERROR: file ".$filename." does not exist.\n";
}


exit 0;

