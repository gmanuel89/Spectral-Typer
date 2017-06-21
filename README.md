# SPECTRAL TYPER

***

## Program version
In order for this WIKI to be applicable, the version of the program must be equal to or higher than **2017.06.21.0**.

***

## Programming language
[R: The Comprehensive R Archive Network](https://www.r-project.org/)

***

## Platform(s) tested
Ubuntu Linux 16.04 x64 - R 3.4.0

Fedora Linux 25 x64 - R 3.4.0

Microsoft Windows 7 x64 - R 3.4.0

Microsoft Windows 10 x64 - R 3.4.0

***

## Scope of the software
The software imports two separate groups of mass spectra (stored in different file formats), performs spectral preprocessing onto the imported spectra (with different parameters) and performs comparisons between each spectrum of a group identified as "Sample" group and each spectrum of the group identified as "Reference" group. In order to do so, the software performs at every iteration, for each reference-sample pair, peak picking, peak alignment and pairwise peaklist comparisons in terms of number of common signals and signal intensity evaluation.

The software returns the results of the comparison as a matrix, in which each row is a sample (spectrum in the "Sample" group) and each column is a Reference entry (spectrum in the "Reference" group). Each matrix entry corresponds to the similarity score, which generally is "YES" for a complete match, "NI" for partial match and "NO" for mismatch, in terms of score value reaching a defined threshold value. 

Moreover, an additional matrix file is exported, containing all the parameters used for the analysis, such as the mass range and the values of the parameters used for the comparison analysis.

***

## Type of data and its organization

#### Type of data
The software can import spectral files in different file formats: [Xmass](https://www.bruker.com/products/mass-spectrometry-and-separations/ms-software.html) (Bruker Daltonics Xmass format), TXT, CSV, MSD and [imzML](https://ms-imaging.org/wp/introduction/) (imaging datasets) files. 


#### Organization of the data
The spectral files should be organized in two separate folders, which must be provided to the software: the reference folder and the sample folder. The folder/file structure should strictly be as follows, with no additional folders/files, in order to avoid software crashes or misfunctioning.

**One-level**: The reference folder should contain either free files (each file will constitute a reference entry) or one folder for each reference entry, containing all the replicates for that entry, in such a way that all the spectra in each folder are averaged to yield one representative spectrum for each reference entry.
**Two-level**: The reference folder should contain one folder for each reference entry, in such a way that all the spectra in each folder are averaged to yield one representative spectrum for each reference entry. The spectra in the reference subfolders can be further grouped in replicates by using another subfolder (each subfolder containing all the replicates for that condition).

**One-level**: The sample folder should contain either free files (each file will constitute a sample) or one folder for each sample, containing all the replicates for that entry, in such a way that all the spectra in each folder are averaged to yield one representative spectrum for each reference entry.
**Two-level**: The sample folder should contain one folder for each sample, and each sample's folder should contain one subfolder for each condition, with all the replicates for that condition inside the subfolder. In this way that all the spectra in each subfolder are averaged to yield one representative spectrum for each sample under the same condition. If there are no condition subfolders, each individual spectrum is considered as a different condition and no averaging is performed.

Moreover, spectral files can be saved, both for the reference and for the samples, in order to evaluate the spectral preprocessing and the peak picking.


#### Output data
The software generates a file corresponding to the result matrix, in which each row is a sample and each column is a reference entry, with the similarity score for each pair. The file format can be either CSV or XLS/XLSX, in the latter case with cells automatically colored in green for YES, yellow for NI and red for NO.

* **F (Fit)**: it is calculated as the proportion of the number of signals of the sample that are in the reference spectrum (common reference-sample signals / sample signals)
* **RF (Retro-fit)**: it is calculated as the proportion of the number of signals of the reference that are in the sample spectrum (common reference-sample signals / reference signals)
* **Correlation**: it displays the value of the Pearson's or Spearman's rho (correlation coefficient) between the signal intensities of the sample and the signal intensities of the reference
* **p-value**: The p-value of the computed correlation
* **ns**: Number of signals onto which the correlation is computed
* **IntMtch**: it displays the percentage of the common sample-reference signals that have matching intensity, in terms of percent difference under a certain set threshold
* **SI (Similarity Index)**: it displays the similarity index score

The spectra files are placed in a folder with the same name as the peaklist file, with two subfolders, one for the "Reference" and one for the "Samples": if "MSD" is selected as the file format, one MSD file for each spectrum is generated, with the peaks embedded in the same file; if "TXT" is selected as the file format, two TXT files are generated, one for the spectrum and one for the peaks.

***

## Buttons, entries and operations

* **Spectra format**: selects the format of the input spectral files (imzML, Xmass, TXT, CSV or MSD).

* **Average replicates in the reference**: selects if the replicates for each treatment should be averaged in the reference, to generate one representative spectrum per treatment.

* **Average replicates in the samples**: selects if the replicates for each treatment should be averaged in the samples, to generate one representative spectrum per treatment.

* **Format of the exported file**: sets the type of the exported files ("CSV", "XLS" or "XLSX").

* **Score only**: selects if all the score components (Fit, Retrofit and Signal Intensity Comparison) should be printed in the output ("NO") or only the overall results ("YES", "NI", "NO") should be retuned ("YES").

* **Display the spectra path in the output**: selects if one column listing the file path for each sample spectrum should be added to the result matrix.

* **Peak picking algorithm**: selects the algorithm to be employed for peak picking ("Friedman's Super Smoother" or "Median Absolute Deviation").

* **Peak deisotoping enveloping**: defines if "Peak deisotoping" (preserve only the monoisotipic peak of the isotope cluster) or "Peak enveloping" (preserve only the most intense peak of the isotope cluster) should be performed after peak picking.

* **Signal-to-noise ratio**: defines the signal-to-noise ratio to be used as a threshold for peak picking, after noise estimation.

* **Peak picking mode**: defines if "all" the peaks should be kept or only the "most intense" for each spectrum.

* **Most intense signals to take**: defines the number of most intense signals to preserve (if "most intense" is selected as "Peak picking mode").

* **Peak filtering threshold percentage**: defines the percentage threshold according to which all the peaks that are not present in at least the selected percentage of the spectra are discarded.

* **Low-intensity peak removal percentage threshold**: defines the percentage threshold according to which all the peaks that have an intensity below the selected percentage of the base peak are discarded.

* **Low-intensity peak removal threshold method**: selects the method for base peak identification, according to which the low-intensity peak removal is performed for each spectrum evaluating the intensity of the base peak of that spectrum ("element-wise") or the base peak of the whole spectral dataset ("whole").

* **Intensity tolerance percent**: defines the tolerance (in %) to be used in "signal intensity" comparison to define two intensity-matching signals (between the sample and the reference entry)

* **Choose similarity criteria**: defines the way in which the signal intensity comparison between sample spectra and reference entry spectra should be performed ("Correlation", "Hierarchical Clustering Analysis - HCA", "Signal intensity", "Similarity index").
    * **_Correlation_**: searches for a similar trend in the signal intensity between the sample and the reference entry by computing the "Pearson's correlation" (estimating Pearson's rho) or the "Spearman's rank-order correlation" (estimating Spearman's rho).
    * **_HCA_**: computes the spectral similarity by measuring the distance between the sample and the reference entry.
        * *Euclidean*: Usual distance between the two vectors (2-norm aka L2-norm : the square root of the sum of the differences squared between two samples (sqrt(sum((x_i - y_i)^2))).
        * *Maximum*: Maximum distance between two components of x and y (supremum norm).
        * *Manhattan*: Absolute distance between the two vectors (1-norm aka L-1 norm).
        * *Canberra*: The sum of the ratios between the absolute value of the sum and the absolute values of the differences between two vectors (sum(|x_i - y_i| / |x_i + y_i|)).
        * *Binary (asymmetric binary)*: The vectors are regarded as binary bits, so non-zero elements are ‘on’ and zero elements are ‘off’. The distance is the proportion of bits in which only one is on amongst those in which at least one is on.
        * *Minkowski*: The p-norm, the pth root of the sum of the pth powers of the differences of the components.
    * **_Signal intensity_**: checks if the intensity of the common signals (between the sample and the reference entry) is similar by evaluating the difference in terms of percentage of intensity (tolerance %). Two signals are identified as matching when their difference in intensity is within a certain tolerance percentage value. (|sample intensity - reference intensity| / reference intensity x 100)
        * *Fixed percentage*: The tolerance value is fixed for every signal across the analysis (defined by the user).
        * *Peak-wise adjusted percentage*: The tolerance value is adjusted for each peak in the comparison between sample and reference entry, the adjustment corresponding to the coefficient of variation of that signal intensity computed over replicates of the reference entry and the sample. The signal is considered matched if the intervals constituted by the intensity value +/- the standard deviation both for the sample and the reference entry overlap.
        * *Average coefficient of variation*: The tolerance value is adjusted for comparison between sample and reference entry, the adjustment corresponding to the average coefficient of variation of signal intensities computed over replicates of the reference entry.
    * **_Similarity index_**: computes the similarity index between the sample and the reference entry by employing signal intensities. It is calculated as the sum of the product between the sample signal intensity and the reference signal intensity divided by the square root of the sum of the sample signal intensity squared and the reference signal intensity squared (Monigatti F, Berndt P. "Algorithm for accurate similarity measurements of peptide mass fingerprints and its application". J Am Soc Mass Spectrom. 2005 Jan;16(1):13-21.)

* **Score threshold values**: defines the two values to be used to define the overall score of the spectral comparison ("YES", "NI", "NO").

* **Allow parallelization**: enables the parallel computation (multi-CPU computation).

* **Browse reference folders...**: select the folder in which all the spectra to be used as "Reference" are stored.

* **Browse samples folders...**: select the folder in which all the spectra to be used as "Samples" are stored.

* **Browse output folder...**: selects the folder in which all the output files should be saved.

* **Spectra preprocessing parameters**: sets the parameters for spectral preprocessing.
    * **_Mass range_**: defines the mass range to which the imported spectra should be cut.
    * **_TOF mode_**: defines if the TOF has been used in the "Linear" or "Reflectron" mode (to adjust the parameters for spectral preprocessing and peak picking).
    * **_Data transformation_**: selects if data transformation should be performed (applies a mathematical operation to all the intensities, among "Square root", "Natural logarithm", "Decimal Logarithm" and "Binary Logarithm").
    * **_Smoothing_**: defines the algorithm for the spectral smoothing ("Savitzky-Golay", "Moving Average", "None") and the strength of the smoothing ("medium", "strong", "stronger").
        * *Savitzky-Golay*: It is a process known as convolution, by fitting successive sub-sets of adjacent data points with a low-degree polynomial by the method of linear least squares. (A. Savitzky and M. J. Golay. 1964. Smoothing and differentiation of data by simplified least squares procedures. Analytical chemistry, 36(8), 1627-1639).
        * *Moving Average*: Given a series of numbers and a fixed subset size, the first element of the moving average is obtained by taking the average of the initial fixed subset of the number series. Then the subset is modified by "shifting forward"; that is, excluding the first number of the series and including the next value in the subset. (Booth et al., San Francisco Estuary and Watershed Science, Volume 4, Issue 2, 2006).
    * **_Baseline subtraction_**: defines the algorithm for baseline subtraction ("SNIP", "TopHat", "ConvexHull", "median", "None"). Before selecting the baseline subtraction algorithm, a number defining the value of the specific parameter for the algorithm can be inserted, and the program will read it while setting the baseline subtraction algorithm.
        * *SNIP*: Statistics-sensitive Non-linear Iterative Peak-clipping algorithm (C.G. Ryan, E. Clayton, W.L. Griffin, S.H. Sie, and D.R. Cousens. 1988. Snip, a statistics-sensitive background treatment for the quantitative analysis of pixe spectra in geoscience applications. Nuclear Instruments and Methods in Physics Research Section B: Beam Interactions with Materials and Atoms, 34(3): 396-402).
        * *TopHat*: This algorithm applies a moving minimum (erosion filter) and subsequently a moving maximum (dilation filter) filter on the intensity values (M. van Herk. 1992. A Fast Algorithm for Local Minimum and Maximum Filters on Rectangular and Octagonal Kernels. Pattern Recognition Letters 13.7: 517-521).
        * *ConvexHull*: The baseline estimation is based on a convex hull constructed below the spectrum (Andrew, A. M. 1979. Another efficient algorithm for convex hulls in two dimensions. Information Processing Letters, 9(5), 216-219).
        * *Median*: This baseline estimation uses a moving median.
    * **_Normalization_**: defines the algorithm for normalization ("TIC", "RMS", "PQN", "median", "None"). Before selecting the normalization algorithm, a number defining the normalization mass range can be inserted, and the program will read it while setting the normalization algorithm.
        * *TIC (Total Ion Current)*: It divides the intensities of the spectrum by the sum of all the intensity values of the spectrum itself (the sum of all the intensities being the spectrum's total current). It becomes less suitable when very intense peak(s) (compared to the others) are present in the spectrum.
        * *RMS (Root Mean Square)*: It divides the intensities of the spectrum by the square root of the sum of all the intensity values of the spectrum itself squared. Like the TIC, it becomes less suitable when very intense peak(s) (compared to the others) are present in the spectrum.
        * *PQN (Probabilistic Quotient Normalization)*: It calibrates the spectra using the TIC normalization; then, a median reference spectrum is obtained; the quotients of all intensities of the spectra with those of the reference spectrum are calculated; the median of these quotients is calculated for each spectrum; finally, all the intensity values of each spectrum are divided by the median of the quotients for the spectrum (F. Dieterle, A. Ross, G. Schlotterbeck, and Hans Senn. 2006. Probabilistic quotient normalization as robust method to account for dilution of complex biological mixtures. Application in 1H NMR metabonomics. Analytical Chemistry 78(13): 4281-4290).
        * *Median*: It divides the intensities of the spectrum by the median of all the intensity values of the spectrum itself. It has been proved to be the most robust normalization method.
    * **_Align spectra_**: selects if alignment of spectra should be performed, by generating a calibration curve ("cubic", "quadratic", "linear", "lowess") employing an automatically generated peaklist ("auto") as reference or by taking the peaks of the "average spectrum" or of the "skyline spectrum" as reference.
    * **_Preprocess spectra in packages of_**: defines the number of spectra to be taken at a time for preprocessing, when the computer resources are limited (taking all the spectra in RAM could cause the computer to freeze).
    * **_Tolerance (in ppm)_**: defines the tolerance (in ppm, parts per million) for the spectral alignment, peak alignment and reference-sample signal match. For linear TOF mode the tolerance should be set to 1000 ppm (0.1%, 4 Da at 4000 Da), while for reflectron TOF mode the tolerance should be set to 100 ppm (0.01%, 0.2 Da at 2000 Da).
    * **_Commit preprocessing_**: stores the preprocessing parameters to be applied for analysis.

* **Import and preprocess spectra...**: imports the spectra and computes preprocessing (according to the specified parameters), averaging and alignment. It also estimates the spectral variability in terms of coefficient of variation of signal intensity across the replicates for each signal and average coefficient of variation of signal intensity, to be used for adjusting the tolerance parameters in th signal intensity comparison.

* **Run Spectral Typer**: runs the Spectral Typer software. For each sample, for each reference entry, the spectral alignment is performed only if selected by the user, the peak picking and alignment is performed and the similarity parameters are computed.

* **Dump the database**: stores the reference spectra and the signal variability estimation in an RData file, to be imported in the future for further use, skipping the import and the preprocessing on the reference spectra.

* **Dump spectral files...**: generates a folder (named as the peaklist matrix file) in which all the spectral files are saved (MSD or TXT) and organized in two subfolders (one for the "Reference spectra" and one for the "Sample spectra").

* **Quit**: close the program and the R session.

***

## Example

#### Organization of the data
Example of folder hierarchy:

* REFERENCE
    * One-level
        * Spectral files (imzML,TXT,CSV,MSD files or folder containing Bruker's Xmass spectrum data)
        * Class-Entry folders/Replicate spectral files (imzML,TXT,CSV,MSD files or folder containing Bruker's Xmass spectrum data)
    * Two-level
        * Class-Entry folders/Treatment folders/Replicate spectral files (imzML,TXT,CSV,MSD files or folder containing Bruker's Xmass spectrum data)

* SAMPLES
    * One-level
        * Spectral files (imzML,TXT,CSV,MSD files or folder containing Bruker's Xmass spectrum data)
    * Two-level
        * Sample folders/Treatment folders/Replicate spectral files (imzML,TXT,CSV,MSD files or folder containing Bruker's Xmass spectrum data)
    
