# This is a DBI/DBD-MySQL Relational Query Engine module. 

package Relations::Family;
require Exporter;
require DBI;
require 5.004;

use Relations;
use Relations::Query;
use Relations::Abstract;
use Relations::Family::Member;
use Relations::Family::Lineage;
use Relations::Family::Rivalry;

# You can run this file through either pod2man or pod2html to produce pretty
# documentation in manual or html file format (these utilities are part of the
# Perl 5 distribution).

# Copyright 2001 GAF-3 Industries, Inc. All rights reserved.
# Written by George A. Fitch III (aka Gaffer), gaf3@gaf3.com

# This program is free software, you can redistribute it and/or modify it under
# the same terms as Perl istelf

$Relations::Family::VERSION = '0.91';

@ISA = qw(Exporter);

@EXPORT    = ();		

@EXPORT_OK = qw(
                new
               );

%EXPORT_TAGS = ();

# From here on out, be strict and clean.

use strict;

# Create a Relations::Family object. This object allows
# you to create lists of object to select from, and 
# queries the available selections from a list off the
# selections made from other lists. This is very useful
# in drillling down through a large (lotta data) complex 
# (lotta tables) MySQL relational database.

sub new {

  # Get the type we were sent

  my ($type) = shift;

  # Get all the arguments passed

  my ($abstract) = rearrange(['ABSTRACT'],@_);

  # $dbh - Default database handle

  # Create the hash to hold all the vars
  # for this object.

  my $self = {};

  # Bless it with the type sent (I think this
  # makes it a full fledged object)

  bless $self, $type;

  # Add the info into the hash only if it was sent

  $self->{abstract} = $abstract;

  # Create an array and a hash of members

  my @members_array = ();
  my %names_hash = ();
  my %labels_hash = ();

  $self->{members_arrayref} = \@members_array;
  $self->{names_hashref} = \%names_hash;
  $self->{labels_hashref} = \%labels_hash;

  return $self;

}

# Adds a member to this family. 

sub add_member {

  # Get the type we were sent

  my ($self) = shift;

  # Get all the arguments passed

  my ($name,
      $label,
      $database,
      $table,
      $id_field,
      $select,
      $from,
      $where,
      $group_by,
      $having,
      $order_by,
      $limit,
      $query,
      $member) = rearrange(['NAME',
                            'LABEL',
                            'DATABASE',
                            'TABLE',
                            'ID_FIELD',
                            'SELECT',
                            'FROM',
                            'WHERE',
                            'GROUP_BY',
                            'HAVING',
                            'ORDER_BY',
                            'LIMIT',
                            'QUERY',
                            'MEMBER'],@_);


  # $name - Member name
  # $label - The label to display for the member
  # $database - The member's database
  # $table - The member's table 
  # $id_field - The name of the member's id field
  # $select - The select clause of the member's query
  # $from - The from clause of the member's query
  # $where - The where clause of the member's query
  # $group_by - The group by clause of the member's query
  # $having - The having clause of the member's query
  # $order_by - The order_by clause of the member's query
  # $limit - The limit clause of the member's query
  # $query - The member's query object
  # $member - The member to add

  # Unless they sent a query or member, create a query using
  # the bits they did send.

  unless ($query || $member) {

    $query = new Relations::Query(-select   => $select,
                                  -from     => $from,
                                  -where    => $where,
                                  -group_by => $group_by,
                                  -having   => $having,
                                  -order_by => $order_by,
                                  -limit    => $limit);

    # Make the query distinct

    $query->{'select'} = 'distinct ' . $query->{'select'};

  }

  # Unless they sent an already created member, create
  # one using what the did send.

  unless ($member) {

    $member = new Relations::Family::Member(-name     => $name,
                                            -label    => $label,
                                            -database => $database,
                                            -table    => $table,
                                            -id_field => $id_field,
                                            -query    => $query);

  }

  # Double check to make sure we don't already have
  # a member with the same name.

  return 0 if $self->{names_hashref}->{$member->{name}};

  # Double check to make sure we don't already have
  # a member with the same label.

  return 0 if $self->{labels_hashref}->{$member->{label}};

  # Ok, it checks out. Add it to the array of lists,
  # the names hash, and the labels hash, so we can
  # look it up when we need to.

  push @{$self->{members_arrayref}}, $member;
  $self->{names_hashref}->{$member->{name}} = $member;
  $self->{labels_hashref}->{$member->{label}} = $member;

  return 1;

}

# Establishes a one to many relationship between
# two members. 

sub add_lineage {

  # Get the type we were sent

  my ($self) = shift;

  # Get all the arguments passed

  my ($parent_name,
      $parent_field,
      $child_name,
      $child_field,
      $parent_member,
      $parent_label,
      $child_member,
      $child_label,
      $lineage) = rearrange([ 'PARENT_NAME',
                              'PARENT_FIELD',
                              'CHILD_NAME',
                              'CHILD_FIELD',
                              'PARENT_MEMBER',
                              'PARENT_LABEL',
                              'CHILD_MEMBER',
                              'CHILD_LABEL',
                              'LINEAGE'],@_);


  # $parent_name - The name of the one member
  # $parent_field - The connecting field of the one member
  # $child_name - The name of the many member
  # $child_field - The connecting field of the many member
  # $parent_member - The one member
  # $parent_label - The label of the one member
  # $child_member - The many member
  # $child_label - The label of the many member

  # Unless they sent a name or member or lineage, get the 
  # parent name using the label. Then unless they sent a 
  # member or lineage, get the parent member using the name.

  $parent_name = $self->{labels_hashref}->{$parent_label}->{name} 
    unless ($parent_name || $parent_member || $lineage);

  $parent_member = $self->{names_hashref}->{$parent_name} 
    unless ($parent_member || $lineage);

  # Unless they sent a name or member or lineage, get the 
  # child name using the label. Then unless they sent a 
  # member or lineage, get the child member using the name.

  $child_name = $self->{labels_hashref}->{$child_label}->{name} 
    unless ($child_name || $child_member || $lineage);

  $child_member = $self->{names_hashref}->{$child_name} 
    unless ($child_member || $lineage);

  # Unless they sent a lineage, create one if they did
  # send bits.

  unless ($lineage) {

    # Double check that we found the members.

    return 0 unless ($parent_member &&
                     $parent_field &&
                     $child_member &&
                     $child_field);

    $lineage = new Relations::Family::Lineage(-parent_member => $parent_member,
                                              -parent_field  => $parent_field,
                                              -child_member  => $child_member,
                                              -child_field   => $child_field);

  }

  # Ok, everything checks out. Add the lineage to both
  # the parent and child so they know that they're related 
  # and how.

  push @{$lineage->{child_member}->{parents_ref}}, $lineage;
  push @{$lineage->{parent_member}->{children_ref}}, $lineage;

  return 1;

}

# Establishes a one to one relationship between
# two members. 

