# This is a component of a DBI/DBD-MySQL Relational Query Engine module. 

package Relations::Family::Lineage;
require Exporter;
require DBI;
require 5.004;

use Relations;

# You can run this file through either pod2man or pod2html to produce pretty
# documentation in manual or html file format (these utilities are part of the
# Perl 5 distribution).

# Copyright 2001 GAF-3 Industries, Inc. All rights reserved.
# Written by George A. Fitch III (aka Gaffer), gaf3@gaf3.com

# This program is free software, you can redistribute it and/or modify it under
# the same terms as Perl istelf

$Relations::Family::Lineage::VERSION = '0.91';

@ISA = qw(Exporter);

@EXPORT    = ();		

@EXPORT_OK = qw(new);

%EXPORT_TAGS = ();

# From here on out, be strict and clean.

use strict;

# Create a Relations::Family::Lineage object. This object 
# holds a one-to-many relationship between two tables.
# This is when the one table (parent) is used a lookup 
# for a field in the many table (child).

sub new {

  # Get the type we were sent

  my ($type) = shift;

  # Get all the arguments passed

  my ($parent_member,
      $parent_field,
      $child_member,
      $child_field) = rearrange(['PARENT_MEMBER',
                                 'PARENT_FIELD',
                                 'CHILD_MEMBER',
                                 'CHILD_FIELD'],@_);

  # $parent_member - Parent family member (one)
  # $parent_field  - Parent member field used as a foreign key
  # $child_member  - Child family member (many)
  # $child_field   - Child member field using the foreign key

  # Create the hash to hold all the vars
  # for this object.

  my $self = {};

  # Bless it with the type sent (I think this
  # makes it a full fledged object)

  bless $self, $type;

  # Add the info into the hash

  $self->{parent_member} = $parent_member;
  $self->{parent_field} = $parent_field;
  $self->{child_member} = $child_member;
  $self->{child_field} = $child_field;

  return $self;

}

$Relations::Family::Lineage::VERSION;