#!/usr/bin/perl

use DBI;
use Relations;
use Relations::Query;
use Relations::Family;
use Relations::Family::Member;
use Relations::Family::Lineage;
use Relations::Family::Rivalry;

configure_settings('fam_test','root','','localhost','3306') unless -e "Settings.pm";

eval "use Settings";

$dsn = "DBI:mysql:mysql:$host:$port";

$dbh = DBI->connect($dsn,$username,$password,{PrintError => 1, RaiseError => 0});

$abs = new Relations::Abstract($dbh);

create_finder($abs,$database);
$fam = relate_finder($abs,$database);

$lin = new Relations::Family::Lineage(-parent_member => 'dude',
                                      -parent_field  => 'dude_id',
                                      -child_member  => 'sweet',
                                      -child_field   => 'sweet_id');

die "Lineage create failed" unless (($lin->{parent_member} eq 'dude') and 
                                    ($lin->{parent_field} eq 'dude_id') and 
                                    ($lin->{child_member} eq 'sweet') and 
                                    ($lin->{child_field} eq 'sweet_id'));

$riv = new Relations::Family::Rivalry(-brother_member => 'yang',
                                      -brother_field  => 'yang_id',
                                      -sister_member  => 'yin',
                                      -sister_field   => 'yin_id');

die "Rivalry create failed" unless (($riv->{brother_member} eq 'yang') and 
                                    ($riv->{brother_field} eq 'yang_id') and 
                                    ($riv->{sister_member} eq 'yin') and 
                                    ($riv->{sister_field} eq 'yin_id'));

$query_one = "select barney as fife " . 
             "from moogoo as green_teeth ".
             "where flotsam>jetsam " .
             "group by denali " .
             "having fortune=cookie " .
             "order by was,is,will ".
             "limit 1";
    
$qry = new Relations::Query(-select   => {'fife' => 'barney'},
                            -from     => {'green_teeth' => 'moogoo'},
                            -where    => "flotsam>jetsam",
                            -group_by => "denali",
                            -having   => {'fortune' => 'cookie'},
                            -order_by => ['was','is','will'],
                            -limit    => '1');

$mem = new Relations::Family::Member(-name     => 'rand',
                                     -label    => 'Random Thoughts',
                                     -database => 'mindtrip',
                                     -table    => 'rand_thoughts',
                                     -id_field => 'rd_id',
                                     -query    => $qry);

die "Member create failed basic" unless (($mem->{name} eq 'rand')  and 
                                         ($mem->{label} eq 'Random Thoughts') and 
                                         ($mem->{database} eq 'mindtrip') and 
                                         ($mem->{table} eq 'rand_thoughts') and 
                                         ($mem->{id_field} eq 'rd_id')  and 
                                         ($mem->{query}->get() eq $query_one));

die "Member create failed chosen" unless (($mem->{chosen_ids_count} == 0)  and 
                                          ($mem->{chosen_ids_string} eq '')  and 
                                          (scalar @{$mem->{chosen_ids_arrayref}} == 0) and
                                          (scalar @{$mem->{chosen_ids_selectref}} == 0) and
                                          ($mem->{chosen_labels_string} eq '')  and 
                                          (scalar @{$mem->{chosen_labels_arrayref}} == 0) and 
                                          (scalar keys %{$mem->{chosen_labels_hashref}} == 0) and 
                                          (scalar keys %{$mem->{chosen_labels_selectref}} == 0));

die "Member create failed available" unless (($mem->{available_ids_count} == 0)  and 
                                             (scalar @{$mem->{available_ids_arrayref}} == 0) and
                                             (scalar @{$mem->{available_ids_selectref}} == 0) and
                                             (scalar @{$mem->{available_labels_arrayref}} == 0) and 
                                             (scalar keys %{$mem->{available_labels_hashref}} == 0) and 
                                             (scalar keys %{$mem->{available_labels_selectref}} == 0));

die "Member create failed select" unless (($mem->{filter} eq '') and 
                                          ($mem->{match} == 0) and 
                                          ($mem->{group} == 0) and 
                                          ($mem->{limit} eq '') and 
                                          ($mem->{ignore} == 0));

$fam = new Relations::Family(-abstract  => 'data stuff');

die "Family create failed" unless (($fam->{abstract} eq 'data stuff')  and 
                                   (scalar @{$fam->{members_arrayref}} == 0) and 
                                   (scalar keys %{$fam->{names_hashref}} == 0) and 
                                   (scalar keys %{$fam->{labels_hashref}} == 0));

$fam->add_member(-member => $mem);

die "Basic add member failed" unless (($fam->{members_arrayref}->[0] == $mem) and
                                      ($fam->{names_hashref}->{'rand'} == $mem) and
                                      ($fam->{labels_hashref}->{'Random Thoughts'} == $mem));

$fam->add_member(-name     => 'donkey',
                 -label    => 'Donkey Biter',
                 -database => 'dweebas',
                 -table    => 'donkeys_damnit',
                 -id_field => 'freak_id',
                 -query    => $qry);

die "Regular add member failed" unless (($fam->{members_arrayref}->[1]->{name} eq 'donkey') and
                                        ($fam->{members_arrayref}->[1]->{label} eq 'Donkey Biter') and
                                        ($fam->{members_arrayref}->[1]->{database} eq 'dweebas') and
                                        ($fam->{members_arrayref}->[1]->{table} eq 'donkeys_damnit') and
                                        ($fam->{members_arrayref}->[1]->{id_field} eq 'freak_id') and
                                        ($fam->{members_arrayref}->[1]->{query} == $qry) and
                                        ($fam->{names_hashref}->{'donkey'} == $fam->{members_arrayref}->[1]) and
                                        ($fam->{labels_hashref}->{'Donkey Biter'} == $fam->{members_arrayref}->[1]));

$fam->add_member(-name     => 'vb',
                 -label    => 'Venga Boyz',
                 -database => 'songs',
                 -table    => 'we_like',
                 -id_field => 'to_party',
                 -select   => {'hey' => 'now'},
                 -from     => {'nappy' => 'winamp'},
                 -where    => {'happines' => 'justaroundthecorner'},
                 -group_by => "nikki",
                 -having   => {'smile' => 'look'},
                 -order_by => ['before','during','after'],
                 -limit    => '500');