sub add_rivalry {

  # Get the type we were sent

  my ($self) = shift;

  # Get all the arguments passed

  my ($brother_name,
      $brother_field,
      $sister_name,
      $sister_field,
      $brother_member,
      $brother_label,
      $sister_member,
      $sister_label,
      $rivalry) = rearrange([ 'BROTHER_NAME',
                              'BROTHER_FIELD',
                              'SISTER_NAME',
                              'SISTER_FIELD',
                              'BROTHER_MEMBER',
                              'BROTHER_LABEL',
                              'SISTER_MEMBER',
                              'SISTER_LABEL',
                              'RIVALRY'],@_);


  # $brother_name - The name of the one member
  # $brother_field - The connecting field of the one member
  # $sister_name - The name of the other member
  # $sister_field - The connecting field of the other member
  # $brother_member - The one member
  # $brother_label - The label of the one member
  # $sister_member - The other member
  # $sister_label - The label of the other member

  # Unless they sent a name or member or rivalry, get the 
  # brother name using the label. Then unless they sent a 
  # member or rivalry, get the brother member using the name.

  $brother_name = $self->{labels_hashref}->{$brother_label}->{name} 
    unless ($brother_name || $brother_member || $rivalry);

  $brother_member = $self->{names_hashref}->{$brother_name} 
    unless ($brother_member || $rivalry);

  # Unless they sent a name or member or rivalry, get the 
  # sister name using the label. Then unless they sent a 
  # member or rivalry, get the sister member using the name.

  $sister_name = $self->{labels_hashref}->{$sister_label}->{name} 
    unless ($sister_name || $sister_member || $rivalry);

  $sister_member = $self->{names_hashref}->{$sister_name} 
    unless ($sister_member || $rivalry);

  # Unless they sent a rivalry, create one if they did
  # send bits.

  unless ($rivalry) {

    # Double check that we found the members.

    return 0 unless ($brother_member &&
                     $brother_field &&
                     $sister_member &&
                     $sister_field);

    $rivalry = new Relations::Family::Rivalry(-brother_member => $brother_member,
                                              -brother_field  => $brother_field,
                                              -sister_member  => $sister_member,
                                              -sister_field   => $sister_field);

  }

  # Ok, everything checks out. Add the rivalry to both
  # the brother and sister so they know that they're related 
  # and how.

  push @{$rivalry->{sister_member}->{brothers_ref}}, $rivalry;
  push @{$rivalry->{brother_member}->{sisters_ref}}, $rivalry;

  return 1;

}

# Gets the chosen items of a member. 

sub get_chosen {

  # Get the type we were sent

  my ($self) = shift;

  # Get all the arguments passed

  my ($name,
      $member,
      $label) = rearrange(['NAME',
                           'MEMBER',
                           'LABELS'],@_);


  # $name - The name of the member
  # $member - The member
  # $label - The label of the member

  # Unless they sent a name or member, get the member name 
  # using the label. Then unless they sent a member, get 
  # the member using the name.

  $name = $self->{labels_hashref}->{$label}->{name} unless ($name || $member);
  $member = $self->{names_hashref}->{$name} unless ($member);

  # Create a has to hold all the values and fill it.

  my %chosen_hash = ();

  $chosen_hash{count} = $member->{chosen_count};
  $chosen_hash{ids_string} = $member->{chosen_ids_string};
  $chosen_hash{ids_arrayref} = $member->{chosen_ids_arrayref};
  $chosen_hash{ids_selectref} = $member->{chosen_ids_selectref};

  $chosen_hash{labels_string} = $member->{chosen_labels_string};
  $chosen_hash{labels_arrayref} = $member->{chosen_labels_arrayref};
  $chosen_hash{labels_hashref} = $member->{chosen_labels_hashref};
  $chosen_hash{labels_selectref} = $member->{chosen_labels_selectref};

  $chosen_hash{filter} = $member->{filter};
  $chosen_hash{match} = $member->{match};
  $chosen_hash{group} = $member->{group};
  $chosen_hash{limit} = $member->{limit};
  $chosen_hash{ignore} = $member->{ignore};

  return \%chosen_hash;

}

# Sets the chosen items of a member. 

sub set_chosen {

  # Get the type we were sent

  my ($self) = shift;

  # Get all the arguments passed

  my ($name,
      $ids,
      $labels,
      $match,
      $group,
      $filter,
      $limit,
      $ignore,
      $selects,
      $label,
      $member) = rearrange(['NAME',
                            'IDS',
                            'LABELS',
                            'MATCH',
                            'GROUP',
                            'FILTER',
                            'LIMIT',
                            'IGNORE',
                            'SELECTS',
                            'LABEL',
                            'MEMBER'],@_);
 
  # $name - The name of the member
  # $selects - The select ids from the select list
  # $ids - The selected ids
  # $labels - The selected labels
  # $member - The member
  # $label - The label of the member
  # $filter - The filter for the labels
  # $match - Mathcing any of all selections
  # $group - Group inclusively or exclusively
  # $limit - Limit settings
  # $ignore - Whether or not we're ignoring this member

  # Unless they sent a name or member, get the member name 
  # using the label. Then unless they sent a member, get 
  # the member using the name.

  $name = $self->{labels_hashref}->{$label}->{name} unless ($name || $member);
  $member = $self->{names_hashref}->{$name} unless ($member);

  # The chosen items can be set a number of ways. So we'll
  # check to see how they sent the data, and set all the 
  # other forms of storing the selections.

  # First off, if there's no select and $ids isn't an array,
  # we'll assume that $ids and $labels are strings and convert 
  # them to arrays. This may not be true, but if it is, 
  # everything works out. If it isn't, then we'll avoid some 
  # errors (I think).

  unless ($selects || ((ref($ids) eq 'ARRAY') && ((ref($labels) eq 'ARRAY') || (ref($labels) eq 'HASH')))) {

    my @ids = split ',', $ids;
    my @labels = split ',', $labels;

    $ids = \@ids;
    $labels = \@labels;

  }

  # If it's an array and has a tab in it, its in the select
  # format.

  if ($selects) {

    # Set the count based on the number of selects, and
    # and set the selectref for the selects to what was
    # sent.

    $member->{chosen_count} = scalar @{$selects};
    $member->{chosen_ids_selectref} = $selects;

    # Empty out the ids array, the labels array,
    # the labels hash, and the labels select hash
    # because we're going to fill them.

    @{$member->{chosen_ids_arrayref}} = ();
    @{$member->{chosen_labels_arrayref}} = ();
    %{$member->{chosen_labels_hashref}} = ();
    %{$member->{chosen_labels_selectref}} = ();

    # Go through all the selects and fill the other
    # storage forms.

    my $select;

    foreach $select (@{$selects}) {

      my ($id,$label) = split /\t/, $select;

      push @{$member->{chosen_ids_arrayref}}, $id;
      push @{$member->{chosen_labels_arrayref}}, $label;
      $member->{chosen_labels_hashref}->{$id} = $label;
      $member->{chosen_labels_selectref}->{$select} = $label;

    }

  }

  # If the ids were set as an array and the labels were
  # sent as a hash.

  elsif (ref($labels) eq 'HASH') {

    # Set the count based on the number of ids, and
    # and set the arrayref for the ids and the hashref
    # of the labels to what was sent.

    $member->{chosen_count} = scalar @{$ids};
    $member->{chosen_ids_arrayref} = $ids;
    $member->{chosen_labels_hashref} = $labels;

    # Empty out the ids select array, the labels array,
    # the labels select hash.

    @{$member->{chosen_ids_selectref}} = ();
    @{$member->{chosen_labels_arrayref}} = ();
    %{$member->{chosen_labels_selectref}} = ();

    # Go through all the ids and fill the other
    # storage forms.

    my $id;

    foreach $id (@{$ids}) {

      push @{$member->{chosen_ids_selectref}}, "$id\t$labels->{$id}";
      push @{$member->{chosen_labels_arrayref}}, $labels->{$id};
      $member->{chosen_labels_selectref}->{"$id\t$labels->{$id}"} = $labels->{$id};

    }

  }

  # If the ids were set as an array and the labels were
  # sent as an array.

  else {

    # Set the count based on the number of ids, and
    # and set the arrayref for the ids and the hashref
    # of the labels to what was sent.

    $member->{chosen_count} = scalar @{$ids};
    $member->{chosen_ids_arrayref} = $ids;
    $member->{chosen_labels_arrayref} = $labels;

    # Empty out the ids select array, the labels hash,
    # the labels select hash.

    @{$member->{chosen_ids_selectref}} = ();
    %{$member->{chosen_labels_hashref}} = ();
    %{$member->{chosen_labels_selectref}} = ();

    # Go through all the ids and fill the other
    # storage forms.

    my $i;

    for ($i = 0; $i < scalar @{$ids}; $i++) {

      push @{$member->{chosen_ids_selectref}}, "$ids->[$i]\t$labels->[$i]";
      $member->{chosen_labels_hashref}->{$ids->[$i]} = $labels->[$i];
      $member->{chosen_labels_selectref}->{"$ids->[$i]\t$labels->[$i]"} = $labels->[$i];

    }

  }

  # Set the strings accordingly.

  $member->{chosen_ids_string} = join ',', @{$member->{chosen_ids_arrayref}};
  $member->{chosen_labels_string} = join ',', @{$member->{chosen_labels_arrayref}};

  # Grab the other settings if sent.

  $member->{filter} = $filter;
  $member->{match} = $match;
  $member->{group} = $group;
  $member->{limit} = $limit;
  $member->{ignore} = $ignore;

  # Return the whole shabang set.

  return $self->get_chosen(-member => $member);

}

