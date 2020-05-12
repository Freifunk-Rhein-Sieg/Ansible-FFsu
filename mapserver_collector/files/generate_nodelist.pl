#!/usr/bin/perl
use strict;
use JSON;
use POSIX qw(strftime);

my $node_json_file = "/opt/data/mobilemeshviewer/nodes_v1.json";
my $nodelist_json_file = "/opt/data/mobilemeshviewer/nodelist.json";
my $nodecounter = 0;
my $maxrecords = 0;
# Timestamp Format 2019-02-15T02:22:16+0100
my $date = strftime "%Y-%m-%d", localtime;
my $time = strftime "%H:%M:%S", localtime;
my $timestamp= $date."T".$time."+0100";

main();

sub main {
        my $node_json = &get_node_json();
        for my $node(keys %{$node_json->{'nodes'}}) {
          $maxrecords++;
        }
        open(my $nl, '>', $nodelist_json_file) || die $!;
        # print "Records: ".$maxrecords;
        #print '{"version":"1.0.1","updated_at":"'.$timestamp.'","nodes":[';
        print $nl '{"version":"1.0.1","updated_at":"'.$timestamp.'","nodes":[';
        for my $node(keys %{$node_json->{'nodes'}}) {
           # print '{"id":"'.$node_json->{'nodes'}->{$node}->{'nodeinfo'}->{'node_id'}.'","name":"';
           print $nl '{"id":"'.$node_json->{'nodes'}->{$node}->{'nodeinfo'}->{'node_id'}.'","name":"';
           # print $node_json->{'nodes'}->{$node}->{'nodeinfo'}->{'hostname'}.'",';
           print $nl $node_json->{'nodes'}->{$node}->{'nodeinfo'}->{'hostname'}.'",';
           if ( $node_json->{'nodes'}->{$node}->{'nodeinfo'}->{'location'}->{'latitude'} ){
              # print '"position":{"lat":'.$node_json->{'nodes'}->{$node}->{'nodeinfo'}->{'location'}->{'latitude'}.',"long":';
              print $nl '"position":{"lat":'.$node_json->{'nodes'}->{$node}->{'nodeinfo'}->{'location'}->{'latitude'}.',"long":';
              # print $node_json->{'nodes'}->{$node}->{'nodeinfo'}->{'location'}->{'longitude'}.'},';
              print $nl $node_json->{'nodes'}->{$node}->{'nodeinfo'}->{'location'}->{'longitude'}.'},';
           }
           # print '"status":{"online":';
           print $nl '"status":{"online":';
           if ( $node_json->{'nodes'}->{$node}->{'flags'}->{'online'} ) {
                # print 'true';
                print $nl 'true';
           }else{
                # print 'false';
                print $nl 'false';
           }
           # print ',"lastcontact":"';
           print $nl ',"lastcontact":"';
           # print $node_json->{'nodes'}->{$node}->{'lastseen'}.'","clients":';
           print $nl $node_json->{'nodes'}->{$node}->{'lastseen'}.'","clients":';
           # print $node_json->{'nodes'}->{$node}->{'statistics'}->{'clients'}.'}}';
           print $nl $node_json->{'nodes'}->{$node}->{'statistics'}->{'clients'}.'}}';
           if ( $nodecounter < $maxrecords-1 ){
               # print ',';
               print $nl ',';
           }
           $nodecounter++;
         }
         # print ']}';
         print $nl ']}';
         close($nl);
        # &write_json($node_json);
}

sub write_json {
        my($json) = @_;

        open(my $fh, '>', $node_json_file) || die $!;
        print $fh to_json($json);
        close($fh);
}

sub get_node_json {
        open(my $fh, '<', $node_json_file) || die $!;
        my $json_data = join('',<$fh>);
        close($fh);

        return from_json($json_data);
}