$query_two = "select now as hey " . 
             "from winamp as nappy ".
             "where happines=justaroundthecorner " .
             "group by nikki " .
             "having smile=look " .
             "order by before,during,after ".
             "limit 500";
    
die "Full add member failed" unless (($fam->{members_arrayref}->[2]->{name} eq 'vb') and
                                      ($fam->{members_arrayref}->[2]->{label} eq 'Venga Boyz') and
                                      ($fam->{members_arrayref}->[2]->{database} eq 'songs') and
                                      ($fam->{members_arrayref}->[2]->{table} eq 'we_like') and
                                      ($fam->{members_arrayref}->[2]->{id_field} eq 'to_party') and
                                      ($fam->{members_arrayref}->[2]->{query}->get() == $query_two) and
                                      ($fam->{names_hashref}->{'vb'} == $fam->{members_arrayref}->[2]) and
                                      ($fam->{labels_hashref}->{'Venga Boyz'} == $fam->{members_arrayref}->[2]));

$fam->add_lineage(-parent_name  => 'vb',
                  -parent_field => 'wakko',
                  -child_name   => 'donkey',
                  -child_field  => 'jakko');

die "Name add lineage failed" unless (($fam->{names_hashref}->{'vb'}->{children_ref}->[0]->{parent_member} == $fam->{names_hashref}->{'vb'})  and 
                                      ($fam->{names_hashref}->{'vb'}->{children_ref}->[0]->{parent_field} eq 'wakko')  and 
                                      ($fam->{names_hashref}->{'vb'}->{children_ref}->[0]->{child_member} == $fam->{names_hashref}->{'donkey'})  and 
                                      ($fam->{names_hashref}->{'vb'}->{children_ref}->[0]->{child_field} eq 'jakko')  and 
                                      ($fam->{names_hashref}->{'donkey'}->{parents_ref}->[0]->{parent_member} == $fam->{names_hashref}->{'vb'})  and 
                                      ($fam->{names_hashref}->{'donkey'}->{parents_ref}->[0]->{parent_field} eq 'wakko')  and 
                                      ($fam->{names_hashref}->{'donkey'}->{parents_ref}->[0]->{child_member} == $fam->{names_hashref}->{'donkey'})  and 
                                      ($fam->{names_hashref}->{'donkey'}->{parents_ref}->[0]->{child_field} eq 'jakko'));

$fam->add_lineage(-parent_label => 'Random Thoughts',
                  -parent_field => 'sally',
                  -child_label   => 'Venga Boyz',
                  -child_field  => 'wally');

die "Label add lineage failed" unless (($fam->{names_hashref}->{'rand'}->{children_ref}->[0]->{parent_member} == $fam->{names_hashref}->{'rand'})  and 
                                       ($fam->{names_hashref}->{'rand'}->{children_ref}->[0]->{parent_field} eq 'sally')  and 
                                       ($fam->{names_hashref}->{'rand'}->{children_ref}->[0]->{child_member} == $fam->{names_hashref}->{'vb'})  and 
                                       ($fam->{names_hashref}->{'rand'}->{children_ref}->[0]->{child_field} eq 'wally')  and 
                                       ($fam->{names_hashref}->{'vb'}->{parents_ref}->[0]->{parent_member} == $fam->{names_hashref}->{'rand'})  and 
                                       ($fam->{names_hashref}->{'vb'}->{parents_ref}->[0]->{parent_field} eq 'sally')  and 
                                       ($fam->{names_hashref}->{'vb'}->{parents_ref}->[0]->{child_member} == $fam->{names_hashref}->{'vb'})  and 
                                       ($fam->{names_hashref}->{'vb'}->{parents_ref}->[0]->{child_field} eq 'wally'));

$fam->add_lineage(-parent_member => $fam->{names_hashref}->{'donkey'},
                  -parent_field  => 'murtle',
                  -child_member  => $fam->{names_hashref}->{'rand'},
                  -child_field   => 'turtle');

die "Member add lineage failed" unless (($fam->{names_hashref}->{'donkey'}->{children_ref}->[0]->{parent_member} == $fam->{names_hashref}->{'donkey'})  and 
                                        ($fam->{names_hashref}->{'donkey'}->{children_ref}->[0]->{parent_field} eq 'murtle')  and 
                                        ($fam->{names_hashref}->{'donkey'}->{children_ref}->[0]->{child_member} == $fam->{names_hashref}->{'rand'})  and 
                                        ($fam->{names_hashref}->{'donkey'}->{children_ref}->[0]->{child_field} eq 'turtle')  and 
                                        ($fam->{names_hashref}->{'rand'}->{parents_ref}->[0]->{parent_member} == $fam->{names_hashref}->{'donkey'})  and 
                                        ($fam->{names_hashref}->{'rand'}->{parents_ref}->[0]->{parent_field} eq 'murtle')  and 
                                        ($fam->{names_hashref}->{'rand'}->{parents_ref}->[0]->{child_member} == $fam->{names_hashref}->{'rand'})  and 
                                        ($fam->{names_hashref}->{'rand'}->{parents_ref}->[0]->{child_field} eq 'turtle'));

$new_lin = new Relations::Family::Lineage(-parent_member => $fam->{names_hashref}->{'vb'},
                                          -parent_field  => 'heehee',
                                          -child_member  => $fam->{names_hashref}->{'rand'},
                                          -child_field   => 'haahaa');

$fam->add_lineage(-lineage => $new_lin);

die "Direct add lineage failed" unless (($fam->{names_hashref}->{'vb'}->{children_ref}->[1]->{parent_member} == $fam->{names_hashref}->{'vb'})  and 
                                        ($fam->{names_hashref}->{'vb'}->{children_ref}->[1]->{parent_field} eq 'heehee')  and 
                                        ($fam->{names_hashref}->{'vb'}->{children_ref}->[1]->{child_member} == $fam->{names_hashref}->{'rand'})  and 
                                        ($fam->{names_hashref}->{'vb'}->{children_ref}->[1]->{child_field} eq 'haahaa')  and 
                                        ($fam->{names_hashref}->{'rand'}->{parents_ref}->[1]->{parent_member} == $fam->{names_hashref}->{'vb'})  and 
                                        ($fam->{names_hashref}->{'rand'}->{parents_ref}->[1]->{parent_field} eq 'heehee')  and 
                                        ($fam->{names_hashref}->{'rand'}->{parents_ref}->[1]->{child_member} == $fam->{names_hashref}->{'rand'})  and 
                                        ($fam->{names_hashref}->{'rand'}->{parents_ref}->[1]->{child_field} eq 'haahaa'));

