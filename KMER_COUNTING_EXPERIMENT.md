<h1>K-mer based population structure</h1>

<h2>
1. Extracting biallelic SNPs from human VCF file
</h2>

Using <strong>perl_scripts/extract_quality_snips.pl</strong>, 
<strong>sh_scripts/extract_selected_quality_snips30.sh</strong>, 
and <strong>perl_scripts/sample_snps.pl</strong> 
we extract SNPs from the VCF file 
published by researchers of the 1000 genomes project: 
<a href ="ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/release/20130502/">VCF file</a>.

We extract all bi-allelic SNPs from 30 samples of a different continental origin, and we leave only 
the SNPs where variance at the SNP site is at least 10 % 
(i.e. the reference nucleotide has an alternative allele in at least 3 out of 30 samples).

<h2>
2. Extracting context substrings around SNP positions 
</h2>
Using <strong>perl_scripts/snipstocontext.pl</strong>, 
<strong>sh_scripts/extract_context_all.sh</strong>, 
and <strong>sh_scripts/concat_rows.sh</strong>  we extract 
substrings from the reference human genome at positions suggested by the SNPs.

The context length is 151, and the SNP positions are separated by at least 300 nucleotides, 
to avoid sampling overlapping substrings. 

The context substrings are then randomly shuffled. 

<h2>
3. Producing k-mer pairs
</h2>
Using <strong>perl_scripts/contexttokmers.pl</strong>
we extract from these context substrings 
90,000 first
snp-covering k-mers of length 31, where the last character corresponds to the SNP position.
For each such k-mer we add its alternative pair, 
by replacing the last character with an alternative according to the VCF. 

Resulting pairs of k-mers are in file <strong>data/snippairs31_ref.txt</strong>, where 
each 2 lines contain ref genome substring and the same substring with alt char in the last position.

<h2>
4. Counting k-mers 
</h2>

We then perform counting of these k-mer pairs in raw DNA reads for 232 samples sequenced at Broad Institute.
The sample keys are in <strong>data/FILE_NAMES_232_BI.txt</strong>. 
The continent labels for these samples are in <strong>data/FILE_LABELS_232_BI.csv</strong>.

The reads were downloaded from:
<a href="ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/data/">ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/data/</a>.

Counting is performed by running our <a href="https://github.com/mgbarsky/streamcount">streamcount</a> program 
for each of 232 samples. We perform counting in parallel
 on a cluster using the following script: 
<strong>sh_scripts/count_snip_kmers_30.sh</strong>. 

Using <strong>perl_scripts/generaltable.pl</strong>, 
the counting results from different samples 
are combined into a single table of counts with sample keys and class labels: 
<strong>data/COUNTS_TABLE_SNIP_PAIRS.csv</strong>. 
In this table, each row represents a sample, and each column represents a k-mer. 

<h2>
5. Generating input for admixture
</h2>
Using <strong>perl_scripts/countstoped.pl</strong>, 
we now convert the resulting count table into an input for an admixture program - a <strong>ped</strong> file format 
(see: <a href="http://www.gwaspi.org/?page_id=145">format description</a>).

We use the following simple logic:
<ul>
<li>If count for both reference and alt k-mers are non-zero - that is a heterozygote, encoded 1 2.</li>
<li>If count for a ref k-mer is non-zero, but for alt is zero - a homozygote of reference type: 1 1.</li>
<li>If count for a ref k-mer is zero, but for alt is non-zero - a homozygote of alt type: 2 2.</li> 
<li>If both counts are zero - that is an undefined case, where we do not have enough information: 0 0.</li>
</ul>

If both counts are zero for all samples, this k-mer is removed, 
as we cannot have missing values for all samples.
That leaves us with 89,970 valid variants, 
and the result file is in <strong>BI_232_snippaircounts.ped</strong>.

<h2>6. Generating input for PCA</h2>
Using <strong>perl_scripts/pedtomatrix.pl</strong>, 
we convert ped file to a matrix, where each allele is expressed as a single number:
0 for ref homozygote, 2 for alt homozygote, and 1 for ref/alt heterozygote. 
We approximated the missing values with 0.

The result is in file <strong>data/BI_232_snippaircounts_matrix.csv</strong>.

<h2>7. Running admixture</h2>
We run <a href="https://www.genetics.ucla.edu/software/admixture/">https://www.genetics.ucla.edu/software/admixture/</a>
to determine admixture proportion in all samples.
We consider number of fuzzy clusters 2 and 3.
We add class labels to the results, and the results are now in files
<strong>BI_232_snippaircounts_k_2_result.txt</strong>, and <strong>BI_232_snippaircounts_k_3_result.txt</strong>.
We now have all the input files for visualizations.

<h2>8. Visualizing two first Principal Components</h2>
We visualize samples by plotting two largest principal components in 2D by running
<strong>R_scripts/PCA_COUNTS.R</strong> on <strong>data/BI_232_snippaircounts_matrix.csv</strong>.

<h2>9. Visualizing Admixture results</h2>
We generate separate figures for each class label by running <strong>R_scripts/BARPLOT_BYLABEL.R</strong>
on <strong>BI_232_snippaircounts_k_2_result.txt</strong>, and
<strong>BI_232_snippaircounts_k_3_result.txt</strong>.

<h2>10. Numeric comparison of fuzzy clusters</h2>
We want to have a numerical indicator of how close are the k-mer based clusters to the clusters based on SNPs.
To compare admixture results numerically, we use <strong>perl_scripts/compareclusters.pl</strong>, 
where we implemented our modification of a cluster comparison idea from 
<a href="http://org.coloradomesa.edu/~rbasnet/research/ClusteringSimilarityAndItsApplications.pdf">A similarity measure for clustering and its applications</a>.
The results are 0.96 similarity for two clusters, and 0.98 for three.

<h2>11. Congruence of distance matrices</h2>
We create a distance (p-distance) matrix for all 232 samples by running 
<strong>perl_scripts/distances_p.pl</strong>.

We then calculate the congruence between this distance matrix and the distance matrix obtained for SNPs, 
using CADM function from the <a href="https://cran.r-project.org/web/packages/ape/index.html">ape package</a>.
The congruence is 0.91. 




