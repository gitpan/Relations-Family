# This is a component of a DBI/DBD-MySQL Relational Query Engine module. 

package Relations::Family::Member;
require Exporter;
require DBI;
require 5.004;

use Relations;
use Relations::Query;

# You can run this file through either pod2man or pod2html to produce pretty
# documentation in manual or html file format (these utilities are part of the
# Perl 5 distribution).

# Copyright 2001 GAF-3 Industries, Inc. All rights reserved.
# Written by George A. Fitch III (aka Gaffer), gaf3@gaf3.com

# This program is free software, you can redistribute it and/or modify it under
# the same terms as Perl istelf

$Relations::Family::Member::VERSION = '0.91';

@ISA = qw(Exporter);

@EXPORT    = ();		

@EXPORT_OK = qw(
                new
               );

%EXPORT_TAGS = ();

# From here on out, be strict and clean.

use strict;

# Create a Relations::Family::Member object. This
# object is a list of values to select from.

sub new {

  # Get the type we were sent

  my ($type) = shift;

  # Get all the arguments passed

  my ($name,
      $label,
      $database,
      $table,
      $id_field,
      $query) = rearrange(['NAME',
                           'LABEL',
                           'DATABASE',
                           'TABLE',
                           'ID_FIELD',
                           'QUERY'],@_);

  # Create the hash to hold all the vars
  # for this object.

  my $self = {};

  # Bless it with the type sent (I think this
  # makes it a full fledged object)

  bless $self, $type;

  # Add the info into the hash

  $self->{name} = $name;
  $self->{label} = $label;
  $self->{database} = $database;
  $self->{table} = $table;
  $self->{id_field} = $id_field;
  $self->{query} = $query;

  # Intialize relationships

  my @parents = ();
  my @children = ();
  my @brothers = ();
  my @sisters = ();

  $self->{parents_ref} = \@parents;
  $self->{children_ref} = \@children;
  $self->{brothers_ref} = \@brothers;
  $self->{sisters_ref} = \@sisters;

  # Initialize chosen ids and labels

  my @chosen_ids_array = ();
  my @chosen_ids_select = ();
  my @chosen_labels_array = ();
  my %chosen_labels_hash = ();
  my %chosen_labels_select = ();

  $self->{chosen_count} = 0;
  $self->{chosen_ids_string} = '';
  $self->{chosen_ids_arrayref} = \@chosen_ids_array;
  $self->{chosen_ids_selectref} = \@chosen_ids_select;

  $self->{chosen_labels_string} = '';
  $self->{chosen_labels_arrayref} = \@chosen_labels_array;
  $self->{chosen_labels_hashref} = \%chosen_labels_hash;
  $self->{chosen_labels_selectref} = \%chosen_labels_select;

  # Initialize available ids and labels

  my @available_ids_array = ();
  my @available_ids_select = ();
  my @available_labels_array = ();
  my %available_labels_hash = ();
  my %available_labels_select = ();

  $self->{available_count} = 0;
  $self->{available_ids_arrayref} = \@available_ids_array;
  $self->{available_ids_selectref} = \@available_ids_select;

  $self->{available_labels_arrayref} = \@available_labels_array;
  $self->{available_labels_hashref} = \%available_labels_hash;
  $self->{available_labels_selectref} = \%available_labels_select;

  # Initialize all selection settings 

  $self->{filter} = '';
  $self->{match} = 0;
  $self->{group} = 0;
  $self->{limit} = '';
  $self->{ignore} = 0;

  return $self;

}

$Relations::Family::Member::VERSION;