$fam->add_rivalry(-brother_name  => 'vb',
                  -brother_field => 'wakko',
                  -sister_name   => 'donkey',
                  -sister_field  => 'jakko');

die "Name add rivalry failed" unless (($fam->{names_hashref}->{'vb'}->{sisters_ref}->[0]->{brother_member} == $fam->{names_hashref}->{'vb'})  and 
                                      ($fam->{names_hashref}->{'vb'}->{sisters_ref}->[0]->{brother_field} eq 'wakko')  and 
                                      ($fam->{names_hashref}->{'vb'}->{sisters_ref}->[0]->{sister_member} == $fam->{names_hashref}->{'donkey'})  and 
                                      ($fam->{names_hashref}->{'vb'}->{sisters_ref}->[0]->{sister_field} eq 'jakko')  and 
                                      ($fam->{names_hashref}->{'donkey'}->{brothers_ref}->[0]->{brother_member} == $fam->{names_hashref}->{'vb'})  and 
                                      ($fam->{names_hashref}->{'donkey'}->{brothers_ref}->[0]->{brother_field} eq 'wakko')  and 
                                      ($fam->{names_hashref}->{'donkey'}->{brothers_ref}->[0]->{sister_member} == $fam->{names_hashref}->{'donkey'})  and 
                                      ($fam->{names_hashref}->{'donkey'}->{brothers_ref}->[0]->{sister_field} eq 'jakko'));

$fam->add_rivalry(-brother_label => 'Random Thoughts',
                  -brother_field => 'sally',
                  -sister_label   => 'Venga Boyz',
                  -sister_field  => 'wally');

die "Label add rivalry failed" unless (($fam->{names_hashref}->{'rand'}->{sisters_ref}->[0]->{brother_member} == $fam->{names_hashref}->{'rand'})  and 
                                       ($fam->{names_hashref}->{'rand'}->{sisters_ref}->[0]->{brother_field} eq 'sally')  and 
                                       ($fam->{names_hashref}->{'rand'}->{sisters_ref}->[0]->{sister_member} == $fam->{names_hashref}->{'vb'})  and 
                                       ($fam->{names_hashref}->{'rand'}->{sisters_ref}->[0]->{sister_field} eq 'wally')  and 
                                       ($fam->{names_hashref}->{'vb'}->{brothers_ref}->[0]->{brother_member} == $fam->{names_hashref}->{'rand'})  and 
                                       ($fam->{names_hashref}->{'vb'}->{brothers_ref}->[0]->{brother_field} eq 'sally')  and 
                                       ($fam->{names_hashref}->{'vb'}->{brothers_ref}->[0]->{sister_member} == $fam->{names_hashref}->{'vb'})  and 
                                       ($fam->{names_hashref}->{'vb'}->{brothers_ref}->[0]->{sister_field} eq 'wally'));

$fam->add_rivalry(-brother_member => $fam->{names_hashref}->{'donkey'},
                  -brother_field  => 'murtle',
                  -sister_member  => $fam->{names_hashref}->{'rand'},
                  -sister_field   => 'turtle');

die "Member add rivalry failed" unless (($fam->{names_hashref}->{'donkey'}->{sisters_ref}->[0]->{brother_member} == $fam->{names_hashref}->{'donkey'})  and 
                                        ($fam->{names_hashref}->{'donkey'}->{sisters_ref}->[0]->{brother_field} eq 'murtle')  and 
                                        ($fam->{names_hashref}->{'donkey'}->{sisters_ref}->[0]->{sister_member} == $fam->{names_hashref}->{'rand'})  and 
                                        ($fam->{names_hashref}->{'donkey'}->{sisters_ref}->[0]->{sister_field} eq 'turtle')  and 
                                        ($fam->{names_hashref}->{'rand'}->{brothers_ref}->[0]->{brother_member} == $fam->{names_hashref}->{'donkey'})  and 
                                        ($fam->{names_hashref}->{'rand'}->{brothers_ref}->[0]->{brother_field} eq 'murtle')  and 
                                        ($fam->{names_hashref}->{'rand'}->{brothers_ref}->[0]->{sister_member} == $fam->{names_hashref}->{'rand'})  and 
                                        ($fam->{names_hashref}->{'rand'}->{brothers_ref}->[0]->{sister_field} eq 'turtle'));

$new_riv = new Relations::Family::Rivalry(-brother_member => $fam->{names_hashref}->{'vb'},
                                          -brother_field  => 'heehee',
                                          -sister_member  => $fam->{names_hashref}->{'rand'},
                                          -sister_field   => 'haahaa');

$fam->add_rivalry(-rivalry => $new_riv);

die "Direct add rivalry failed" unless (($fam->{names_hashref}->{'vb'}->{sisters_ref}->[1]->{brother_member} == $fam->{names_hashref}->{'vb'})  and 
                                        ($fam->{names_hashref}->{'vb'}->{sisters_ref}->[1]->{brother_field} eq 'heehee')  and 
                                        ($fam->{names_hashref}->{'vb'}->{sisters_ref}->[1]->{sister_member} == $fam->{names_hashref}->{'rand'})  and 
                                        ($fam->{names_hashref}->{'vb'}->{sisters_ref}->[1]->{sister_field} eq 'haahaa')  and 
                                        ($fam->{names_hashref}->{'rand'}->{brothers_ref}->[1]->{brother_member} == $fam->{names_hashref}->{'vb'})  and 
                                        ($fam->{names_hashref}->{'rand'}->{brothers_ref}->[1]->{brother_field} eq 'heehee')  and 
                                        ($fam->{names_hashref}->{'rand'}->{brothers_ref}->[1]->{sister_member} == $fam->{names_hashref}->{'rand'})  and 
                                        ($fam->{names_hashref}->{'rand'}->{brothers_ref}->[1]->{sister_field} eq 'haahaa'));

$chosen = $fam->set_chosen(-name   => 'vb',
                           -selects => ["5\tblee",
                                        "8\tblah"],
                           -filter => 'thing',
                           -match  => 1,
                           -group  => 4,
                           -limit  => "2,3",
                           -ignore => 7);

