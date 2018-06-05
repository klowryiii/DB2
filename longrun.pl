#!/usr/bin/perl -swnl
#  This script pulls out AVG exec time, num execs and
#  Statement text of sqls from snap where avg exec time
#  is greater than the \$sqltime variable below
#    Generate a snapshot or use an archived snapshot file
#  -command used to generate: db2 get snapshot for all on [dbname]
#   BASIC USAGE:  longrun.pl [-t=secs]  snapshot.file
#  -command to get data in chronological order: ls -tr dbrun*.snap | xargs perl [-t=5] ./longrun.pl | more

BEGIN {

        #print usage if no filename
        $#ARGV < 0 and print "Usage: longrun.pl [-t=2.5] filename\n       -t defaults to 1 second " and exit 1;

        $oldfile='';

        #if time switch not defined set to default of 1
        defined $t or $t=0.0;

}

#set file to current filename
$file=$ARGV;

#if file switches print out header info
if ( $file ne $oldfile &&  $file !~ m/nb/ ) {

    $cmd="grep 'Snapshot timestamp' $file | cut -d '=' -f2 | uniq| tail -1";
    $timestamp=`$cmd`;

  print "\n\n$file\n";
  print "Timestamp: $timestamp";
  printf ("%-4s %-8s %20s\n", 'AVG','#Execs','Statement Text');
  printf ("%-4s %-8s %20s\n", '===','======','=====' x 5);

}

chomp;

# Get number executions and total time
/Number of executions/ and ($d1,$numex)=split '=';
/Total execution time/ and ($d1,$timex)=split '=';

#if Statment text and positive executions and meets time info
if ( /Statement text/ && $numex > 0 ) { # C

   $per = $timex/$numex ;

   ($d1,$text)=split 't\s+=/',$_;
   ($d1,$text)=split ('=',$_,2);

   $per > $t and printf ("%.3f %d %s\n", $per,$numex,$text);

} # C

eof and $file !~ m/nb/ and print "\n  **End processing for $file **\n";

$oldfile=$file;
