#!/usr/bin/perl -w
use strict;
use JSON;
use LWP::UserAgent;
use File::Copy;

# copy Source Files
copy("/opt/data/merged/nodes_v1.json","/opt/data/merged/merged_nodes_v1.json") or die "Copy nodes base failed: $!";
copy("/opt/data/merged/graph_v1.json","/opt/data/merged/merged_graph_v1.json") or die "Copy graph base failed: $!";
copy("/opt/data/merged/tdf_nodes_v1.json","/opt/data/merged/merged_tdf_nodes_v1.json")  or die "Copy nodes tdf base failed: $!";
copy("/opt/data/merged/inn_nodes_v1.json","/opt/data/merged/merged_inn_nodes_v1.json")  or die "Copy nodes inn base failed: $!";
copy("/opt/data/merged/flu_nodes_v1.json","/opt/data/merged/merged_flu_nodes_v1.json")  or die "Copy nodes flu base failed: $!";

#
my $json_node_file = '/opt/data/merged/merged_nodes_v1.json';
my $json_graph_file = '/opt/data/merged/merged_graph_v1.json';
my $json_nodelist_file = '/opt/data/merged/merged_nodelist.json';
my %sub_domains = (
    #    'su-su'         => {
    #            'nodes' => 'http://fgw02.freifunk-siegburg.de/01_nodes_v1.json',
    #            'graph' => 'http://fgw02.freifunk-siegburg.de/01_graph_v1.json'
    #    },
        'su-lo'         => {
                'nodes' => 'http://fgw02.freifunk-siegburg.de/03_nodes_v1.json',
                'graph' => 'http://fgw02.freifunk-siegburg.de/03_graph_v1.json'
        },
        'su-snw'            => {
                'nodes' => 'http://fgw03.freifunk-siegburg.de/05_nodes_v1.json',
                'graph' => 'http://fgw03.freifunk-siegburg.de/05_graph_v1.json'
        },
        'su-sa'            => {
                'nodes' => 'http://fgw03.freifunk-siegburg.de/04_nodes_v1.json',
                'graph' => 'http://fgw03.freifunk-siegburg.de/04_graph_v1.json'
        },
        'su-nk'            => {
                'nodes' => 'http://fgw01.freifunk-siegburg.de/07_nodes_v1.json',
                'graph' => 'http://fgw01.freifunk-siegburg.de/07_graph_v1.json'
        },
        'su-ak'            => {
                'nodes' => 'http://fgw04.freifunk-siegburg.de/11_nodes_v1.json',
                'graph' => 'http://fgw04.freifunk-siegburg.de/11_graph_v1.json'
        },
        'su-rhb'            => {
                'nodes' => 'http://fgw04.freifunk-siegburg.de/14_nodes_v1.json',
                'graph' => 'http://fgw04.freifunk-siegburg.de/14_graph_v1.json'
        },
        'tdf-tdf'            => {
                'nodes' => 'https://map.freifunk-rhein-sieg.net/data/merged/tdf_nodes_v1.json',
                'graph' => 'https://map.freifunk-rhein-sieg.net/data/tdf4/tdf/graph.json'
        },
        'tdf-inn'            => {
                'nodes' => 'https://map.freifunk-rhein-sieg.net/data/merged/inn_nodes_v1.json',
                'graph' => 'https://map.freifunk-rhein-sieg.net/data/tdf5/inn/graph.json'
        },
        'tdf-flu'            => {
                'nodes' => 'https://map.freifunk-rhein-sieg.net/data/merged/flu_nodes_v1.json',
                'graph' => 'https://map.freifunk-rhein-sieg.net/data/tdf6/flu/graph.json'
        }

);

&main();

