#!/usr/bin/env perl
#
# Show notification of active tasks
#
# Assumptions:
#  * Prio (A) is important
#  * due:YYYY-MM-DD defines due dates
#  * t:YYYY-MM-DD defines start dates
#
use strict;
use warnings;
use utf8;
use POSIX qw/strftime/;

binmode STDOUT, ":utf8";

my $todocount = 0;
my $current_date = getCurrentDate();

# get date from due string using regular expression
sub getDueDateFromString {
  if(shift =~ /.*due:(\d{4}-\d{1,2}-\d{1,2}).*/) {
    return $1;
  } else {
    return "9999-12-31";
  }
}

# get prio from string
sub getPrioFromString {
  if(shift =~ /.*(\([A-Z]\)).*/) {
    return $1;
  } else {
    return '';
  }
}

# get date from start string using regular expression
sub getStartDateFromString {
  if(shift =~ /.*t:(\d{4}-\d{1,2}-\d{1,2}).*/) {
    return $1;
  } else {
    return "9999-12-31";
  }
}

# show notification, set urgency to critical if task prio is (A)
sub showNotification {
  my $urgency = ($_ =~ /.*(\(A\)).*/) ? "critical" : "normal";
  $urgency = taskIsDue($_) ? "critical" : "normal";
  `notify-send -u "$urgency" -a "Todo.txt" "$_[0]"`;
}

sub taskIsDue {
  my $due_date = getDueDateFromString($_);
  return ($current_date ge $due_date) ? 1 : 0;
}

sub prioIsSet { return getPrioFromString(shift); }
sub duedateIsSet { return getDueDateFromString(shift); }
sub startdateIsSet { return getStartDateFromString(shift); }
sub getCurrentDate { return strftime("%Y-%m-%d", localtime); }

# get all tasks to the array line by line
foreach (split(/\n/,`bash todo.sh -p ls`)) {
  next if not ( $_ =~ /^\d\ .*/); # only tasks (ID)
  next if ( $_ =~ /^\d\ x\ .*/); # not archieved tasks
  next if not ( prioIsSet($_) or duedateIsSet($_) or startdateIsSet($_) );

  my $due_date     = getDueDateFromString($_);
  my $start_date   = getStartDateFromString($_);
  if (
    (($current_date gt $due_date) or ($current_date eq $due_date)) ||
    (($current_date gt $start_date) or ($current_date eq $start_date)) ||
    (prioIsSet($_))
  ) {
    $todocount += 1;
    showNotification($_);
  }
}

if ( $todocount > 0 ) {
  print "🚧" . $todocount . "\n";
  print "🚧" . $todocount . "\n";
  print "#FF8800\n";
} else {
  print "🌴0\n";
  print "🌴0\n";
  print "#00FF00\n";
}
