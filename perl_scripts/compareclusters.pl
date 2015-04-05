#! /usr/bin/perl
# Here we are comparing the results of clustering
#created by admixture program, and stored in files, where labels have been sorted; BI_232_k_3_result_sortedbyID.txt
#each row represents a sample point
#columns are tab-delimited, and are in the following format:
#NA19914	AFR	0.000010 0.700326 0.299664
#we are assuming that there is an equal number of clusters and 
#that the points are sorted by id, so each row corresponds to the same point in both of them

use strict;
use List::Util qw[min max];
use Getopt::Long;

my $clusterFile1 = "";
my $clusterFile2 = "";
GetOptions("file1=s" => \$clusterFile1,
"file2=s" => \$clusterFile2);

#collect program arguments
if($clusterFile1 eq "" or $clusterFile2 eq "")
{
    print "Error: file names for both clusters must be provided: --file1 FILE NAME --file2 FILE NAME\n";   
    exit 1;
}


#open input file to find number of columns (clusters) and of rows (samples)
open my $reader, $clusterFile1 or die "error trying to open cluster file 1 for reading: $!";
my $lineID=0;
my $totalClusters=0;
while(my $line = <$reader>)
{	   
    if ($lineID == 0)
	{
		chomp $line;
		my @lineArray = split(" ",$line);
		
		$totalClusters = $#lineArray -1; #two first columns are id and label
	}

	$lineID ++;	
    
}
my $totalSamples=$lineID;
close $reader;

print STDERR "There are total $totalSamples samples and $totalClusters clusters\n";

$lineID=0;

my $totalSimilarity = 0;
#now convert to comma-separated matrix
open my $reader1, $clusterFile1 or die "error trying to open cluster file 1 for reading: $!";
open my $reader2, $clusterFile2 or die "error trying to open cluster file 2 for reading: $!";

my @intersectionsperCluster;
my @unionsPerCluster;

for (my $i=0; $i<$totalClusters ; $i++) 
{
	$intersectionsperCluster[$i] = 0;
	$unionsPerCluster[$i] = 0;
}

while(my $line1 = <$reader1> )
{
	my $line2 = <$reader2>;

	chomp $line1;  
	chomp $line2;  
	
	
	#split content of two tab-separated lines into arrays: @lineArray1 and  @lineArray2
	my @lineArray1 = split(" ",$line1);	    	
	my @lineArray2 = split(" ",$line2);
    
	#first make sure that we are testing the same data point
    if (  $lineArray1[0] ne $lineArray2[0])
	{
		print "Incomparable data points \n";
		exit 1;
	}

    for (my $i=2; $i<=$#lineArray1 ; $i++) 
    {            
        #collect how much weight is in common for this cluster, and how much total weight 
       	my $common = min ($lineArray1[$i] , $lineArray2[$i]);
		my $total = $lineArray1[$i]+$lineArray2[$i];

		my $union = $total - $common; # total - 2*common + common
		#collecting into union of cluster $i-2
		$intersectionsperCluster[$i-2] += $common;
		$unionsPerCluster[$i-2] += $union;		
    }
       
    $lineID++;

    
	print "Processed sample $lineID \n";	
    
}

close $reader1;
close $reader2;
print "Processed total $lineID points. \n";

for (my $i=0; $i<$totalClusters ; $i++) 
{
	print 	"cluster $i intersection ".$intersectionsperCluster[$i]." union ".$unionsPerCluster[$i]."\n";
	$totalSimilarity += $intersectionsperCluster[$i]/$unionsPerCluster[$i];	
}
my $clusterSimilarity = $totalSimilarity/$totalClusters;
print "Total point similarity for $totalClusters is  $totalSimilarity and the cluster similarity measure is $clusterSimilarity. \n";	

