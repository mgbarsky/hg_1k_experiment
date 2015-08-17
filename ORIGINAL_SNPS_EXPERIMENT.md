<h1>Experiment with original SNPs</h1>

<h1>
</h1>
<h2>
1. Extracting biallelic SNPs from human VCF file
</h2>

Using <strong>perl_scripts/extract_quality_snips.pl</strong>,
<strong>sh_scripts/extract_all_quality_snips.sh</strong>, 
<strong>sh_scripts/extract_selected_quality_snips30.sh</strong>, 
and <strong>perl_scripts/sample_snps.pl</strong> 
we extract SNPs from the VCF file 
published by researchers of the 1000 genomes project: 
<a href ="ftp.1000genomes.ebi.ac.uk/vol1/ftp/release/20130502/">VCF file</a>.

We extract all bi-allelic SNPs, 
and we leave only 
the SNPs where variance at the SNP site is at least 10 %.

The result is in <strong>ALL_QUALITY_SNIPS.csv</strong>.

<h2>
2. PED encoding for Admixture
</h2>
To extract only columns corresponding to 232 samples from Broad institute, 
and convert them into ped format (see: <a href="http://www.gwaspi.org/?page_id=145">format description</a>),
 we run
<strong>perl_scripts/snipstopedencoding_selectedsample.pl</strong>.

The resulting 91,729 SNPs are in <strong>BI_232_samples.ped</strong>.

To test whether we can study 232 samples if we only would have snps from 30 samples,
we also extract SNPs from only 30 random samples, and use them to compare 232 original samples. 
The resulting ped file is <strong>BI_232_samples_30_markers.ped</strong>.
 
<h2>
3. Generating input for PCA
</h2>
To convert a ped format to a simple matrix for Principal Component Analysis, we run
<strong>perl_scripts/pedtomatrix.pl</strong> for both inputs generated in 2.

The output files are <strong>BI_232_samples_matrix.csv</strong>, and
<strong>BI_232_samples_30_markers_matrix.csv</strong>.

The entries of this matrix are:
<ul>
<li>alt/alt - 2</li>
<li>ref/ref - 0</li>
<li>ref/alt - 1</li>
</ul>

<h2>
4. Running admixture
</h2>
We run <a href="https://www.genetics.ucla.edu/software/admixture/">https://www.genetics.ucla.edu/software/admixture/</a>
to determine admixture proportions in all 232 samples.
We consider number of fuzzy clusters: 2 and 3.
We add class labels to the results, and the results are now in files
<strong>BI_232_samples_30_markers_2_result.txt</strong>, and <strong>BI_232_samples_30_markers_3_result.txt</strong> for markers extracted from 30 samples.
and in files <strong>BI_232_samples_k_2_result.txt</strong>, 
and <strong>BI_232_samples_k_3_result.txt</strong> for markers extracted from all 232 samples.
We now have all the input files for visualizations.

<h2>5. Visualizing two first Principal Components</h2>
We visualize samples by plotting two largest principal components in 2D by running
<strong>R_scripts/PCA_SNIPS.R</strong> on <strong>data/BI_232_samples_matrix.csv</strong>, and on
<strong>data/BI_232_samples_30_markers_matrix.csv</strong>. The visual results are completely identical.

<h2>6. Visualizing Admixture results</h2>
We generate separate figures for each class label by running <strong>R_scripts/BARPLOT_BYLABEL.R</strong>
on all admixture results obtained in step 4.

<h2>7. Numeric comparison of fuzzy clusters</h2>
We want to have a numerical indicator of how close are the clusters based on SNPs from 30 samples 
to the clusters based on SNPs from all 232 samples.
To compare admixture results numerically, we use <strong>perl_scripts/compareclusters.pl</strong>, 
where we implemented our modification of a cluster comparison idea from 
<a href="http://org.coloradomesa.edu/~rbasnet/research/ClusteringSimilarityAndItsApplications.pdf">A similarity measure for clustering and its applications</a>.
The results are 0.997 similarity for two clusters, and 0.997 for three.
This confirms that we can use 
SNPs obtained from 30 samples to study much larger populations.
Thus, we use the SNPs from these 30 samples in all further experiments.
