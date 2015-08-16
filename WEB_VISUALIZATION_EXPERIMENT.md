<h1>Web visualization</h1>
<h4>See: <a href="http://projects.oicr.on.ca/visualizing-human-populations/">web tool</a>.</h4>

For our web visualization tool, 
we used results obtained in our <a href="https://github.com/mgbarsky/hg_1k_experiment/blob/master/KMER_COUNTING_EXPERIMENT.md">K-mer counting experiment</a>.
<h2>1. Generating data for web visualization</h2>
<ol>
<li>First, in order to decrease memory used by the browser, 
we checked what is the minimum number of k-mer pairs which produces the same visualization.
We found that about 8,000 markers are enough to separate samples into sub-populations.
As our k-mers are already shuffled, we take first 16,000 counts from each sample, and produce 8,000 allele pairs.
We also save a subset of the first 16,000 k-mers into a separate file <strong>data/snippairs31_8K_ref.txt</strong>  
</li>
<li>
In order to test an idea about visualizing a new sample, we removed four random samples 
of AMR, AFR, ASN, and EUR origin from the PCA matrix 
(see folder <strong>data/samples</strong>) and worked with the remaining 228 samples.
The resulting matrix for 8,000 pairs and for 228 samples is in <strong>ALLELES_8K_228.csv</strong>.
</li>
<li>Using <strong>R_scripts/web_data.R</strong>, we run PCA on this matrix. 
We collect three first principal components into file <strong>data/3PCs_8k_228.csv</strong>. 
This file is used to plot samples in 3D in our web tool.
To be able to compute these principal components from counts for a new sample, 
we save loadings into loading file <strong>LOADINGS.csv</strong>.
</li>
</ol>

<h2>2. Browser visualization </h2>
The 228 samples are visualized by plotting 3 PCs in a 3D space. The data is obtained through Ajax request.
The custom light-weight 3D engine was implemented in Javascript to plot points in 3 dimensions. 
Samples are colored according to the continental group.

<h2>3. Counting k-mers in the browser</h2>
In order to allow user to count k-mers in his custom raw DNA reads, 
without submitting his data to the server, we implement a Javascript 
version of <a href="https://github.com/mgbarsky/streamcount">streamcount</a>.
To go easy on the browser, we pre-computed the keyword tree into a binary file <strong>data/kwtree</strong>,
and we use byte arrays to further decrease the memory in the Javascript program.
Once the user selects his local input file(s), which have to be in the text format, 
the files are streamed through the keyword tree, simultaneously counting all k-mers in one pass.

<h2>4. Visualizing user sample</h2>
The counts of the selected 8,000 k-mers can either be computed in the browser, 
or by running the original <a href="https://github.com/mgbarsky/streamcount">streamcount</a>, 
fast, multi-threaded, implemented in c.

Once the counts of k-mer pairs exist, we can plot a user sample by calculating 3 principal components
using these counts and the loadings file from 1.3.
  
