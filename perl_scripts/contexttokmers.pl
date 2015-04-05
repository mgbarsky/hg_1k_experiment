#! /usr/bin/perl
# Creates lines from randomly chosen snps from snpcontext.txt
use strict;
use Getopt::Long;

my $numKmers = 0;   #how many total lines to have
my $inputFile="";
my $k = 0;
GetOptions("f=s" => \$inputFile,
	   "k=s" => \$k, "n=s" => \$numKmers);

#collect program arguments
if($inputFile eq "" || $k eq "" || $k == 0 )
{
	print "Error: provide input file(--f), and the value of k(--k)\n";    	
    	exit 1;
}

#open output files for writing
open SNIPWRITER, '>', "$inputFile"."snippairs$k.txt" or die "error trying to open output file for snips: $!";
open RANDWRITER, '>', "$inputFile"."random$k.txt" or die "error trying to open output file for random reference k-mers: $!";

#open input file for reading
open my $reader, $inputFile or die "error trying to open input file: $!";

my $cnt=0;
my $snipCount = 0;
my $randCount =0;

while (my $line = <$reader> and ($snipCount < $numKmers or $randCount < $numKmers) )
{
   	chomp $line;

	if ($line ne "")
	{
		#split content of a comma-separated line into an array: @lineArray 
		my @lineArray = split(',', $line);

		my $seq = $lineArray[0];
		my $pos1 = int ($lineArray[1]);
		my $char1 = $lineArray[2];
		my $pos2 = int ($lineArray[3]);
		my $char2 = $lineArray[4];

		#check that there is really this base at this position
		if(substr ($seq, $pos1,1) ne $char1)
		{
			print "In the context string there is a different character at position $pos1 expected  $char1 \n";
			exit(1);
		}
		
		if ($snipCount < $numKmers)
		{
			#generate reference k-mer covering snip
			my $snip1 = substr $seq, ($pos1-$k+1), $k;
	
			#we take a non-ref char
			my $snip2 = $snip1;
			substr($snip2, -1,1) = $char2;

			#write this pair of snips to the output file
			print SNIPWRITER $snip1."\n";
			print SNIPWRITER $snip2."\n";
			$snipCount ++;
		}

		#find 1 random k-mers - 
		#starting before or after pos 1
	
		my $randsubstr = "";
		my $seq_len = length ($seq); 
	
		#starting BEFORE $pos1
		my $last_pos = $pos1-$k;
		my $first_pos = 0;
		my $randomPos = int(rand($last_pos -$first_pos )+$first_pos); 
		$randsubstr = substr $seq, $randomPos, $k;
		
		if (length ($randsubstr) == $k)
		{
			#write 1 rand k-mers to file
			print RANDWRITER $randsubstr."\n";
			$randCount++;
		}
	
		$cnt++;
	}
}

close $reader;


print STDERR "Total lines $cnt, extracted $snipCount snp pairs and $randCount random reference k-mers\n";



#snpcontexttolines.pl --n 5000

