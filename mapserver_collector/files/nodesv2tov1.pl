#!/usr/bin/perl

use strict;
use warnings;
use JSON::Parse 'json_file_to_perl';
#use Data::Dumper;
use Data::Dumper qw(Dumper);
use DateTime;
#use Date::Manip;

# define default runtime vars
my $filename = $ARGV[0];
my $destfilename = $ARGV[1];
my $nodecounter_max = 0;
my $nodecounter = 0;
my $nodesfound = 0;
my $created_on;

# my $filename = "nodes.json";

if ( ! $filename | ! $destfilename ) {
                print "USAGE: ./nodesv2tov1.pl <in_nodes_v2_filename> <out_nodes_v1_filename>\n";
	        exit 0;        
	}

# test, if file exist
if ( -f $filename ){

	# Read JSON data from FILE
	my $content = json_file_to_perl ($filename);

	 # print ref $content, "\n";

	foreach my $key ( keys %$content ) {
	   # print $key, " => ", $content->{$key},"\n";
	     if ( $key eq 'timestamp' ){
	       print "timestamp found : ";
	       $created_on = $content->{$key};
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

	      } # if key timestamp
              if ( $key eq 'nodes' ){
	                   $nodesfound=1; 
		#	foreach my @node 
              } # if key nodes         


	} # foreach keys

        if ( $nodesfound ) {
	        print "found nodes array...\n"; 

	        open(my $nl, '>', $destfilename) || die $!;

		while ( $content->{'nodes'}->[$nodecounter_max] ){
                   # just count to max values
                   # print $nodecounter_max.": ".$content->{'nodes'}->[$nodecounter_max]->{'nodeinfo'}->{'node_id'}."\n";
                   $nodecounter_max++;
                }
	        $nodecounter_max --;
                print "Records: ".$nodecounter_max."\n";	

		# print Header to file
		print $nl '{"version":1,"Generator":"nodesv2tov1.pl","timestamp":"'.$created_on.'","nodes":{';

                # Process array for each of nodecounter-max nodes:
                for (my $i = 0; $i < $nodecounter_max; $i++){
                        # Nodes value parsing
			  # print "nodeid: ".$content->{'nodes'}->[$i]->{'nodeinfo'}->{'node_id'};
			print $nl '"'.$content->{'nodes'}->[$i]->{'nodeinfo'}->{'node_id'}.'":{';
			  # print "firstseen: ".$content->{'nodes'}->[$i]->{'firstseen'};
			print $nl '"firstseen":"'.$content->{'nodes'}->[$i]->{'firstseen'}.'","';
                          #  print "lastseen: ".$content->{'nodes'}->[$i]->{'lastseen'};
			print $nl 'lastseen":"'.$content->{'nodes'}->[$i]->{'lastseen'}.'",';
			  # print "+flags: online: ";
                        if ( $content->{'nodes'}->[$i]->{'flags'} ) {
			   print $nl '"flags":{';
		           if ( $content->{'nodes'}->[$i]->{'flags'}->{'online'} ){
			      # print "true";
			      print $nl '"online":true';
			   } else {
			      # print "false";
			      print $nl '"online":false';
			   }
			   # print "gateway: ";
			   if ( $content->{'nodes'}->[$i]->{'flags'}->{'gateway'} ){
			      # print "true";
			      print $nl ',"gateway":true';
			   } else {
			      # print "false";
			      print $nl ',"gateway":false';
			   }
			   print $nl '},';
			}
		           # print "+statistics: node_id: ".$content->{'nodes'}->[$i]->{'statistics'}->{'node_id'}; 
			print $nl '"statistics":{"node_id":"'.$content->{'nodes'}->[$i]->{'statistics'}->{'node_id'}.'"';
			   # print "clients: ".$content->{'nodes'}->[$i]->{'statistics'}->{'clients'};
			print $nl ',"clients":'.$content->{'nodes'}->[$i]->{'statistics'}->{'clients'};
                        if ( $content->{'nodes'}->[$i]->{'statistics'}->{'rootfs_usage'}) {
			    # print "rootfs_usage: ".$content->{'nodes'}->[$i]->{'statistics'}->{'rootfs_usage'};
			    print $nl ',"rootfs_usage":'.$content->{'nodes'}->[$i]->{'statistics'}->{'rootfs_usage'};
			}
			   # print "memory_usage: ".$content->{'nodes'}->[$i]->{'statistics'}->{'memory_usage'};
			print $nl ',"memory_usage":'.$content->{'nodes'}->[$i]->{'statistics'}->{'memory_usage'};
			   # print "uptime: ".$content->{'nodes'}->[$i]->{'statistics'}->{'uptime'};
                        print $nl ',"uptime":'.$content->{'nodes'}->[$i]->{'statistics'}->{'uptime'};
			   # print "idletime: ".$content->{'nodes'}->[$i]->{'statistics'}->{'idletime'};
			print $nl ',"idletime":'.$content->{'nodes'}->[$i]->{'statistics'}->{'idletime'};
			if ( $content->{'nodes'}->[$i]->{'statistics'}->{'gateway'} ) {
			    # print "gateway: ".$content->{'nodes'}->[$i]->{'statistics'}->{'gateway'};
			    print $nl ',"gateway":"'.$content->{'nodes'}->[$i]->{'statistics'}->{'gateway'}.'"';
			}
			   # print "-processes: total: ".$content->{'nodes'}->[$i]->{'statistics'}->{'processes'}->{'total'};
			print $nl ',"processes":{"total":'.$content->{'nodes'}->[$i]->{'statistics'}->{'processes'}->{'total'};
			   # print "running: ".$content->{'nodes'}->[$i]->{'statistics'}->{'processes'}->{'running'};
			print $nl ',"running":'.$content->{'nodes'}->[$i]->{'statistics'}->{'processes'}->{'running'}.'}';
			   # print "-traffic: -tx: bytes: ".$content->{'nodes'}->[$i]->{'statistics'}->{'traffic'}->{'tx'}->{'bytes'};
			print $nl ',"traffic":{"tx":{"bytes":'.$content->{'nodes'}->[$i]->{'statistics'}->{'traffic'}->{'tx'}->{'bytes'};
			   # print "packets: ".$content->{'nodes'}->[$i]->{'statistics'}->{'traffic'}->{'tx'}->{'packets'};
			print $nl ',"packets":'.$content->{'nodes'}->[$i]->{'statistics'}->{'traffic'}->{'tx'}->{'packets'};
			   # print "dropped: ".$content->{'nodes'}->[$i]->{'statistics'}->{'traffic'}->{'tx'}->{'dropped'};
			print $nl ',"dropped":'.$content->{'nodes'}->[$i]->{'statistics'}->{'traffic'}->{'tx'}->{'dropped'}.'}';
			  # print "+rx: bytes: ".$content->{'nodes'}->[$i]->{'statistics'}->{'traffic'}->{'rx'}->{'bytes'};
			print $nl ',"rx":{"bytes":'.$content->{'nodes'}->[$i]->{'statistics'}->{'traffic'}->{'rx'}->{'bytes'};
			  # print "packets: ".$content->{'nodes'}->[$i]->{'statistics'}->{'traffic'}->{'rx'}->{'packets'};
			print $nl ',"packets":'.$content->{'nodes'}->[$i]->{'statistics'}->{'traffic'}->{'rx'}->{'packets'}.'}';
			  # print "+forward: bytes: ".$content->{'nodes'}->[$i]->{'statistics'}->{'traffic'}->{'forward'}->{'bytes'};
			if ( $content->{'nodes'}->[$i]->{'statistics'}->{'traffic'}->{'forward'} ) {
			     print $nl ',"forward":{'; 
			     if ( $content->{'nodes'}->[$i]->{'statistics'}->{'traffic'}->{'forward'}->{'bytes'}  ) {
		   	        print $nl '"bytes":'.$content->{'nodes'}->[$i]->{'statistics'}->{'traffic'}->{'forward'}->{'bytes'};
			        # print "packets: ".$content->{'nodes'}->[$i]->{'statistics'}->{'traffic'}->{'forward'}->{'packets'};
			        print $nl ',"packets":'.$content->{'nodes'}->[$i]->{'statistics'}->{'traffic'}->{'forward'}->{'packets'};
			     }
			     print $nl '}';
			}
			  # print "+mgmt_tx: bytes: ".$content->{'nodes'}->[$i]->{'statistics'}->{'traffic'}->{'mgmt_tx'}->{'bytes'};
			print $nl ',"mgmt_tx":{"bytes":'.$content->{'nodes'}->[$i]->{'statistics'}->{'traffic'}->{'mgmt_tx'}->{'bytes'};
			  # print "packets: ".$content->{'nodes'}->[$i]->{'statistics'}->{'traffic'}->{'mgmt_tx'}->{'packets'};
			print $nl ',"packets":'.$content->{'nodes'}->[$i]->{'statistics'}->{'traffic'}->{'mgmt_tx'}->{'packets'}.'}';
			  # print "+mgmt_rx: bytes: ".$content->{'nodes'}->[$i]->{'statistics'}->{'traffic'}->{'mgmt_rx'}->{'bytes'};
			print $nl ',"mgmt_rx":{"bytes":'.$content->{'nodes'}->[$i]->{'statistics'}->{'traffic'}->{'mgmt_rx'}->{'bytes'};
			  # print "packets: ".$content->{'nodes'}->[$i]->{'statistics'}->{'traffic'}->{'mgmt_rx'}->{'packets'};
			print $nl ',"packets":'.$content->{'nodes'}->[$i]->{'statistics'}->{'traffic'}->{'mgmt_rx'}->{'packets'}.'}}}';
			  # print "+nodeinfo: node_id: ".$content->{'nodes'}->[$i]->{'nodeinfo'}->{'node_id'};
			print $nl ',"nodeinfo":{"node_id":"'.$content->{'nodes'}->[$i]->{'nodeinfo'}->{'node_id'}.'"';
			  # print "+network: mac: ".$content->{'nodes'}->[$i]->{'nodeinfo'}->{'network'}->{'mac'};
			print $nl ',"network":{"mac":"'.$content->{'nodes'}->[$i]->{'nodeinfo'}->{'network'}->{'mac'}.'"';
			  # print "+addresses: ";
			print $nl ',"addresses":[';
			if ( $content->{'nodes'}->[$i]->{'nodeinfo'}->{'network'}->{'addresses'}->[0] ) {
			    # print "0: ".$content->{'nodes'}->[$i]->{'nodeinfo'}->{'network'}->{'addresses'}->[0];
			    print $nl '"'.$content->{'nodes'}->[$i]->{'nodeinfo'}->{'network'}->{'addresses'}->[0].'"';
			}
			if ( $content->{'nodes'}->[$i]->{'nodeinfo'}->{'network'}->{'addresses'}->[1] ) {
			    # print "1: ".$content->{'nodes'}->[$i]->{'nodeinfo'}->{'network'}->{'addresses'}->[1]; 
			    print $nl ',"'.$content->{'nodes'}->[$i]->{'nodeinfo'}->{'network'}->{'addresses'}->[1].'"';
			}
			print $nl '],"mesh":{"bat0":{"interfaces":{';
			if ( $content->{'nodes'}->[$i]->{'nodeinfo'}->{'network'}->{'mesh'}->{'bat0'}->{'interfaces'}->{'wireless'}->[0] ){ 
			    # print "+mesh: +bat0: +interfaces: +wireless: 0: ".$content->{'nodes'}->[$i]->{'nodeinfo'}->{'network'}->{'mesh'}->{'bat0'}->{'interfaces'}->{'wireless'}->[0];
                            print $nl '"wireless":["'.$content->{'nodes'}->[$i]->{'nodeinfo'}->{'network'}->{'mesh'}->{'bat0'}->{'interfaces'}->{'wireless'}->[0].'"';
			    if ( $content->{'nodes'}->[$i]->{'nodeinfo'}->{'network'}->{'mesh'}->{'bat0'}->{'interfaces'}->{'wireless'}->[1] ){
			       # print "1: ".$content->{'nodes'}->[$i]->{'nodeinfo'}->{'network'}->{'mesh'}->{'bat0'}->{'interfaces'}->{'wireless'}->[1];
			       print $nl ',"'.$content->{'nodes'}->[$i]->{'nodeinfo'}->{'network'}->{'mesh'}->{'bat0'}->{'interfaces'}->{'wireless'}->[1].'"';
			    }
			print $nl '],';
			}
			print $nl '"other":[';
                        if ( $content->{'nodes'}->[$i]->{'nodeinfo'}->{'network'}->{'mesh'}->{'bat0'}->{'interfaces'}->{'other'}->[0] ){
			    # print "+other 0: ".$content->{'nodes'}->[$i]->{'nodeinfo'}->{'network'}->{'mesh'}->{'bat0'}->{'interfaces'}->{'other'}->[0];
			    print $nl '"'.$content->{'nodes'}->[$i]->{'nodeinfo'}->{'network'}->{'mesh'}->{'bat0'}->{'interfaces'}->{'other'}->[0].'"';
			}
			if ( $content->{'nodes'}->[$i]->{'nodeinfo'}->{'network'}->{'mesh'}->{'bat0'}->{'interfaces'}->{'other'}->[1] ){
			    # print "1: ".$content->{'nodes'}->[$i]->{'nodeinfo'}->{'network'}->{'mesh'}->{'bat0'}->{'interfaces'}->{'other'}->[1];
			    print $nl ',"'.$content->{'nodes'}->[$i]->{'nodeinfo'}->{'network'}->{'mesh'}->{'bat0'}->{'interfaces'}->{'other'}->[1].'"';
			}	
			print $nl ']}}},';
			if ($content->{'nodes'}->[$i]->{'nodeinfo'}->{'network'}->{'mesh_interfaces'}) {
			    # print "mesh_interfaces: ".$content->{'nodes'}->[$i]->{'nodeinfo'}->{'network'}->{'mesh_interfaces'};
			    print $nl '"mesh_interfaces":"'.$content->{'nodes'}->[$i]->{'nodeinfo'}->{'network'}->{'mesh_interfaces'}.'"},';
			} else {
			   # print "mesh_interfaces: null";
			   print $nl '"mesh_interfaces":null},';
			}
			print $nl '"owner":';
			if ( $content->{'nodes'}->[$i]->{'nodeinfo'}->{'owner'} ){
			    # print "+owner: contact: ".$content->{'nodes'}->[$i]->{'nodeinfo'}->{'owner'}->{'contact'};
                            print $nl '{"contact":"'.$content->{'nodes'}->[$i]->{'nodeinfo'}->{'owner'}->{'contact'}.'"},';
			} else {
			    # print "owner: null";
			    print $nl 'null,';
			}
			# print "+system: site_code: ".$content->{'nodes'}->[$i]->{'nodeinfo'}->{'system'}->{'site_code'};
                        if ( $content->{'nodes'}->[$i]->{'nodeinfo'}->{'system'}->{'site_code'}  ) {
			   print $nl '"system":{"site_code":"'.$content->{'nodes'}->[$i]->{'nodeinfo'}->{'system'}->{'site_code'}.'"},';
			} else {
			   print $nl '"system":{"site_code":"unknown"},';
			}
			   # print "hostname: ".$content->{'nodes'}->[$i]->{'nodeinfo'}->{'hostname'};
			print $nl '"hostname":"'.$content->{'nodes'}->[$i]->{'nodeinfo'}->{'hostname'}.'",';
			if ( $content->{'nodes'}->[$i]->{'nodeinfo'}->{'location'}  ) {
			    print $nl '"location":{';
			    # print "+location: longitude: ".$content->{'nodes'}->[$i]->{'nodeinfo'}->{'location'}->{'longitude'};
			    print $nl '"longitude":'.$content->{'nodes'}->[$i]->{'nodeinfo'}->{'location'}->{'longitude'};
			    # print "latitude: ".$content->{'nodes'}->[$i]->{'nodeinfo'}->{'location'}->{'latitude'};
			    print $nl ',"latitude":'.$content->{'nodes'}->[$i]->{'nodeinfo'}->{'location'}->{'latitude'};
			    if ( $content->{'nodes'}->[$i]->{'nodeinfo'}->{'location'}->{'altitude'}  ) {
			       # print "altitude: ".$content->{'nodes'}->[$i]->{'nodeinfo'}->{'location'}->{'altitude'};
			       print $nl ',"altitude":'.$content->{'nodes'}->[$i]->{'nodeinfo'}->{'location'}->{'altitude'}; 
			    }
			    print $nl '},';
			}
			   # print "+software";
			   print $nl '"software":{"autoupdater":{';
			if ( $content->{'nodes'}->[$i]->{'nodeinfo'}->{'software'}->{'autoupdater'}  ) {
				# print "enabled: ";
				if ( $content->{'nodes'}->[$i]->{'nodeinfo'}->{'software'}->{'autoupdater'}->{'enabled'} ){
				    # print "true";
				    print $nl '"enabled":true';
				} else {
				    # print "false";
				    print $nl '"enabled":false';
				}
			        if ($content->{'nodes'}->[$i]->{'nodeinfo'}->{'software'}->{'autoupdater'}->{'branch'} ) {

					# print "branch: ".$content->{'nodes'}->[$i]->{'nodeinfo'}->{'software'}->{'autoupdater'}->{'branch'};
					print $nl ',"branch":"'.$content->{'nodes'}->[$i]->{'nodeinfo'}->{'software'}->{'autoupdater'}->{'branch'}.'"';
				}
			}
			   # print "+batman-adv: version: ".$content->{'nodes'}->[$i]->{'nodeinfo'}->{'software'}->{'batman-adv'}->{'version'};
			print $nl '},"batman-adv":{"version":"'.$content->{'nodes'}->[$i]->{'nodeinfo'}->{'software'}->{'batman-adv'}->{'version'}.'"';
			if ( $content->{'nodes'}->[$i]->{'nodeinfo'}->{'software'}->{'batman-adv'}->{'compat'} ) {
			    # print "compat: ".$content->{'nodes'}->[$i]->{'nodeinfo'}->{'software'}->{'batman-adv'}->{'compat'};
			    print $nl ',"compat":'.$content->{'nodes'}->[$i]->{'nodeinfo'}->{'software'}->{'batman-adv'}->{'compat'}.'';
			}
			print $nl '},';
			   # print "+firmware: base: ".$content->{'nodes'}->[$i]->{'nodeinfo'}->{'software'}->{'firmware'}->{'base'};
			print $nl '"babeld":{},"fastd":{},"firmware":{"base":"'.$content->{'nodes'}->[$i]->{'nodeinfo'}->{'software'}->{'firmware'}->{'base'}.'",';
			# print "release: ".$content->{'nodes'}->[$i]->{'nodeinfo'}->{'software'}->{'firmware'}->{'release'};
			print $nl '"release":"'.$content->{'nodes'}->[$i]->{'nodeinfo'}->{'software'}->{'firmware'}->{'release'}.'"},';
			   # print "status-page: api: ".$content->{'nodes'}->[$i]->{'nodeinfo'}->{'software'}->{'status-page'}->{'api'};
			print $nl '"status-page":{"api":'.$content->{'nodes'}->[$i]->{'nodeinfo'}->{'software'}->{'status-page'}->{'api'}.'}},';
			   # print "+hardware: nproc: ".$content->{'nodes'}->[$i]->{'nodeinfo'}->{'hardware'}->{'nproc'};
			print $nl '"hardware":{"nproc":'.$content->{'nodes'}->[$i]->{'nodeinfo'}->{'hardware'}->{'nproc'}.',';
			   # print "model: ".$content->{'nodes'}->[$i]->{'nodeinfo'}->{'hardware'}->{'model'};
			if ( $content->{'nodes'}->[$i]->{'nodeinfo'}->{'hardware'}->{'model'} ) {
			    print $nl '"model":"'.$content->{'nodes'}->[$i]->{'nodeinfo'}->{'hardware'}->{'model'}.'"},';
			} else {
			    print $nl '"model":"unknown"},';	
			}
			   # print "vpn: ";
			print $nl '"vpn":';
			if ( $content->{'nodes'}->[$i]->{'nodeinfo'}->{'vpn'} ) {
				# print "true";
				print $nl 'true}}';
			} else {
				# print "false";
			        print $nl 'false}}';
			}
			if ( $nodecounter < $nodecounter_max-1 ) {
			       print $nl ',';
			}
			# end

			# print "\n\n";
			$nodecounter ++;
		
        	}
		print $nl '}}';
		close ($nl);        
		
}
} else {
			print "ERROR: file ".$filename." does not exist.\n";
}


exit 0;



