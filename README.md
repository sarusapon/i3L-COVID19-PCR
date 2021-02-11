# i3L-COVID19-PC (.py version)
These scripts are used for data cleanup and analysis in the COVID-19 diagnostics lab of Indonesia International Institute for Life Sciences. We are currently using two machines: Kogene Biotech PowerAmp96 (as Elsa) and ABI 7500 (as Anna).

The goal is to pivot different Genes into their own column (E, RdRp, and RNAse P), remove sample rows that do not have Ct value for both E and RdRp, as well as to check whether there is any contamination in extraction and PCR control. The resulting DataFrame is outputed to an excel file, which then will be copy-pasted into our ~~Google Sheets~~ **Database**.


## Dependencies
* pandas
* numpy



## How to use


First time run:
* Download Python 3
* Install pandas module
 > Enter in CMD/Terminal:
 
 >pip install pandas


How to run the script:
* Run the Python script from CMD/Terminal
 > Change directory to folder containing the script, e.g.:
 
 >cd '/Users/sarusapon/Documents/i3l-covid-pcr-analysis'
 
 >and then run the script:
 
 >python3 i3l-covid-pcr-analysis.py

Output file will be generated on the same directory as the scripts


## Things to make sure before using the scripts


* ~~THERE ARE NO BATCHES WHERE THE SAMPLES ARE NOT 15~~ fixed in .py version
* No duplicate Sample ID (else it will cause error in the pivoting step)

For Elsa:
* Ensure positive and PCR controls (NTC) are properly named (e.g. POS01, POS02, NTC01, NTC02, etc.)

For Anna:
* ~~When exporting, only block the wells with samples (don't select all wells if the run is less than six batches)~~ fixed in .py version
* All genes (E, RDRP, RNAse P) are included when exporting
* The run is exported as it is (you don't have to remove parameters/columns from the export tool)


(for PCR team, please message me anytime if you have any questions about the setup or if there is any error)


### To do list:
* Google sheets API integration for sampling location
* GUI (let's see lmao)