# Gets wheter a list needs to be queried. 

sub get_needs {

  # Get the type we were sent

  my ($self) = shift;

  # Get all the arguments passed

  my ($member,
      $needs,
      $needed,
      $skip) = (@_);

  # $member - The member
  # $needs - Hash of needs
  # $needed - Hash ref of lists
  # $skip - Skip the sent member

  # If we've got stuff selected, and we're not to be 
  # ignored, then we need a query.

  my $need = ($member->{chosen_count} > 0) && !$member->{ignore} && !$skip;

  # Add ourselves to the hash, sohwing that we've been
  # evaluated for a need to query

  $needed->{$member->{name}} = 1;

  # Go thorugh all our relatives, and || their need with 
  # ours, unless they've already been evaluated for 
  # need. We || them because if they need a query, and 
  # they haven't been check yet, then we need a query
  # to connect them to the central member.

  my ($lineage,$rivalry);

  # Parents

  foreach $lineage (@{$member->{parents_ref}}) {

    next if $needed->{$lineage->{parent_member}->{name}};

    $need = $self->get_needs($lineage->{parent_member},$needs,$needed) || $need;

  }

  # Children

  foreach $lineage (@{$member->{children_ref}}) {

    next if $needed->{$lineage->{child_member}->{name}};

    $need = $self->get_needs($lineage->{child_member},$needs,$needed) || $need;

  }

  # Brothers

  foreach $rivalry (@{$member->{brothers_ref}}) {

    next if $needed->{$rivalry->{brother_member}->{name}};

    $need = $self->get_needs($rivalry->{brother_member},$needs,$needed) || $need;

  }

  # Sisters

  foreach $rivalry (@{$member->{sisters_ref}}) {

    next if $needed->{$rivalry->{sister_member}->{name}};

    $need = $self->get_needs($rivalry->{sister_member},$needs,$needed) || $need;

  }

  # Return whether we're needed, and set the
  # needs hash.

  $needs->{$member->{name}} = $need;

}

# Gets a member's chosen values. 

sub get_values {

  # Get the type we were sent

  my ($self) = shift;

  # Get all the arguments passed

  my ($member,
      $values,
      $valued,
      $no_all,
      $skip) = (@_);

  # $member - The member
  # $values - Array of hashes of values
  # $valued - Hash ref of lists
  # $can_all - Whether or not we can match all
  # $skip - Skip the sent member

  # If we've got stuff selected, we're not to be ignored, 
  # and we're not being skipped then we need to be valued.

  if (($member->{chosen_count} > 0) && !$member->{ignore} && !$skip) {

    # Unless we're set to match all, and we're allowed to
    # match all values.

    unless ($member->{match} && !$no_all) {

      # Then we're just going to add our values to the 
      # values array of hashes.

      # Declare a row for counting.

      my $row; 

      # Go through each row of values

      foreach $row (@{$values}) {

        # Put our values in keyed by our name

        $row->{$member->{name}} = $member->{chosen_ids_string};

      }

    # If we're to match all

    } else {

      # Declare and id for counting, a row of values, as well 
      # as a new array for the array of hashes of values.

      my $id;
      my $row;
      my @new_values = ();

      # Go through each row in the values

      foreach $row (@{$values}) {

        # Go through each of our ids

        foreach $id (@{$member->{chosen_ids_arrayref}}) {

          # Create a new row from the current values row,
          # assign our current id to it, and add it to the
          # new array of hashes of values

          my %row = %{$row};

          my $key;

          $row{$member->{name}} = $id;

          push @new_values, \%row;

        }

      }

      # Point values to our new array.

      $values = \@new_values;

    }

  }

  # Add ourselves to the hash, showing that we've
  # added our values, and are thus valued.

  $valued->{$member->{name}} = 1;

  # Go thorugh all our relatives, add add their values to\
  # values, unless they've already been evaluated for 
  # values. 

  my ($lineage,$rivalry);

  # Parents

  foreach $lineage (@{$member->{parents_ref}}) {

    next if $valued->{$lineage->{parent_member}->{name}};

    $values = $self->get_values($lineage->{parent_member},$values,$valued);

  }

  # Children

  foreach $lineage (@{$member->{children_ref}}) {

    next if $valued->{$lineage->{child_member}->{name}};

    $values = $self->get_values($lineage->{child_member},$values,$valued,$no_all);

  }

  # Brothers

  foreach $rivalry (@{$member->{brothers_ref}}) {

    next if $valued->{$rivalry->{brother_member}->{name}};

    $values = $self->get_values($rivalry->{brother_member},$values,$valued,$no_all);

  }

  # Sisters

  foreach $rivalry (@{$member->{sisters_ref}}) {

    next if $valued->{$rivalry->{sister_member}->{name}};

    $values = $self->get_values($rivalry->{sister_member},$values,$valued,$no_all);

  }

  return $values;

}

# Gets a member's contribution to the query. 