die "Select set chosen failed" unless (($chosen->{count} == 2) and
                                        ($chosen->{ids_string} eq '5,8') and
                                        ($chosen->{ids_arrayref}->[0] == 5) and
                                        ($chosen->{ids_arrayref}->[1] == 8) and
                                        ($chosen->{ids_selectref}->[0] eq "5\tblee") and
                                        ($chosen->{ids_selectref}->[1] eq "8\tblah") and
                                        ($chosen->{labels_string} eq 'blee,blah') and
                                        ($chosen->{labels_arrayref}->[0] eq 'blee') and
                                        ($chosen->{labels_arrayref}->[1] eq 'blah') and
                                        ($chosen->{labels_hashref}->{'5'} eq 'blee') and
                                        ($chosen->{labels_hashref}->{'8'} eq 'blah') and
                                        ($chosen->{labels_selectref}->{"5\tblee"} eq 'blee') and
                                        ($chosen->{labels_selectref}->{"8\tblah"} eq 'blah') and
                                        ($chosen->{filter} eq 'thing') and
                                        ($chosen->{match} == 1) and
                                        ($chosen->{group} == 4) and
                                        ($chosen->{limit} eq '2,3') and
                                        ($chosen->{ignore} == 7));

$chosen = $fam->set_chosen(-label   => 'Random Thoughts',
                           -ids     => [23,12],
                           -labels => {23 => "foo",
                                       12 => "bar"},
                           -filter => 'thang',
                           -match  => 3,
                           -group  => 2,
                           -limit  => "235454",
                           -ignore => 6);

die "Hash set chosen failed" unless (($chosen->{count} == 2) and
                                      ($chosen->{ids_string} eq '23,12') and
                                      ($chosen->{ids_arrayref}->[0] == 23) and
                                      ($chosen->{ids_arrayref}->[1] == 12) and
                                      ($chosen->{ids_selectref}->[0] eq "23\tfoo") and
                                      ($chosen->{ids_selectref}->[1] eq "12\tbar") and
                                      ($chosen->{labels_string} eq 'foo,bar') and
                                      ($chosen->{labels_arrayref}->[0] eq 'foo') and
                                      ($chosen->{labels_arrayref}->[1] eq 'bar') and
                                      ($chosen->{labels_hashref}->{'23'} eq 'foo') and
                                      ($chosen->{labels_hashref}->{'12'} eq 'bar') and
                                      ($chosen->{labels_selectref}->{"23\tfoo"} eq 'foo') and
                                      ($chosen->{labels_selectref}->{"12\tbar"} eq 'bar') and
                                      ($chosen->{filter} eq 'thang') and
                                      ($chosen->{match} == 3) and
                                      ($chosen->{group} == 2) and
                                      ($chosen->{limit} eq '235454') and
                                      ($chosen->{ignore} == 6));

$fam->set_chosen(-member  => $mem,
                 -ids     => [47,51],
                 -labels  => ["shoe","saloon"],
                 -filter => 'g-money',
                 -match  => 5,
                 -group  => 1,
                 -limit  => "5471",
                 -ignore => 1);

$chosen = $fam->get_chosen(-name => 'rand');

die "Hash set chosen failed" unless (($chosen->{count} == 2) and
                                      ($chosen->{ids_string} eq '47,51') and
                                      ($chosen->{ids_arrayref}->[0] == 47) and
                                      ($chosen->{ids_arrayref}->[1] == 51) and
                                      ($chosen->{ids_selectref}->[0] eq "47\tshoe") and
                                      ($chosen->{ids_selectref}->[1] eq "51\tsaloon") and
                                      ($chosen->{labels_string} eq 'shoe,saloon') and
                                      ($chosen->{labels_arrayref}->[0] eq 'shoe') and
                                      ($chosen->{labels_arrayref}->[1] eq 'saloon') and
                                      ($chosen->{labels_hashref}->{'47'} eq 'shoe') and
                                      ($chosen->{labels_hashref}->{'51'} eq 'saloon') and
                                      ($chosen->{labels_selectref}->{"47\tshoe"} eq 'shoe') and
                                      ($chosen->{labels_selectref}->{"51\tsaloon"} eq 'saloon') and
                                      ($chosen->{filter} eq 'g-money') and
                                      ($chosen->{match} == 5) and
                                      ($chosen->{group} == 1) and
                                      ($chosen->{limit} eq '5471') and
                                      ($chosen->{ignore} == 1));

$fam->set_chosen(-label  => 'Donkey Biter',
                 -ids     => "21,36",
                 -labels  => "flew,koo koo",
                 -filter => 'special-sauce',
                 -match  => 6,
                 -group  => 1,
                 -limit  => "6211",
                 -ignore => 1);

$chosen = $fam->get_chosen(-name => 'donkey');

die "String set chosen failed" unless (($chosen->{count} == 2) and
                                      ($chosen->{ids_string} eq '21,36') and
                                      ($chosen->{ids_arrayref}->[0] == 21) and
                                      ($chosen->{ids_arrayref}->[1] == 36) and
                                      ($chosen->{ids_selectref}->[0] eq "21\tflew") and
                                      ($chosen->{ids_selectref}->[1] eq "36\tkoo koo") and
                                      ($chosen->{labels_string} eq 'flew,koo koo') and
                                      ($chosen->{labels_arrayref}->[0] eq 'flew') and
                                      ($chosen->{labels_arrayref}->[1] eq 'koo koo') and
                                      ($chosen->{labels_hashref}->{'21'} eq 'flew') and
                                      ($chosen->{labels_hashref}->{'36'} eq 'koo koo') and
                                      ($chosen->{labels_selectref}->{"21\tflew"} eq 'flew') and
                                      ($chosen->{labels_selectref}->{"36\tkoo koo"} eq 'koo koo') and
                                      ($chosen->{filter} eq 'special-sauce') and
                                      ($chosen->{match} == 6) and
                                      ($chosen->{group} == 1) and
                                      ($chosen->{limit} eq '6211') and
                                      ($chosen->{ignore} == 1));

$finder = relate_finder($abs,$database);

$finder->set_chosen(-name   => 'account',
                    -ids    => "21,36");

%needs = ();
%needed = ();

$needs = \%needs;
$needed = \%needed;

$need = $finder->get_needs($finder->{names_hashref}->{'account'},$needs,$needed,1);

die "Get self needs failed" unless ((not $need) and
                                    (not $needs->{'account'}));

%needs = ();
%needed = ();

$needs = \%needs;
$needed = \%needed;

