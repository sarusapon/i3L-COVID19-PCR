# i3L-COVID19-PC
These scripts are used for data cleanup and analysis in the COVID-19 diagnostics lab of Indonesia International Institute for Life Sciences. We are currently using two machines: Kogene Biotech PowerAmp96 (as Elsa) and ABI 7500 (as Anna); thus requiring two different scripts for the analysis

The goal is to pivot different Genes into their own column (E, RdRp, and RNAse P), remove sample rows that do not have Ct value for both E and RdRp, as well as to check whether there is any contamination in extraction and PCR control. The resulting DataFrame is outputed to an excel file, which then will be copy-pasted into our ~~Google Sheets~~ **Database**.

## Dependencies
* pandas
* numpy

## How to use
* Download the scripts ([Elsa](https://drive.google.com/file/d/1188WCP-ucjbhiV4Ib9Qh8IMx9RN6DKcY/view?usp=sharing) & [Anna](https://drive.google.com/file/d/1hHkjVtMHIxGXo7jDPA7HswbcwscBKhfo/view?usp=sharing))
* Download and install Anaconda (https://www.anaconda.com/products/individual)
* Open anaconda-navigator and launch Jupyterlab
* Open the scripts from within Jupyterlab
* Copy the filename (if scripts and files in one directory) or the filepath into the designated location (file_directory) as explained in the notebook
* Run all cells (click the double arrow '>>' button)

Output file will be generated on the same directory as the scripts


## Things to make sure before using the scripts


* <span style="color:red">**THERE ARE NO BATCHES WHERE THE SAMPLES ARE NOT 15. Please use the alternative version of the script in this case.**</span> (Technically, this script can still be used with more/less than 15 samples, as long as the extraction control is at number 15)
* No duplicate Sample ID (else it will cause error in the pivoting step)

For Elsa:
* Ensure positive and PCR controls (NTC) are properly named (e.g. POS01, POS02, NTC01, NTC02, etc.)

For Anna:
* When exporting, only block the wells with samples (don't select all wells if the run is less than six batches)
* The run is exported as it is (you don't have to remove parameters/columns from the export tool)
* All genes (E, RDRP, RNAse P) are included when exporting


(for PCR team, please message me anytime if you have any questions about the setup or if there is any error)