sub get_query {

  # Get the type we were sent

  my ($self) = shift;

  # Get all the arguments passed

  my ($member,
      $query,
      $row,
      $needs,
      $queried) = (@_);

  # $member - The member
  # $query - The query to build
  # $row - query hash to use
  # $needs - Hash of who needs to be queried
  # $queried - Hash of member's have been queried

  # Our table is needed in the query.

  $query->add(-from => $member->{table});

  # If we have stuff chosen, then our chosen ids 
  # need to be in the query. Make sure we exclude
  # our chosen values if we're supposed to.

  if ($row->{$member->{name}}) {

    my $group = $member->{group} ? ' not' : '';

    my $member_id = "$member->{database}." .
                    "$member->{table}." . 
                    "$member->{id_field}";

    $query->add(-where => "$member_id$group in ($row->{$member->{name}})");

  }

  # Add ourselves to the hash, showing that we've
  # added our query, and are thus queried.

  $queried->{$member->{name}} = 1;

  # Go thorugh all our relatives, add add their query to
  # query, unless they've already been queried or they just 
  # don't need to be queried.

  my ($lineage,$rivalry);

  # Parents

  foreach $lineage (@{$member->{parents_ref}}) {

    next if ($queried->{$lineage->{parent_member}->{name}} || 
              !$needs->{$lineage->{parent_member}->{name}});

    my $parent_field = "$lineage->{parent_member}->{database}." .
                       "$lineage->{parent_member}->{table}." . 
                       "$lineage->{parent_field}";

    my $child_field = "$lineage->{child_member}->{database}." .
                      "$lineage->{child_member}->{table}." . 
                      "$lineage->{child_field}";

    $query->add(-where => "$child_field=$parent_field");

    $self->get_query($lineage->{parent_member},$query,$row,$needs,$queried);

  }

  # Children

  foreach $lineage (@{$member->{children_ref}}) {

    next if ($queried->{$lineage->{child_member}->{name}} || 
              !$needs->{$lineage->{child_member}->{name}});

    my $parent_field = "$lineage->{parent_member}->{database}." .
                       "$lineage->{parent_member}->{table}." . 
                       "$lineage->{parent_field}";

    my $child_field = "$lineage->{child_member}->{database}." .
                      "$lineage->{child_member}->{table}." . 
                      "$lineage->{child_field}";

    $query->add(-where => "$parent_field=$child_field");

    $self->get_query($lineage->{child_member},$query,$row,$needs,$queried);

  }

  # Brothers

  foreach $rivalry (@{$member->{brothers_ref}}) {

    next if ($queried->{$rivalry->{brother_member}->{name}} || 
              !$needs->{$rivalry->{brother_member}->{name}});

    my $brother_field = "$rivalry->{brother_member}->{database}." .
                        "$rivalry->{brother_member}->{table}." . 
                        "$rivalry->{brother_field}";

    my $sister_field = "$rivalry->{sister_member}->{database}." .
                       "$rivalry->{sister_member}->{table}." . 
                       "$rivalry->{sister_field}";

    $query->add(-where => "$sister_field=$brother_field");

    $self->get_query($rivalry->{brother_member},$query,$row,$needs,$queried);

  }

  # Sisters

  foreach $rivalry (@{$member->{sisters_ref}}) {

    next if ($queried->{$rivalry->{sister_member}->{name}} || 
              !$needs->{$rivalry->{sister_member}->{name}});

    my $brother_field = "$rivalry->{brother_member}->{database}." .
                        "$rivalry->{brother_member}->{table}." . 
                        "$rivalry->{brother_field}";

    my $sister_field = "$rivalry->{sister_member}->{database}." .
                       "$rivalry->{sister_member}->{table}." . 
                       "$rivalry->{sister_field}";

    $query->add(-where => "$brother_field=$sister_field");

    $self->get_query($rivalry->{sister_member},$query,$row,$needs,$queried);

  }

}

# Gets the available records from a 
# member based on other members

sub get_available {

  # Get the type we were sent

  my ($self) = shift;

  # Get all the arguments passed

  my ($name,
      $member,
      $label,
      $focus) = rearrange(['NAME',
                           'MEMBER',
                           'LABEL',
                           'FOCUS'],@_);
 
  # $name - The name of the member
  # $member - The member
  # $label - The label of the member
  # $focus - Whether to use one's own chosen ids

  # Unless they sent a name or member, get the member name 
  # using the label. Then unless they sent a member, get 
  # the member using the name.

  $name = $self->{labels_hashref}->{$label}->{name} unless ($name || $member);
  $member = $self->{names_hashref}->{$name} unless ($member);

  # Create a query to hold the avaiable items. Base it off
  # of what was specified at the creation of the current 
  # member and what's been selected.

  my $available_query = $member->{query}->clone();

  # If we have a filter, put it in.

  if ($member->{filter}) {

    $available_query->add(-having => "label like '%$member->{filter}%'");

  }
  
  # If we have a limit, put it in.

  if ($member->{limit}) {

    $available_query->add(-limit => $member->{limit});

  }
  
  # Now we need to see if we need to query any of the 
  # members, starting at this member. So create the hashes 
  # to hold the needs. The needs is just a hashref keyed
  # by the member name and set to whether the member needs
  # to be queried.
  
  my %needs = ();
  my %needed = ();

  # We also have to keep track of what's been checked 
  # already, so we'll create a hash and key with member
  # name set to 1 if they've been checked.

  my $needs = \%needs;
  my $needed = \%needed;

  # Now call the recursive get_needs, starting at the 
  # current member. Make sure the first member's skipped 
  # too, since we're not going build a query of avaiable 
  # records if the only selections are from this member.

  my $need = $self->get_needs($member,$needs,$needed,1);

  # If there's a need to query, let's get all the values 
  # and build a query.

  if ($need) {

    # Create an empty vales set. A values set is an arrayref
    # of hashrefs of selected ids key by the member name. To
    # create an empty values set, we need an empty hash's 
    # reference in the first member of an array being pointed
    # to. 

    my %row = ();
    my @values = ();
    push @values, \%row;
    my $values = \@values;

    # Like get_needs, we also need a hash for keeping track 
    # of which members we've valued. 

    my %valued = ();
    my $valued = \%valued;

    # Call the recursive gets values. Skip the current member
    # and don't allow match all's on the member and all their
    # connected members except parents.

    $values = $self->get_values($member,$values,$valued,1,1 && !$focus);

    # Go through all the values sets found and create a 
    # temporary table for each set.

    my ($row,$set);

    $set = 0;

    my $id_field = "$member->{database}.$member->{table}.$member->{id_field}";

    foreach $row (@{$values}) {

      # Now we have to make a hash to hold who's been queried
      # and who hasn't. 

      my %queried = ();
      my $queried = \%queried;

      # Create a query object for this values set.

      my $row_query = new Relations::Query(-select => {'id_field' => $id_field});

      # Run the recursive get query. 

      $self->get_query($member,$row_query,$row,$needs,$queried);

      # Now create a temporary table with the query

      my $table = $member->{name} . '_query_' . $set;
      my $create = "create temporary table $table ";
      my $condition = "$member->{table}.$member->{id_field}=$table.id_field";

      $self->{abstract}->run_query(-query => "drop table if exists $table");

      $self->{abstract}->run_query(-query => $create . $row_query->get());

      # Add this temp table and requirement to the 
      # avaiable query, and increase the set var.

      $available_query->add(-from  => $table,
                            -where => $condition);

      $set++;

    }

  }

  # Execute the main query

  my $sth = $self->{abstract}->{dbh}->prepare($available_query->get());

  $sth->execute() or print "Available query failed: " . $available_query->get() . "\n";

  # Clear out the member's avaiable stuff.

  my @available_ids_array = ();
  my @available_ids_select = ();
  my @available_labels_array = ();
  my %available_labels_hash = ();
  my %available_labels_select = ();

  $member->{available_count} = 0;
  $member->{available_ids_arrayref} = \@available_ids_array;
  $member->{available_ids_selectref} = \@available_ids_select;

  $member->{available_labels_arrayref} = \@available_labels_array;
  $member->{available_labels_hashref} = \%available_labels_hash;
  $member->{available_labels_selectref} = \%available_labels_select;

  # Populate all members

  my ($hash_ref);

  while ($hash_ref = $sth->fetchrow_hashref) {

    $member->{available_count}++;

    push @{$member->{available_ids_arrayref}}, $hash_ref->{id};
    push @{$member->{available_ids_selectref}}, "$hash_ref->{id}\t$hash_ref->{label}";

    push @{$member->{available_labels_arrayref}}, $hash_ref->{label};
    $member->{available_labels_hashref}->{$hash_ref->{id}} = $hash_ref->{label};
    $member->{available_labels_selectref}->{"$hash_ref->{id}\t$hash_ref->{label}"} = $hash_ref->{label};

  }

  $sth->finish();

  # Create the info hash to return and fill it

  my %available = ();

  $available{filter} = $member->{filter};
  $available{match} = $member->{match};
  $available{group} = $member->{group};
  $available{limit} = $member->{limit};
  $available{ignore} = $member->{ignore};
  $available{count} = $member->{available_count};
  $available{ids_arrayref} = $member->{available_ids_arrayref};
  $available{ids_selectref} = $member->{available_ids_selectref};
  $available{labels_arrayref} = $member->{available_labels_arrayref};
  $available{labels_hashref} = $member->{available_labels_hashref};
  $available{labels_selectref} = $member->{available_labels_selectref};

  return \%available;

}