$need = $finder->get_needs($finder->{names_hashref}->{'item'},$needs,$needed,1);

die "Get other needs failed" unless (($need) and
                                     ($needs->{'item'}));

$finder->set_chosen(-name   => 'customer',
                    -ids    => "4,20");

%row = ();
@values = ();
push @values, \%row;
$values = \@values;

%valued = ();
$valued = \%valued;

$values = $finder->get_values($finder->{names_hashref}->{'type'},$values,$valued,1,1);

die "Get basic values failed" unless (($values->[0]->{'account'} eq "21,36") and
                                      ($values->[0]->{'customer'} eq "4,20"));

$finder->set_chosen(-name   => 'product',
                    -ids    => "3,3445,10000",
                    -match  => 1);

%row = ();
@values = ();
push @values, \%row;
$values = \@values;

%valued = ();
$valued = \%valued;

$values = $finder->get_values($finder->{names_hashref}->{'item'},$values,$valued,1,1);

die "Get all values failed" unless (($values->[0]->{'product'} eq "3") and
                                    ($values->[0]->{'account'} eq "21,36") and
                                    ($values->[0]->{'customer'} eq "4,20") and
                                    ($values->[1]->{'product'} eq "3445") and
                                    ($values->[1]->{'account'} eq "21,36") and
                                    ($values->[1]->{'customer'} eq "4,20") and
                                    ($values->[2]->{'product'} eq "10000") and
                                    ($values->[2]->{'account'} eq "21,36") and
                                    ($values->[2]->{'customer'} eq "4,20"));

%row = ();
@values = ();
push @values, \%row;
$values = \@values;

%valued = ();
$valued = \%valued;

$values = $finder->get_values($finder->{names_hashref}->{'type'},$values,$valued,1,1);

die "Get all -> any values failed" unless (($values->[0]->{'product'} eq "3,3445,10000") and
                                           ($values->[0]->{'account'} eq "21,36") and
                                           ($values->[0]->{'customer'} eq "4,20"));

$finder->set_chosen(-name   => 'product',
                    -ids    => $finder->{names_hashref}->{'product'}->{chosen_ids_string},
                    -match  => 0);

$finder->set_chosen(-name   => 'account',
                    -ids    => $finder->{names_hashref}->{'account'}->{chosen_ids_string},
                    -match  => 1);

$finder->set_chosen(-name   => 'customer',
                    -ids    => $finder->{names_hashref}->{'customer'}->{chosen_ids_string},
                    -match  => 1);

%row = ();
@values = ();
push @values, \%row;
$values = \@values;

%valued = ();
$valued = \%valued;

$values = $finder->get_values($finder->{names_hashref}->{'account'},$values,$valued,1,1);

die "Get account values failed" unless (($values->[0]->{'product'} eq "3,3445,10000") and
                                        ($values->[0]->{'customer'} eq "4,20"));

%row = ();
@values = ();
push @values, \%row;
$values = \@values;

%valued = ();
$valued = \%valued;

$values = $finder->get_values($finder->{names_hashref}->{'customer'},$values,$valued,1,1);

die "Get customer values failed" unless (($values->[0]->{'product'} eq "3,3445,10000") and
                                         ($values->[0]->{'account'} eq "21,36"));

%row = ();
@values = ();
push @values, \%row;
$values = \@values;

%valued = ();
$valued = \%valued;

$values = $finder->get_values($finder->{names_hashref}->{'item'},$values,$valued,1,1);

die "Get cross values failed" unless (($values->[0]->{'product'} eq "3,3445,10000") and
                                      ($values->[0]->{'account'} eq "21") and
                                      ($values->[0]->{'customer'} eq "4") and
                                      ($values->[1]->{'product'} eq "3,3445,10000") and
                                      ($values->[1]->{'account'} eq "36") and
                                      ($values->[1]->{'customer'} eq "4") and
                                      ($values->[2]->{'product'} eq "3,3445,10000") and
                                      ($values->[2]->{'account'} eq "21") and
                                      ($values->[2]->{'customer'} eq "20") and
                                      ($values->[3]->{'product'} eq "3,3445,10000") and
                                      ($values->[3]->{'account'} eq "36") and
                                      ($values->[3]->{'customer'} eq "20"));

%needs = ();
%needed = ();

$needs = \%needs;
$needed = \%needed;

$need = $finder->get_needs($finder->{names_hashref}->{'item'},$needs,$needed,1);

%row = ();
@values = ();
push @values, \%row;
$values = \@values;

%valued = ();
$valued = \%valued;

$values = $finder->get_values($finder->{names_hashref}->{'item'},$values,$valued,1,1);

%queried = ();
$queried = \%queried;

$qry = new Relations::Query(-select => 'item_id');

$finder->get_query($finder->{names_hashref}->{'item'},$qry,$values->[2],$needs,$queried);

$query = "select item_id " . 
           "from item,purchase,customer,account,product " . 
           "where $database.item.pur_id=$database.purchase.pur_id and " .
                 "$database.purchase.cust_id=$database.customer.cust_id and " .
                 "$database.customer.cust_id in (20) and " .
                 "$database.customer.cust_id=$database.account.cust_id and " .
                 "$database.account.acc_id in (21) and " .
                 "$database.item.prod_id=$database.product.prod_id and " .
                 "$database.product.prod_id in (3,3445,10000) ";

die "Get get query failed" unless (($qry->get() eq $query));

print "\nEverything seems fine\n";

