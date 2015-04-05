#! /usr/bin/perl
# Converts table of expected snp counters to a distance matrix - p-distance  - shared allele distance

#This portion is common to all distances
#*******************************************
use strict;
use Getopt::Long;

my $tableFile = "";   #file with the table: first in the row - is sample type, second - sample name, then values for each snip


GetOptions("t=s" => \$tableFile);

#collect program arguments
if($tableFile eq ""  )
{
	print "Error: provide the name of a file with expected values --t TABLEFILE \n";
    	
    	exit 1;
}


#open output file for writing a new table of distances in 
open WRITER, '>', "$tableFile".".P-DISTANCE.csv" or die "error trying to open output file: $!";

#open input files for reading a table of expected values
my $tableReader; 
open my $tableReader, $tableFile or die "error trying to open input table file: $!";

#read entire table into a 2D array
our @table;  #to be  visible in a distance function calculation

our $totalSnips;

my $lineNumber = 0;

while (my $line = <$tableReader>)
{
   	chomp $line;
	my @lineArray = split(',', $line);
	

	for (my $i=2; $i <= $#lineArray; $i ++) 
	{
		my $rounded =  int ($lineArray[$i]); 
		$table [$lineNumber] [$i-2] = $rounded;

		#sanity check
		if($rounded < 0 or $rounded >2)
		{
			print "Invalid expected value $rounded \n";
			exit (1);
		}	
	}
	if($lineNumber==0)
    {
        $totalSnips = $#lineArray-2+1; 
    }
	$lineNumber++;		
}

close $tableReader;

my $totalIndividuals = $lineNumber;
 print "Total snips = $totalSnips total individuals = $totalIndividuals \n";



#iterate over all individuals and calculate distance between each pair
my @distances; #2D table of distances

for (my $first=0; $first < $totalIndividuals ; $first ++) 
{
	
	for (my $second=0; $second < $totalIndividuals ; $second++)
	{
		if($first == $second)
        {
            $distances [$first] [$first] = 0;
        }
        else
        {
            my $result = getDistance ($first, $second);
		    #put into 2D matrix
		    $distances [$first] [$second] = $result;
        }
	}
    print "Finished distances for row $first \n";
}
$distances [$totalIndividuals-1][$totalIndividuals-1]=0;

#iterate over distances table and record each row into output file
#print WRITER $totalIndividuals . "\n";
for (my $row=0; $row < $totalIndividuals ; $row ++) 
{
	my $out_line = $distances [$row] [0];
	for (my $col=1; $col < $totalIndividuals ; $col++)
	{
		$out_line = $out_line . ',' . $distances [$row] [$col];		
	}
	print WRITER $out_line . "\n";
}

#This one is different for each distance type
#************************************ 
sub getDistance
{
	my ($first, $second) = @_;
	my $totalAlleles = 2 * $totalSnips;
	my $distance;
	my $differentSitesCounts = 0;

	for(my $col=0; $col < $totalSnips; $col ++)
	{
		if($table [$first][$col] != $table [$second][$col])
		{
			$differentSitesCounts+=(abs ($table [$first][$col] - $table [$second][$col]));
		}	
	} 
	
  	$distance = $differentSitesCounts/$totalAlleles;	
	
	return $distance;
}