# Sets chosen items from available items, using the
# members current chosen ids, as well as other members
# chosen ids.

sub choose_available {

  # Get the type we were sent

  my ($self) = shift;

  # Get all the arguments passed

  my ($name,
      $member,
      $label) = rearrange(['NAME',
                           'MEMBER',
                           'LABEL'],@_);
 
  # $name - The name of the member
  # $member - The member
  # $label - The label of the member

  # Unless they sent a name or member, get the member name 
  # using the label. Then unless they sent a member, get 
  # the member using the name.

  $name = $self->{labels_hashref}->{$label}->{name} unless ($name || $member);
  $member = $self->{names_hashref}->{$name} unless ($member);

  # Get the available members ids, including using the 
  # member's own ids in the query.

  my $available = $self->get_available(-member => $member, -focus => 1);

  # Return the result from setting the chosen ids to
  # the available ids and labels.

  return $self->set_chosen(-member => $member,
                           -ids    => $available->{ids_arrayref},
                           -labels => $available->{labels_hashref},
                           -filter => $member->{filter},
                           -match  => $member->{match},
                           -group  => $member->{group},
                           -limit  => $member->{limit},
                           -ignore => $member->{ignore});

}

$Relations::Family::VERSION;

__END__

=head1 NAME

Relations::Family - DBI/DBD::mysql Relational Query Engine module. 

=head1 SYNOPSIS

  # DBI, Relations::Family Script that creates some queries.

  #!/usr/bin/perl

  use DBI;
  use Relations::Family;

  $dsn = "DBI:mysql:finder";

  $username = "root";
  $password = '';

  $dbh = DBI->connect($dsn,$username,$password,{PrintError => 1, RaiseError => 0});

  my $family = new Relations::Family($dbh);

  $family->add_member(-name     => 'region',
                      -label    => 'Region',
                      -database => 'finder',
                      -table    => 'region',
                      -id_field => 'reg_id',
                      -select   => {'id'    => 'reg_id',
                                   'label' => 'reg_name'},
                      -from     => 'region',
                      -order_by => "reg_name");

  $family->add_member(-name     => 'sales_person',
                      -label    => 'Sales Person',
                      -database => 'finder',
                      -table    => 'sales_person',
                      -id_field => 'sp_id',
                      -select   => {'id'    => 'sp_id',
                                   'label' => "concat(f_name,' ',l_name)"},
                      -from     => 'sales_person',
                      -order_by => ["l_name","f_name"]);

  $family->add_lineage(-parent_name  => 'region',
                       -parent_field => 'reg_id',
                       -child_name   => 'sales_person',
                       -child_field  => 'reg_id');

  $family->set_chosen(-label  => 'Sales Person',
                      -ids    => '2,5,7');

  $available = $family->get_available(-label  => 'Region');

  print "Found $available->{count} Regions:\n";

  foreach $id (@{$available->{ids_arrayref}}) {

    print "Id: $id Label: $available->{labels_hashref}->{$id}\n";

  }

  $dbh->disconnect();

=head1 ABSTRACT

This perl module uses perl5 objects to simplify searching through
large, complex MySQL databases, especially those with foreign keys.
It uses an object orientated interface, complete with functions to 
create and manipulate the relational family.

The current version of Relations::Family is available at

  http://www.gaf3.com

=head1 DESCRIPTION

=head2 WHAT IT DOES

With Relations::Family you can create a 'family' of members for querying 
records. A member could be a table, or it could be a query on a table, like
all the different months from a table's date field. Once the members are
created, you can specify how those members are related, who's using who
as a foreign key lookup, etc.

Once the 'family' is complete, you can select records from one member, and
the query all the matching records from another member. For example, say you 
a product table being used as a lookup for a order items tables, and you want
to find all the order items for a certain product. You can select that 
product's record from the product member, and then get the matching order 
item records to find all the order items for that product.

=head2 CALLING RELATIONS::FAMILY ROUTINES

All standard Relations::Family routines use both an ordered and named 
argument calling style. This is because some routines have as many as 
twelve arguments, and the code is easier to understand given a named 
argument style, but since some people, however, prefer the ordered argument 
style because its smaller, I'm glad to do that too. 

If you use the ordered argument calling style, such as

  $family->add_lineage('customer','cust_id','purchase','cust_id');

the order matters, and you should consult the function defintions 
later in this document to determine the order to use.

If you use the named argument calling style, such as

  $famimly->add_lineage(-parent_name  => 'customer',
                        -parent_field => 'cust_id',
                        -child_name   => 'purchase',
                        -child_field  => 'cust_id');

the order does not matter, but the names, and minus signs preceeding them, do.
You should consult the function defintions later in this document to determine 
the names to use.

In the named arugment style, each argument name is preceded by a dash.  
Neither case nor order matters in the argument list.  -name, -Name, and 
-NAME are all acceptable.  In fact, only the first argument needs to begin with 
a dash.  If a dash is present in the first argument, Relations::Family assumes
dashes for the subsequent ones.

=head1 LIST OF RELATIONS::FAMILY FUNCTIONS

An example of each function is provided in either 'test.pl' and 'demo.pl'.

=head2 new

  $family = new Relations::Family($abstract);

  $family = new Relations::Family(-abstract => $abstract);

Creates creates a new Relations::Family object using a Relations::Abstract
object.

=head2 add_member

  $family->add_member($name,
                      $label,
                      $database,
                      $table,
                      $id_field,
                      $select,
                      $from,
                      $where,
                      $group_by,
                      $having,
                      $order_by,
                      $limit);

  $family->add_member(-name     => $name,
                      -label    => $label,
                      -database => $database,
                      -table    => $table,
                      -id_field => $id_field,
                      -select   => $select,
                      -from     => $from,
                      -where    => $where,
                      -group_by => $group_by,
                      -having   => $having,
                      -order_by => $order_by,
                      -limit    => $limit);

  $family->add_member(-name     => $name,
                      -label    => $label,
                      -database => $database,
                      -table    => $table,
                      -id_field => $id_field,
                      -query    => $query);

Creates and adds a member to a family. There's three basic groups of 
arguments in an add_member call. The first group sets how to name 
the member. The second sets how to configure the member. The third 
group explains how to create the query to display the member's records 
for selection. 

B<$name> and B<$label> - 
In the first group, $name and $label set the internal and external
identity, so both must be unique to the family. Typically, $name 
is a short string used for quickly specifying a member when coding
with a family, while $label is a longer string used to display the 
identity of a member to user using the program.

B<$database>, B<$table> and B<$id_field> - 
In the second group, $database, $table and $id_field set the MySQL
properties. The $database and $table variables are the database 
and table used by the member, while $id_field is the member's 
table's primary key field. Relations::Family using this info when
connecting members to each other during a query.

B<$select> through B<$limit> - 
These parameters are sent directly to a Relations::Query object,
and that object is modified to select distinct by default. In order
for the member to function properly you must declase two variables,
id and label, in the 'select' part of the query. Ids are the values
that connect one member to another. Labels are what's displayed to 
the user to select. See the the documention for Relations::Query for 
more info on creating a query object.

B<$query> - 
Instead of specifying the peices of a query, you can create a query
separately, and send it . In my own experience, I often run into a 
situation where different members have the same query. The minimize
code, you can query the query once, then use it many times.

=head2 add_lineage

  $family->add_lineage($parent_name,
                       $parent_field,
                       $child_name,
                       $child_field);

  $family->add_lineage(-parent_name  => $parent_name,
                       -parent_field => $parent_field,
                       -child_name   => $child_name,
                       -child_field  => $child_field);

  $family->add_lineage(-parent_label => $parent_label,
                       -parent_field => $parent_field,
                       -child_label  => $child_label,
                       -child_field  => $child_field);