sub create_finder {

  my $abs = shift;
  my $database = shift;

  $create = "

    DROP DATABASE IF EXISTS $database;
    CREATE DATABASE $database;
    USE $database;

    CREATE TABLE account (
       acc_id int(10) unsigned NOT NULL auto_increment,
       cust_id tinyint(3) unsigned DEFAULT '0' NOT NULL,
       balance decimal(6,2) DEFAULT '0.00' NOT NULL,
       PRIMARY KEY (acc_id),
       UNIQUE cust_id (cust_id)
    );

    INSERT INTO account (acc_id, cust_id, balance) VALUES ( '1', '1', '134.87');
    INSERT INTO account (acc_id, cust_id, balance) VALUES ( '2', '4', '54.65');
    INSERT INTO account (acc_id, cust_id, balance) VALUES ( '3', '3', '0.00');
    INSERT INTO account (acc_id, cust_id, balance) VALUES ( '4', '5', '357.72');
    INSERT INTO account (acc_id, cust_id, balance) VALUES ( '5', '2', '78.99');

    CREATE TABLE customer (
       cust_id int(10) unsigned NOT NULL auto_increment,
       cust_name varchar(32) NOT NULL,
       phone varchar(32) NOT NULL,
       PRIMARY KEY (cust_id),
       UNIQUE cust_name (cust_name)
    );

    INSERT INTO customer (cust_id, cust_name, phone) VALUES ( '1', 'Harry\\'s Garage', '555-8762');
    INSERT INTO customer (cust_id, cust_name, phone) VALUES ( '2', 'Varney Solutions', '555-8814');
    INSERT INTO customer (cust_id, cust_name, phone) VALUES ( '3', 'Simply Flowers', '555-1392');
    INSERT INTO customer (cust_id, cust_name, phone) VALUES ( '4', 'Last Night Diner', '555-0544');
    INSERT INTO customer (cust_id, cust_name, phone) VALUES ( '5', 'Teskaday Print Shop', '555-4357');

    CREATE TABLE item (
       item_id int(10) unsigned NOT NULL auto_increment,
       pur_id int(10) unsigned DEFAULT '0' NOT NULL,
       prod_id int(10) unsigned DEFAULT '0' NOT NULL,
       qty int(10) unsigned DEFAULT '0' NOT NULL,
       PRIMARY KEY (item_id),
       UNIQUE ord_id (pur_id, prod_id)
    );

    INSERT INTO item (item_id, pur_id, prod_id, qty) VALUES ( '1', '1', '3', '2');
    INSERT INTO item (item_id, pur_id, prod_id, qty) VALUES ( '2', '1', '4', '10');
    INSERT INTO item (item_id, pur_id, prod_id, qty) VALUES ( '3', '1', '1', '3');
    INSERT INTO item (item_id, pur_id, prod_id, qty) VALUES ( '4', '1', '2', '30');
    INSERT INTO item (item_id, pur_id, prod_id, qty) VALUES ( '5', '1', '5', '14');
    INSERT INTO item (item_id, pur_id, prod_id, qty) VALUES ( '6', '2', '4', '5');
    INSERT INTO item (item_id, pur_id, prod_id, qty) VALUES ( '7', '2', '5', '7');
    INSERT INTO item (item_id, pur_id, prod_id, qty) VALUES ( '8', '2', '2', '10');
    INSERT INTO item (item_id, pur_id, prod_id, qty) VALUES ( '9', '3', '9', '1');
    INSERT INTO item (item_id, pur_id, prod_id, qty) VALUES ( '10', '3', '4', '5');
    INSERT INTO item (item_id, pur_id, prod_id, qty) VALUES ( '11', '3', '5', '5');
    INSERT INTO item (item_id, pur_id, prod_id, qty) VALUES ( '12', '3', '2', '12');
    INSERT INTO item (item_id, pur_id, prod_id, qty) VALUES ( '13', '4', '6', '1');
    INSERT INTO item (item_id, pur_id, prod_id, qty) VALUES ( '14', '4', '9', '1');
    INSERT INTO item (item_id, pur_id, prod_id, qty) VALUES ( '15', '4', '8', '1');
    INSERT INTO item (item_id, pur_id, prod_id, qty) VALUES ( '16', '4', '7', '1');
    INSERT INTO item (item_id, pur_id, prod_id, qty) VALUES ( '17', '5', '13', '24');
    INSERT INTO item (item_id, pur_id, prod_id, qty) VALUES ( '18', '5', '12', '50');
    INSERT INTO item (item_id, pur_id, prod_id, qty) VALUES ( '19', '5', '10', '32');
    INSERT INTO item (item_id, pur_id, prod_id, qty) VALUES ( '20', '5', '11', '120');
    INSERT INTO item (item_id, pur_id, prod_id, qty) VALUES ( '21', '6', '12', '12');
    INSERT INTO item (item_id, pur_id, prod_id, qty) VALUES ( '22', '7', '9', '12');
    INSERT INTO item (item_id, pur_id, prod_id, qty) VALUES ( '23', '8', '6', '1');
    INSERT INTO item (item_id, pur_id, prod_id, qty) VALUES ( '24', '8', '9', '1');
    INSERT INTO item (item_id, pur_id, prod_id, qty) VALUES ( '25', '8', '8', '1');
    INSERT INTO item (item_id, pur_id, prod_id, qty) VALUES ( '26', '8', '7', '6');

    CREATE TABLE product (
       prod_id int(10) unsigned NOT NULL auto_increment,
       prod_name varchar(16) NOT NULL,
       type_id int(10) unsigned DEFAULT '0' NOT NULL,
       PRIMARY KEY (prod_id),
       UNIQUE prod_name (prod_name)
    );

    INSERT INTO product (prod_id, prod_name, type_id) VALUES ( '1', 'Towel Dispenser', '1');
    INSERT INTO product (prod_id, prod_name, type_id) VALUES ( '2', 'Towels', '1');
    INSERT INTO product (prod_id, prod_name, type_id) VALUES ( '3', 'Soap Dispenser', '1');
    INSERT INTO product (prod_id, prod_name, type_id) VALUES ( '4', 'Soap', '1');
    INSERT INTO product (prod_id, prod_name, type_id) VALUES ( '5', 'Toilet Paper', '1');
    INSERT INTO product (prod_id, prod_name, type_id) VALUES ( '6', 'Answer Machine', '2');
    INSERT INTO product (prod_id, prod_name, type_id) VALUES ( '7', 'Phone', '2');
    INSERT INTO product (prod_id, prod_name, type_id) VALUES ( '8', 'Fax', '2');
    INSERT INTO product (prod_id, prod_name, type_id) VALUES ( '9', 'Copy Machine', '2');
    INSERT INTO product (prod_id, prod_name, type_id) VALUES ( '10', 'Dishes', '3');
    INSERT INTO product (prod_id, prod_name, type_id) VALUES ( '11', 'Silverware', '3');
    INSERT INTO product (prod_id, prod_name, type_id) VALUES ( '12', 'Cups', '3');
    INSERT INTO product (prod_id, prod_name, type_id) VALUES ( '13', 'Bowls', '3');

    CREATE TABLE pur_sp (
       ps_id int(10) unsigned NOT NULL auto_increment,
       pur_id int(10) unsigned DEFAULT '0' NOT NULL,
       sp_id int(10) unsigned DEFAULT '0' NOT NULL,
       PRIMARY KEY (ps_id),
       UNIQUE ord_id (pur_id, sp_id)
    );

    INSERT INTO pur_sp (ps_id, pur_id, sp_id) VALUES ( '1', '1', '14');
    INSERT INTO pur_sp (ps_id, pur_id, sp_id) VALUES ( '2', '3', '3');
    INSERT INTO pur_sp (ps_id, pur_id, sp_id) VALUES ( '3', '4', '10');
    INSERT INTO pur_sp (ps_id, pur_id, sp_id) VALUES ( '4', '5', '8');
    INSERT INTO pur_sp (ps_id, pur_id, sp_id) VALUES ( '5', '5', '16');
    INSERT INTO pur_sp (ps_id, pur_id, sp_id) VALUES ( '6', '5', '9');
    INSERT INTO pur_sp (ps_id, pur_id, sp_id) VALUES ( '7', '6', '12');
    INSERT INTO pur_sp (ps_id, pur_id, sp_id) VALUES ( '8', '6', '6');
    INSERT INTO pur_sp (ps_id, pur_id, sp_id) VALUES ( '9', '6', '14');
    INSERT INTO pur_sp (ps_id, pur_id, sp_id) VALUES ( '10', '6', '1');
    INSERT INTO pur_sp (ps_id, pur_id, sp_id) VALUES ( '11', '7', '8');
    INSERT INTO pur_sp (ps_id, pur_id, sp_id) VALUES ( '12', '7', '15');
    INSERT INTO pur_sp (ps_id, pur_id, sp_id) VALUES ( '13', '7', '7');
    INSERT INTO pur_sp (ps_id, pur_id, sp_id) VALUES ( '14', '8', '4');

    CREATE TABLE purchase (
       pur_id int(10) unsigned NOT NULL auto_increment,
       cust_id int(10) unsigned DEFAULT '0' NOT NULL,
       date date DEFAULT '0000-00-00' NOT NULL,
       PRIMARY KEY (pur_id)
    );

    INSERT INTO purchase (pur_id, cust_id, date) VALUES ( '1', '1', '2000-12-07');
    INSERT INTO purchase (pur_id, cust_id, date) VALUES ( '2', '1', '2001-02-08');
    INSERT INTO purchase (pur_id, cust_id, date) VALUES ( '3', '1', '2001-04-21');
    INSERT INTO purchase (pur_id, cust_id, date) VALUES ( '4', '3', '2001-03-10');
    INSERT INTO purchase (pur_id, cust_id, date) VALUES ( '5', '4', '2000-11-03');
    INSERT INTO purchase (pur_id, cust_id, date) VALUES ( '6', '4', '2001-05-09');
    INSERT INTO purchase (pur_id, cust_id, date) VALUES ( '7', '5', '2001-04-07');
    INSERT INTO purchase (pur_id, cust_id, date) VALUES ( '8', '2', '2001-01-04');

    CREATE TABLE region (
       reg_id int(10) unsigned NOT NULL auto_increment,
       reg_name varchar(16) NOT NULL,
       PRIMARY KEY (reg_id),
       UNIQUE reg_name (reg_name)
    );

    INSERT INTO region (reg_id, reg_name) VALUES ( '1', 'North East');
    INSERT INTO region (reg_id, reg_name) VALUES ( '2', 'South East');
    INSERT INTO region (reg_id, reg_name) VALUES ( '3', 'South West');
    INSERT INTO region (reg_id, reg_name) VALUES ( '4', 'North West');

    CREATE TABLE sales_person (
       sp_id int(10) unsigned NOT NULL auto_increment,
       f_name varchar(32) NOT NULL,
       l_name varchar(32) NOT NULL,
       reg_id int(10) unsigned DEFAULT '0' NOT NULL,
       PRIMARY KEY (sp_id),
       UNIQUE f_name (f_name, l_name)
    );

    INSERT INTO sales_person (sp_id, f_name, l_name, reg_id) VALUES ( '1', 'John', 'Lockland', '1');
    INSERT INTO sales_person (sp_id, f_name, l_name, reg_id) VALUES ( '2', 'Mimi', 'Butterfield', '4');
    INSERT INTO sales_person (sp_id, f_name, l_name, reg_id) VALUES ( '3', 'Sheryl', 'Saunders', '2');
    INSERT INTO sales_person (sp_id, f_name, l_name, reg_id) VALUES ( '4', 'Frank', 'Macena', '1');
    INSERT INTO sales_person (sp_id, f_name, l_name, reg_id) VALUES ( '5', 'Joyce', 'Parkhurst', '3');
    INSERT INTO sales_person (sp_id, f_name, l_name, reg_id) VALUES ( '6', 'Dave', 'Gropenhiemer', '4');
    INSERT INTO sales_person (sp_id, f_name, l_name, reg_id) VALUES ( '7', 'Hank', 'Wishings', '2');
    INSERT INTO sales_person (sp_id, f_name, l_name, reg_id) VALUES ( '8', 'Fred', 'Pirozzi', '3');
    INSERT INTO sales_person (sp_id, f_name, l_name, reg_id) VALUES ( '9', 'Sally', 'Rogers', '3');
    INSERT INTO sales_person (sp_id, f_name, l_name, reg_id) VALUES ( '10', 'Jane', 'Wadsworth', '4');
    INSERT INTO sales_person (sp_id, f_name, l_name, reg_id) VALUES ( '11', 'Ravi', 'Svenka', '1');
    INSERT INTO sales_person (sp_id, f_name, l_name, reg_id) VALUES ( '12', 'Jennie', 'Dryden', '1');
    INSERT INTO sales_person (sp_id, f_name, l_name, reg_id) VALUES ( '13', 'Mike', 'Nicerby', '4');
    INSERT INTO sales_person (sp_id, f_name, l_name, reg_id) VALUES ( '14', 'Karen', 'Harner', '2');
    INSERT INTO sales_person (sp_id, f_name, l_name, reg_id) VALUES ( '15', 'Jose', 'Salina', '3');
    INSERT INTO sales_person (sp_id, f_name, l_name, reg_id) VALUES ( '16', 'Mya', 'Protaste', '2');
    INSERT INTO sales_person (sp_id, f_name, l_name, reg_id) VALUES ( '17', 'Calvin', 'Peterson', '1');

    CREATE TABLE type (
       type_id int(10) unsigned NOT NULL auto_increment,
       type_name varchar(8) NOT NULL,
       PRIMARY KEY (type_id),
       UNIQUE type_name (type_name)
    );

    INSERT INTO type (type_id, type_name) VALUES ( '1', 'Toiletry');
    INSERT INTO type (type_id, type_name) VALUES ( '2', 'Office');
    INSERT INTO type (type_id, type_name) VALUES ( '3', 'Dining')
    
  ";

  @create = split ';',$create;

  foreach $create (@create) {

    $abs->run_query($create);

  }

}

sub relate_finder {

  my $abs = shift;
  my $database = shift;

  my $fam = new Relations::Family($abs);

  $fam->add_member(-name     => 'account',
                   -label    => 'Cust. Account',
                   -database => $database,
                   -table    => 'account',
                   -id_field => 'acc_id',
                   -select   => {'id'    => 'acc_id',
                                 'label' => "concat(cust_name,' - ',balance)"},
                   -from     => ['account','customer'],
                   -where    => "customer.cust_id=account.cust_id",
                   -order_by => "cust_name");

  $fam->add_member(-name     => 'customer',
                   -label    => 'Customer',
                   -database => $database,
                   -table    => 'customer',
                   -id_field => 'cust_id',
                   -select   => {'id'    => 'cust_id',
                                 'label' => 'cust_name'},
                   -from     => 'customer',
                   -order_by => "cust_name");

  $fam->add_member(-name     => 'item',
                   -label    => 'Puchase Item',
                   -database => $database,
                   -table    => 'item',
                   -id_field => 'item_id',
                   -select   => {'id'    => 'item_id',
                                 'label' => "concat(
                                              cust_name,
                                              ' - ',
                                              date_format(date, '%M %D, %Y'),
                                              ' - ',
                                              prod_name,
                                              ' - ',
                                              qty
                                            )"},
                   -from     => ['purchase',
                                 'customer',
                                 'product',
                                 'item'],
                   -where    => ['purchase.pur_id=item.pur_id',
                                 'product.prod_id=item.prod_id',
                                 'customer.cust_id=purchase.cust_id'],
                   -order_by => ['date desc',
                                 'cust_name',
                                 'prod_name']);

  $fam->add_member(-name     => 'product',
                   -label    => 'Product',
                   -database => $database,
                   -table    => 'product',
                   -id_field => 'prod_id',
                   -select   => {'id'    => 'prod_id',
                                 'label' => 'prod_name'},
                   -from     => 'product',
                   -order_by => "prod_name");

  $fam->add_member(-name     => 'pur_sp',
                   -label    => 'Purchase via Sales Person',
                   -database => $database,
                   -table    => 'pur_sp',
                   -id_field => 'ps_id',
                   -select   => {'id'    => 'ps_id',
                                 'label' => "concat(
                                              cust_name,
                                              ' - ',
                                              date_format(date, '%M %D, %Y'),
                                              ' via ',
                                              f_name,
                                              ' ',
                                              l_name
                                            )"},
                   -from     => ['pur_sp',
                                 'purchase',
                                 'customer',
                                 'sales_person'],
                   -where    => ['purchase.pur_id=pur_sp.pur_id',
                                 'customer.cust_id=purchase.cust_id',
                                 'sales_person.sp_id=pur_sp.sp_id'],
                   -order_by => ['date desc',
                                 'cust_name',
                                 'l_name',
                                 'f_name']);

  $fam->add_member(-name     => 'purchase',
                   -label    => 'Purchase',
                   -database => $database,
                   -table    => 'purchase',
                   -id_field => 'pur_id',
                   -select   => {'id'    => 'pur_id',
                                 'label' => "concat(
                                              cust_name,
                                              ' - ',
                                              date_format(date, '%M %D, %Y')
                                            )"},
                   -from     => ['purchase',
                                 'customer'],
                   -where    => 'customer.cust_id=purchase.cust_id',
                   -order_by => ['date desc',
                                 'cust_name']);

  $fam->add_member(-name     => 'region',
                   -label    => 'Region',
                   -database => $database,
                   -table    => 'region',
                   -id_field => 'reg_id',
                   -select   => {'id'    => 'reg_id',
                                 'label' => 'reg_name'},
                   -from     => 'region',
                   -order_by => "reg_name");

  $fam->add_member(-name     => 'sales_person',
                   -label    => 'Sales Person',
                   -database => $database,
                   -table    => 'sales_person',
                   -id_field => 'sp_id',
                   -select   => {'id'    => 'sp_id',
                                 'label' => "concat(f_name,' ',l_name)"},
                   -from     => 'sales_person',
                   -order_by => ["l_name","f_name"]);

  $fam->add_member(-name     => 'type',
                   -label    => 'Type',
                   -database => $database,
                   -table    => 'type',
                   -id_field => 'type_id',
                   -select   => {'id'    => 'type_id',
                                 'label' => 'type_name'},
                   -from     => 'type',
                   -order_by => "type_name");

  $fam->add_lineage(-parent_name  => 'purchase',
                    -parent_field => 'pur_id',
                    -child_name   => 'item',
                    -child_field  => 'pur_id');

  $fam->add_lineage(-parent_name  => 'product',
                    -parent_field => 'prod_id',
                    -child_name   => 'item',
                    -child_field  => 'prod_id');

  $fam->add_lineage(-parent_name  => 'type',
                    -parent_field => 'type_id',
                    -child_name   => 'product',
                    -child_field  => 'type_id');

  $fam->add_lineage(-parent_name  => 'purchase',
                    -parent_field => 'pur_id',
                    -child_name   => 'pur_sp',
                    -child_field  => 'pur_id');

  $fam->add_lineage(-parent_name  => 'sales_person',
                    -parent_field => 'sp_id',
                    -child_name   => 'pur_sp',
                    -child_field  => 'sp_id');

  $fam->add_lineage(-parent_name  => 'customer',
                    -parent_field => 'cust_id',
                    -child_name   => 'purchase',
                    -child_field  => 'cust_id');

  $fam->add_lineage(-parent_name  => 'region',
                    -parent_field => 'reg_id',
                    -child_name   => 'sales_person',
                    -child_field  => 'reg_id');

  $fam->add_rivalry(-brother_name  => 'customer',
                    -brother_field => 'cust_id',
                    -sister_name   => 'account',
                    -sister_field  => 'cust_id');

  return $fam;

}

