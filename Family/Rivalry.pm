# This is a component of a DBI/DBD-MySQL Relational Query Engine module. 

package Relations::Family::Rivalry;
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

$Relations::Family::Rivalry::VERSION = '0.91';

@ISA = qw(Exporter);

@EXPORT    = ();		

@EXPORT_OK = qw(new);

%EXPORT_TAGS = ();

# From here on out, be strict and clean.

use strict;

# Create a Relations::Family::Rivalry object.This object 
# holds a one-to-one relationship between two tables.
# This is when the first one table (brother) is connected 
# to a second one table (sister) via a primary key.

sub new {

  # Get the type we were sent

  my ($type) = shift;

  # Get all the arguments passed

  my ($sister_member,
      $sister_field,
      $brother_member,
      $brother_field) = rearrange(['SISTER_MEMBER',
                                   'SISTER_FIELD',
                                   'BROTHER_MEMBER',
                                   'BROTHER_FIELD'],@_);

  # $brother_member - Brother family member (one)
  # $brother_field  - Brother primary key
  # $sister_member  - Sister family member (one)
  # $sister_field   - Sister primary key

  # Create the hash to hold all the vars
  # for this object.

  my $self = {};

  # Bless it with the type sent (I think this
  # makes it a full fledged object)

  bless $self, $type;

  # Add the info into the hash only if it was sent

  $self->{sister_member} = $sister_member;
  $self->{sister_field} = $sister_field;
  $self->{brother_member} = $brother_member;
  $self->{brother_field} = $brother_field;

  return $self;

}

$Relations::Family::Rivalry::VERSION;