Adds a one-to-many relationhsip to a family. This is used when a 
member, the child, is using another member, the parent, as a 
lookup. The parent field is the field in the parent member,
usually the primary key, the values of which is is stored in the 
child member's child_field.

B<$parent_name> or B<$parent_label> - 
Specifies the parent member by name or label. 

B<$parent_field> - 
Specifies the field in the parent member that holds the values 
used by the child member's child_field, usually the parent 
member's primary key.

B<$child_name> or B<$child_label> - 
Specifies the child member by name or label. 

B<$child_field> - 
Specifies the field in the child member that stores the values 
of the parent member's field.

=head2 add_rivalry

  $family->add_rivalry($brother_name,
                       $brother_field,
                       $sister_name,
                       $sister_field);

  $family->add_rivalry(-brother_name  => $brother_name,
                       -brother_field => $brother_field,
                       -sister_name   => $sister_name,
                       -sister_field  => $sister_field);

  $family->add_rivalry(-brother_label => $brother_label,
                       -brother_field => $brother_field,
                       -sister_label  => $sister_label,
                       -sister_field  => $sister_field);

Adds a one-to-one relationhsip to a family. This is used when a 
member, there is a one to one relationship between two members. 
The brother field is the field in the brother member, the values 
of which is is stored in the sister member's sister_field, or
vice vice versa.

B<$brother_name> or B<$brother_label> - 
Specifies the brother member by name or label. 

B<$brother_field> - 
Specifies the field in the brother member that holds the values 
used by the sister member's sister_field.

B<$sister_name> or B<$sister_label> - 
Specifies the sister member by name or label. 

B<$sister_field> - 
Specifies the field in the sister member that stores the values 
of the brother member's field.

=head2 set_chosen

  $family->set_chosen($name,
                      $ids,
                      $labels,
                      $match,
                      $group,
                      $filter,
                      $limit);

  $family->set_chosen(-name   => $name,
                      -ids    => $ids,
                      -labels => $labels,
                      -match  => $match,
                      -group  => $group,
                      -filter => $filter,
                      -limit  => $limit);

  $family->set_chosen(-label  => $label,
                      -ids    => $ids,
                      -labels => $labels,
                      -match  => $match,
                      -group  => $group,
                      -filter => $filter,
                      -limit  => $limit);

Sets the member's records selected by a user, as well as 
some other goodies to control the selection process.

B<$name> or B<$label> - 
Specifies the member by name or label. 

B<$ids> -
The ids selected. Can be a comma delimitted string, or
an array.

B<$labels> -
The labels selected. Can be a comma delimitted string, an
array, or a hash keyed by $ids. It is isn't necessary to 
send these, unless you want the selected labels returned 
by get_chosen. 

B<$match> -
Match any or all. Null or 0 for any, 1 for all. This deals with
multiple selections from a member and how that affects matching
records from another member. Match any returns records that are 
connected to any of the selections. Match all returns records 
that are connected to all the selection. 

B<$group> -
Group include or exclude. Null or 0 for include, 1 for exclude. 
This deals with whether to returning matching records or non 
matching records. Group include returns records connected to 
the selections. Group exclude returns records not connected to 
the selections.

B<$filter> -
Filter labels. In order to simplify the selection process, you 
can specify a filter to only show a select group of records 
from a member for selecting. The filter argument accepts a string,
$filter, and places it in the clause "having label like 
'%$filter%'".

B<$limit> -
Limit returned records. In order to simplify the selection 
process, you can specify a limit clause to only show a certain 
number of records from a member for selecting. The limit argument 
accepts a string, $limit, and places it in the clause "limit 
$limit", so it can be a single number, or two numbers separated
by a comma. 

=head2 get_chosen

  $chosen = $family->get_chosen($name);

  $chosen = $family->get_chosen(-name => $name);

  $chosen = $family->get_chosen(-label => $label);

Returns a member's selected records in a couple different forms,
as well as the other goodies to control the selection process.

B<$name> or B<$label> - 
Specifies the member by name or label. 

B<$chosen> - 
A hash reference of all returned values.

B<$chosen->{count}> - 
The number of selected records.

B<$chosen->{ids_string}> - 
A comma delimtted string of the ids of the selected records.

B<$chosen->{ids_arrayref}> - 
An array reference of the ids of the selected records.

B<$chosen->{labels_string}> - 
A comma delimtted string of the labels of the selected records.
If no labels were sent to get_chosen, this is not available.

B<$chosen->{labels_arrayref}> - 
An array reference of the labels of the selected records. If no 
labels were sent to get_chosen, this is not available.

B<$chosen->{labels_hashref}> - 
A hash reference of the labels of the selected records, keyed 
by the selected ids. If no labels were sent to get_chosen, this 
is not available.

B<$chosen->{match}> - 
The match argument sent to get_chosen().

B<$chosen->{group}> - 
The group argument sent to get_chosen().

B<$chosen->{filter}> - 
The filter argument sent to get_chosen().

B<$chosen->{limit}> - 
The limit argument sent to get_chosen().

=head2 get_available

  $available = $family->get_available($name);

  $available = $family->get_available(-name => $name);

  $available = $family->get_available(-label => $label);

Returns a member's available records, records connected to the 
currently selected records in other members.

B<$name> or B<$label> - 
Specifies the member by name or label. 

B<$available> - 
A hash reference of all returned values.

B<$available->{count}> - 
The number of available records.

B<$available->{ids_string}> - 
A comma delimtted string of the ids of the available records.

B<$available->{ids_arrayref}> - 
An array reference of the ids of the available records.

B<$available->{labels_string}> - 
A comma delimtted string of the labels of the available records.

B<$available->{labels_arrayref}> - 
An array reference of the labels of the available records. 

B<$available->{labels_hashref}> - 
A hash reference of the labels of the available records, keyed 
by the available ids.

=head1 RELATIONS::FAMILY DEMO - FINDER

=head2 Setup

Included with this distribution is demo.pl, which demonstrates all the listed
functionality of Relations::Family. You must have MySQL, Perl, DBI, DBD-MySQL, 
Relations, Relations::Query, Relations::Abstract, and Relations::Family 
installed. 

After installing everything, run demo.pl by typing 

  perl demo.pl

while in the Relations-Family installation directory.

=head2 Overview

This demo revolves around the finder database. This database is for a made up 
company that sells three different types of products: Toiletry: Soap, Towels,
etc., Dining: PLates Cups, etc. and Office: Phones, Faxes, etc. There's a 
type table for the different types of products, and a product table for the
different products. There's also a one-to-many relationship between type to 
product, because each product is of a specific type.

A similar relationship exists between the sales_person table, which holds all 
the different sales people, and the region table, which holds the regions for
the sales peoples. Each sales person belong to a particular region, so there's
a one-to-many relationship fromt he region table to the sales_person table.

If there's sellers, there's buyers. This is the function of the customer 
table. There is also an account table, for the accounts for each customer.
Since each customer has only one account, there is merely a one-to-one
relationship between customer and account.

With sellers and buyers, there must be purchases. Enter the purchase table,
which holds all the purchases. Since only one customer makes a certain 
purchase, but one customer could make many purchases, there is a one-to-many 
relationship from the customer table to the purchase table.

Each purchase contain some number of products at various quantities. This is 
the role of the item table. One purchase can have multiple items, so there is
a one-to-many relationship from the purchase table to the item table. 

A product is the item purchased at different quantities, and a product can be
in multiple purchases. Thus, there is a one-to-many relationship from the 
product table to the item table.

