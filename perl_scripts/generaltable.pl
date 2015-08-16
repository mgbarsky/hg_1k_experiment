#! /usr/bin/perl
# Gives a table of counts per each pattern line
use strict;
use Getopt::Long;

my $fileList = "";   #file with the names of the files, /.mounts/labs/simpsonlab/users/mbarsky/hg/seq_only/FILE_NAMES.tx for each there already exists /.mounts/labs/simpsonlab/users/mbarsky/hg/seq_only/$line_31-mers_COUNTS.txt
my $patternsFile = 0;   #txt file with _31-mers_MAPPINGS.txt


GetOptions("f=s" => \$fileList,
           "p=s" => \$patternsFile);

#collect program arguments
if($fileList eq "" || $patternsFile eq "")
{
	print "Error: provide names of file list file and pattern file\n";
    	usage();
    	exit 1;
}


#open output file for writing a table
open TABLEWRITER, '>', "$patternsFile"."_COUNTS_GENERAL_TABLE.txt" or die "error trying to open output file: $!";

#open input files for reading
my $countsReader; #file handle to read each counts file


open my $linesReader, $patternsFile or die "error trying to open patterns mapping file: $!";

my @lines; #holds all lines describing patterns

#read patterns file into an array of lines - each line will be processed separately
while (my $line = <$linesReader>)
{
   	chomp $line;
	push (@lines, $line);   # we will add it to the array.		
}

close $linesReader;

#read all file names into an array of files
my @files; #holds all file names provided in  @fileList file
open my $filesReader, $fileList or die "error trying to open file list file: $!";
while (my $fileName = <$filesReader>)
{
   	chomp $fileName;
	push (@files, $fileName);   # we will add it to the array.		
}

close $filesReader;

my $numOfPatterns ;

my $i; #position in an array of patterns
#now we are going in the loop and for each file generate a line with all counters
for (my $fn=0; $fn<= $#files; $fn++)
{
	my $output_row = $files[$fn];
	my $row_total = 0;	

	
	#first we will generate an array holding summary counters in this file for each pattern
	#for this we need to read counters from counters file into an array
	open my $countsReader, "data/snipcounts/".$files[$fn].".fastq_31-mers_COUNTS.txt" or die "error trying to open counters file: $!";
	my @counters;
	while (my $counter = <$countsReader>)
	{
	   	chomp $counter;
		push (@counters, int ($counter));   # we will add it to the array.
			
	}
	
	close $countsReader;

	my $numValidPatterns =0;
	for ($i=0; $i <= $#lines; $i ++) 
	{
		my @lineArray = split('\t', $lines[$i]);
	
		my $counterID = $lineArray[2];
		my $rcCounterID = $lineArray[3];
		my $repeated = $lineArray[4];
		if ($counterID <= 0 or $rcCounterID <= 0 or $counterID > $#counters or $rcCounterID > $#counters)
		{
			print STDERR "Error in mapping pattern to tree leaves: row $i, counter ids ($counterID, $rcCounterID) \n";
		}
		if(!$repeated)
		{
			my $countPerFilePerPattern = int ($counters[$counterID]) + int ($counters[$rcCounterID]);
			$output_row = $output_row . "\t". $countPerFilePerPattern;
			$numValidPatterns++;
		}
	} 
	
	$numOfPatterns = $numValidPatterns;
	#write row with counters into a table file
	print TABLEWRITER $output_row . "\n";
	print "Processed file $fn with $numValidPatterns non-repeating patterns \n";	
}


my $numOfFiles =  $#files +1;
print STDERR "Processed total $numOfPatterns k-mers and $numOfFiles files\n";

sub usage
{
    print "generaltable.pl - generates a set of lines by applying variants to a context extracted from reference genome\n";
    print "Usage: counterstopatterns.pl --f FILELIST --p PATTERNSINFOFILE\n";
    print "\n";
    print "Options:\n";
    print "               --f=FILESLIST\n";
    print "               --p=PATTERNSMAPPING\n";
}

#snpcontexttolines.pl --n 5000