sub main {
        my $rg_node_json = &get_rg_node_json($json_node_file);


        my $sub_node_json = &get_sub_node_json();

        my $rg_graph_json  = &get_rg_graph_json($json_graph_file);

        my $sub_graph_json = &get_sub_graph_json();


        my %node_map;

        my $node_new_i = 0;
        my $node_old_i = 0;

        for my $node(keys(@{$rg_graph_json->{'batadv'}->{'nodes'}})) {
                $node_map{'rg'}{$node_old_i} = $node_new_i;
                $node_old_i++;
                $node_new_i++;
        }

        for my $sub_domain(keys(%{$sub_graph_json})) {
                $node_old_i = 0;
                for my $node(@{$sub_graph_json->{$sub_domain}->{'nodes'}}) {
                        $node_map{$sub_domain}{$node_old_i} = $node_new_i;
                        $rg_graph_json->{'batadv'}->{'nodes'}->[$node_new_i] = $node;
                        $node_old_i++;
                        $node_new_i++;
                }

                for my $link(@{$sub_graph_json->{$sub_domain}->{'links'}}) {
                        $link->{'source'} = $node_map{$sub_domain}{$link->{'source'}};
                        $link->{'target'} = $node_map{$sub_domain}{$link->{'target'}};
                        push(@{$rg_graph_json->{'batadv'}->{'links'}},$link);
                }
        }

        for my $node(keys %{$sub_node_json}) {
                $rg_node_json->{'nodes'}->{$node} = $sub_node_json->{$node};
        }

        &write_json($rg_node_json, $json_node_file);
        &write_json($rg_graph_json, $json_graph_file);

        # copy merged Files
        copy("/opt/data/merged/merged_nodes_v1.json","/opt/data/mobilemeshviewer/nodes_v1.json") or die "Copy merged nodes base failed: $!";
        copy("/opt/data/merged/merged_graph_v1.json","/opt/data/mobilemeshviewer/graph_v1.json") or die "Copy merged graph base failed: $!";


}

sub write_json {
        my($json,$file) = @_;

        open(my $fh, '>:encoding(UTF-8)', $file) || die $!;
                print $fh to_json($json);
        close($fh);
}

sub get_rg_node_json {
        my($file) = @_;

        open(my $fh, '<', $file) || die $!;
        my $json_data = join('',<$fh>);
        close($fh);

        return from_json($json_data);
}

sub get_rg_graph_json {
        my($file) = @_;

        open(my $fh, '<', $file) || die $!;
        my $json_data = join('',<$fh>);
        close($fh);

        return from_json($json_data);
}

sub get_sub_graph_json {
        my $return;

        eval {
                for my $sub_domain(keys %sub_domains) {
                        print "GetGraph: $sub_domain\n";
                        my $ua = LWP::UserAgent->new();
                        my $res = $ua->get($sub_domains{$sub_domain}{'graph'});

                        if($res->is_success) {
                                my $json_data = from_json($res->decoded_content);

                                for my $node(@{$json_data->{'batadv'}->{'nodes'}}) {
                                        $node->{'node_id'} = $node->{'node_id'};
                                        push(@{$return->{$sub_domain}->{'nodes'}}, $node);
                                }
                                for my $link(@{$json_data->{'batadv'}->{'links'}}) {
                                        push(@{$return->{$sub_domain}->{'links'}}, $link);
                                }
                        } else {
                                print $sub_domain.":\n".$res->decoded_content."\n".$res->status_line."\n\n";
                        }

                }
        }; warn() if $@;

        return $return;
}

sub get_sub_node_json {
        my $return;

        eval {
        for my $sub_domain(keys %sub_domains) {
                print "GetNodes: $sub_domain\n";
                my $ua = LWP::UserAgent->new();
                my $res = $ua->get($sub_domains{$sub_domain}{'nodes'});

                if($res->is_success) {
                        my $json_data = from_json($res->decoded_content);
                        for my $node(keys(%{$json_data->{'nodes'}})) {
                                $json_data->{'nodes'}->{$node}->{'nodeinfo'}->{'node_id'} = $json_data->{'nodes'}->{$node}->{'nodeinfo'}->{'node_id'};
                                $return->{$node} = $json_data->{'nodes'}->{$node};
                        }
                } else {
                        print "$sub_domain\n: $res->decoded_content\n$res->status_line\n\n";
                }
        }
        }; warn() if $@;
        return $return;
}