Finally, zero or more sales people can get credit for a purchase, so there 
is many-to-many relationship between the sales_person and purchase tables.
This relationship is handled by the pur_sp table, so there is a one-to-many
relatiionship from the purchase table to the pur_sp table and a one-to-many 
relationship from the sales_person table to the pur_sp table.

Family's role in this is true to it's name sake: It brings all of this into
one place, and allows table to connect to one another. A member in the finder 
family is created for each table in the finder database, and a lineage (for
one-to-many's) or a rivalry (for one-to-one's) for relationship.

With Family, you can select records from one member and find all the 
connecting records in other members. For example, to see all the products
made by a purchase, you'd go to the purchase member, and select the purchase
in question, and then go to the product's member. The avaiable records
in product would be all the product on that purchase.

=head2 Usage

To run the demo, make sure you've followed the setup instructions, and go
to the directory in which you've placed demo.pl and finder.pm. Run demo.pl
like a regular perl script.

The demo starts with a numbered listing of all the members of the finder 
family. To view available records from a member and/or make selections, type
in the member's number and hit return. 

The first thing you'll be asked is if you want to choose available. This 
narrows down the current selected members of a list by the available 
records for a list. Enter 'Y' for yes, and 'N' for no. It defaults to 'N' so 
a blank is the same as no.

You'll then get two questions regarding the presentation of a member's 
records. I'll go into both here.

Limit is for displaying only a certain number of avaiable records at a time.
It's fed into a MySQL limit clause so it can be one number, or two separated
by a comma. To just see X number of rows from the begining, just enter X. To
see X number of rows starting at Y, enter Y,X. 

Filter is for filtering avaialable records for display. It takes a string, and
only returns member's avaiable records that have the entered string in their
label. Just enter the text to filter by.

You'll then get a numbered listing of all the available records for that member, 
as well as the match, group, ignore, limit and filter settings for that member. 

Next, you'll get some questions regarding which records are to be selectecd,
and how those selections are to be used (or not used!). I'll go into them here.

Selections are the records you want to choose. To choose records type each 
number in, separating with commas. 

Match is whether you want other lists to match any of your multiple selections 
from this member or all of them. 0 for many, 1 for all.

Group is whether you want to include what was selected in this member, or 
exclude was selected, in matching other member's records. 0 for include,
1 for exclude.

Finally, you'll be asked if you want to do this again. 'Y' for yes, 'N' for
no. It defaults to 'Y', so just press return for yes. If you choose yes, 
you'll get a list of members, go through the selection/viewing process again.

=head2 Examples

All together, this database can be used to figure out a bunch of stuff. Here's
some ways to query certain records. With each example, it's best to restart 
demo.pl for scratch (exit and rerun).

B<Limit and Filter> - 
There are 17 Sales Persons in the database. Though this isn't terribly many, 
you can lower the number sales people displayed at one time with Family two 
different ways, by limitting or by filtering. Here's examples for both. 

First, let's look at all the sales people
- From the members list, select 7 for Sales Person.
- Don't choose available, no limit, and no filter. (or just hit return)
- There should be 17 available records:

   (2)  Mimi Butterfield
   (12) Jennie Dryden
   (6)  Dave Gropenhiemer
   (14) Karen Harner
   (1)  John Lockland
   (4)  Frank Macena
   (13) Mike Nicerby
   (5)  Joyce Parkhurst
   (17) Calvin Peterson
   (8)  Fred Pirozzi
   (16) Mya Protaste
   (9)  Sally Rogers
   (15) Jose Salina
   (3)  Sheryl Saunders
   (11) Ravi Svenka
   (10) Jane Wadsworth
   (7)  Hank Wishings

These are all the sales people.
- No Selections (or just hit return)
- Match = 0, Group = 0 (or just hit return)
- Reply Y, to 'Again?' (to select another member)

Now, let's just look at the first 5 sales peoeple.
- From the members list, select 7 for Sales Person.
- Don't choose available. (or just hit return)
- Set limit to 5. 
- No filter. (or just hit return)
- There should be 5 available records: 

   (2)  Mimi Butterfield
   (12) Jennie Dryden
   (6)  Dave Gropenhiemer
   (14) Karen Harner
   (1)  John Lockland

These are the first 5 sales people
- No Selections (or just hit return)
- Match = 0, Group = 0 (or just hit return)
- Reply Y, to 'Again?' (to select another member)

How 'bout the last 5 sales people.
- From the members list, select 7 for Sales Person.
- Don't choose available. (or just hit return)
- Set limit to 12,5. 
- No filter. (or just hit return)
- There should be 5 available records:

   (15) Jose Salina
   (3)  Sheryl Saunders
   (11) Ravi Svenka
   (10) Jane Wadsworth
   (7)  Hank Wishings

These are the last 5 sales people. Limit started at the 12th record,
and allowed the next 5 records.
- No Selections (or just hit return)
- Match = 0, Group = 0 (or just hit return)
- Reply Y, to 'Again?' (to select another member)

Finaly, let's find all the sales people that have the letter 'y' in
the first or last name.
- From the members list, select 7 for Sales Person.
- Don't choose available, and no limit.  (or just hit return)
- Set filter to y. 
- There should be 6 available records: 

   (12) Jennie Dryden
   (13) Mike Nicerby
   (5)  Joyce Parkhurst
   (16) Mya Protaste
   (9)  Sally Rogers
   (3)  Sheryl Saunders

These are all the people with the letter 'y' in their first or last name.
- No Selections (or just hit return)
- Match = 0, Group = 0 (or just hit return)
- Reply N, to 'Again?' (to quit)

B<The Selections Effect> - A purchase contains one or more products, and you can
see which product were purchased on a purchased order by selected a record
from the purcahse member, and viewing the avaiable records of the product 
member. Varney solutions made a purchase on jan 4th, 2001, and we'd like to 
see what they bought.

First, let's see all the products.
- From the members list, select 3 for Product.
- Don't choose available, no limit, and no filter. (or just hit return)
- There should be 13 available records:

   (6)  Answer Machine
   (13) Bowls
   (9)  Copy Machine
   (12) Cups
   (10) Dishes
   (8)  Fax
   (7)  Phone
   (11) Silverware
   (4)  Soap
   (3)  Soap Dispenser
   (5)  Toilet Paper
   (1)  Towel Dispenser
   (2)  Towels

These are all the products.
- No Selections (or just hit return)
- Match = 0, Group = 0 (or just hit return)
- Reply Y, to 'Again?' (to select another member)

Let's pick a purchase to view the products from.
- From the members list, select 5 for Purchase.
- Don't choose available, no limit, and no filter. (or just hit return)
- There should be 8 available records:

   (6)  Last Night Diner - May 9th, 2001
   (3)  Harry's Garage - April 21st, 2001
   (7)  Teskaday Print Shop - April 7th, 2001
   (4)  Simply Flowers - March 10th, 2001
   (2)  Harry's Garage - February 8th, 2001
   (8)  Varney Solutions - January 4th, 2001
   (1)  Harry's Garage - December 7th, 2000
   (5)  Last Night Diner - November 3rd, 2000

- From the available records, select 8 for Varney Solutions' Purchase.
- Match = 0, Group = 0 (or just hit return)
- Reply Y, to 'Again?' (to select another member)

Now, we'll check out all the products on that purchase.
- From the members list, select 3 for Product.
- Don't choose available, no limit, and no filter. (or just hit return)
- There should be 4 available records:

   (6)  Answer Machine
   (9)  Copy Machine
   (8)  Fax
   (7)  Phone

These are the products purchased by Varney in January.
- No Selections (or just hit return)
- Match = 0, Group = 0 (or just hit return)
- Reply N, to 'Again?' (to quit)

