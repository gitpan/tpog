#!/usr/bin/perl -w
use strict;


sub sys
{
	my $cmd = shift;
	chomp($cmd);
	$cmd .= "\n";
	print "attempting: $cmd";
	system($cmd)==0 or die "Error on $cmd $!\n";
}

my $upload_dir = '../upload/';
sys("rm -rf $upload_dir");
sys("mkdir $upload_dir");

use Time::localtime;
my $t = localtime; 	# snapshot current time

my $year = $t->year() +1900;
my $month = sprintf("%02d", $t->mon() + 1);
my $day = sprintf("%02d", $t->mday);

my $date = $year .'_'. $month .'_'. $day;

####################################################################
# given a filename, create a uniquified filename based on timestamp
####################################################################
sub uniquify
{
	my $in = shift(@_);
	$in =~ /(.*)(\..*)/;
	my $name = $1;
	my $ext = $2;

	return $name .'.'. $date . $ext;
}


####################################################################
# copy the html file over to upload area
####################################################################

my $orig_html = 'giftware.html';

my $upld_html = $upload_dir . uniquify($orig_html);

sys("cp $orig_html $upld_html");


####################################################################
sub search_and_replace_html
####################################################################
{
	my ($search, $replace) = @_;

	# modify the upload_html to point to the uniquified file
	sys("mv $upld_html $upld_html".".old");

	open(my $rd, "<". $upld_html .".old");
	open(my $wr, '>'.$upld_html);

	while(<$rd>)
		{
		my $line = $_;
		$line =~ s/$search/$replace/;
		print $wr $line;
		}

	close($rd) or die "Error closing $upld_html.old \n";
	close($wr) or die "Error closing $upld_html \n";

	sys ("rm -f $upld_html.old");
}

####################################################################
# copy all the png files over
####################################################################
my @pngs = glob('*.png');

foreach my $png (@pngs)
	{
	my $uniq_png = uniquify($png);
	sys("cp $png $upload_dir".$uniq_png  );

	search_and_replace_html("IMG SRC=\"$png\"",  "IMG SRC=\"$uniq_png\"" );

	}

####################################################################
# set the date in the html file:
####################################################################

search_and_replace_html('yyyy_mm_dd', $date);