B<Matching Multiple> - You can also lookup purchases by products. 
Furthermore you can look purcahses up by selecting many products, 
and finding purchases that have any of the selected products. You
can even find purchases that contain all the selected products. 

First, let's see all the purchases.
- From the members list, select 5 for Purchase.
- Don't choose available, no limit, and no filter. (or just hit return)
- There should be 8 available records:

   (6)  Last Night Diner - May 9th, 2001
   (3)  Harry's Garage - April 21st, 2001
   (7)  Teskaday Print Shop - April 7th, 2001
   (4)  Simply Flowers - March 10th, 2001
   (2)  Harry's Garage - February 8th, 2001
   (8)  Varney Solutions - January 4th, 2001
   (1)  Harry's Garage - December 7th, 2000
   (5)  Last Night Diner - November 3rd, 2000

- No Selections (or just hit return)
- Match = 0, Group = 0 (or just hit return)
- Reply Y, to 'Again?' (to select another member)

Now, we'll check out all the products, select a few, and set matching to
any so we can purchases that have any (Soap or Soap Dispenser).
- From the members list, select 3 for Product.
- Don't choose available, no limit, and no filter. (or just hit return)
- There should be 13 available records:

   (6)  Answer Machine
   (13) Bowls
   (9)  Copy Machine
   (12) Cups
   (10) Dishes
   (8)  Fax
   (7)  Phone
   (11) Silverware
   (4)  Soap
   (3)  Soap Dispenser
   (5)  Toilet Paper
   (1)  Towel Dispenser
   (2)  Towels

These are all the products.
- From the available records, select 4,3 for Soap, and Soap Dispenser
- Match = 0, Group = 0 (or just hit return)
- Reply Y, to 'Again?' (to select another member)

Now, we'll see which purchase contain either Soap or Soap Dispenser.
- From the members list, select 5 for Purchase.
- Don't choose available, no limit, and no filter. (or just hit return)
- There should be 3 available records:

   (3)  Harry's Garage - April 21st, 2001
   (2)  Harry's Garage - February 8th, 2001
   (1)  Harry's Garage - December 7th, 2000

- No Selections (or just hit return)
- Match = 0, Group = 0 (or just hit return)
- Reply Y, to 'Again?' (to select another member)

Now, we'll check out all the products, select a few, and set matching to
all so we can purchases that have all (Soap and Soap Dispenser).
- From the members list, select 3 for Product.
- Don't choose available, no limit, and no filter. (or just hit return)
- There should be 13 available records, Soap and Soap Dispenser *'ed,

   (6)  Answer Machine
   (13) Bowls
   (9)  Copy Machine
   (12) Cups
   (10) Dishes
   (8)  Fax
   (7)  Phone
   (11) Silverware
 * (4)  Soap
 * (3)  Soap Dispenser
   (5)  Toilet Paper
   (1)  Towel Dispenser
   (2)  Towels

These are all the products, with Soap and Soap Dispenser already selected.
- From the available records, select 4,3 for Soap, and Soap Dispenser
- Match = 1 (means 'any')
- Group = 0 (or just hit return)
- Reply Y, to 'Again?' (to select another member)

Now, we'll see which purchase contain both Soap and Soap Dispenser.
- From the members list, select 5 for Purchase.
- Don't choose available, no limit, and no filter. (or just hit return)
- There should be 1 available record:

   (1)  Harry's Garage - December 7th, 2000

This is the only purchase that contains both Soap and Soap Dispenser. 
- No Selections (or just hit return)
- Match = 0, Group = 0 (or just hit return)
- Reply N, to 'Again?' (to quit)

B<Group Inclusion/Exclusion> - Sometimes you'd like to find all records
the records not connected to your selections from a particular member.
Say you wanted to check up on all the orders from customers, except the
Harry's Garage, who would have already let you know if there was a 
problem.

First, let's see all the purchases.
- From the members list, select 5 for Purchase.
- Don't choose available, no limit, and no filter. (or just hit return)
- There should be 8 available records:

   (6)  Last Night Diner - May 9th, 2001
   (3)  Harry's Garage - April 21st, 2001
   (7)  Teskaday Print Shop - April 7th, 2001
   (4)  Simply Flowers - March 10th, 2001
   (2)  Harry's Garage - February 8th, 2001
   (8)  Varney Solutions - January 4th, 2001
   (1)  Harry's Garage - December 7th, 2000
   (5)  Last Night Diner - November 3rd, 2000

- No Selections (or just hit return)
- Match = 0, Group = 0 (or just hit return)
- Reply Y, to 'Again?' (to select another member)

Let's pick a customer to not view the purchases from.
- From the members list, select 1 for Customer.
- Don't choose available, no limit, and no filter. (or just hit return)
- There should be 5 available records:

   (1)  Harry's Garage
   (4)  Last Night Diner
   (3)  Simply Flowers
   (5)  Teskaday Print Shop
   (2)  Varney Solutions

- From the available records, select 1 for Harry's Garage.
- Match = 0 (or just hit return)
- Group = 1 (means 'exclude')
- Reply Y, to 'Again?' (to select another member)

Now, we'll check out all the purchases not from Harry's Garage.
- From the members list, select 5 for Purchase.
- Don't choose available, no limit, and no filter. (or just hit return)
- There should be 5 available records:

   (6)  Last Night Diner - May 9th, 2001
   (7)  Teskaday Print Shop - April 7th, 2001
   (4)  Simply Flowers - March 10th, 2001
   (8)  Varney Solutions - January 4th, 2001
   (5)  Last Night Diner - November 3rd, 2000

- No Selections (or just hit return)
- Match = 0, Group = 0 (or just hit return)
- Reply N, to 'Again?' (to quit)

=head1 OTHER RELATED WORK

=head2 Relations

This perl library contains functions for dealing with databases.
It's mainly used as the the foundation for all the other 
Relations modules. It may be useful for people that deal with
databases in Perl as well.

=head2 Relations::Abstract

A DBI/DBD::mysql Perl module. Meant to save development time and code 
space. It takes the most common (in my experience) collection of DBI 
calls to a MySQL databate, and changes them to one liner calls to an
object.

=head2 Relations::Query

An Perl object oriented form of a SQL select query. Takes hash refs,
array refs, or strings for different clauses (select,where,limit)
and creates a string for each clause. Also allows users to add to
existing clauses. Returns a string which can then be sent to a 
MySQL DBI handle. 

=head2 Relations.Admin.inc.php

Some generalized PHP classes for creating Web interfaces to relational 
databases. Allows users to add, view, update, and delete records from 
different tables. It has functionality to use tables as lookup values 
for records in other tables.

=head2 Relations::Family

A Perl query engine for relational databases.  It queries members from 
any table in a relational database using members selected from any 
other tables in the relational database. This is especially useful with 
complex databases; databases with many tables and many connections 
between tables.

=head2 Relations::Display

An Perl module creating GD::Graph objects from database queries. It 
takes in a query through a Relations::Query object, along with 
information pertaining to which field values from the query results are 
to be used in creating the graph title, x axis label and titles, legend 
label (not used on the graph) and titles, and y axis data. Returns a 
GD::Graph object built from from the query.

=head2 Relations::Choice

An Perl CGI interface for Relations::Family, Reations::Query, and 
Relations::Display. It creates complex (too complex?) web pages for 
selecting from the different tables in a Relations::Family object. 
It also has controls for specifying the grouping and ordering of data
with a Relations::Query object, which is also based on selections in 
the Relations::Family object. That Relations::Query can then be passed
to a Relations::Display object, and a graph or table will be displayed.
A working model already exists in a production enviroment. I'd like to 
streamline it, and add some more functionality before releasing it to 
the world. Shooting for early mid Summer 2001.

=cut