# i3L-COVID19-PC
These scripts are used for data cleanup and analysis in the COVID-19 diagnostics lab of Indonesia International Institute for Life Sciences. We are currently using two machines: Kogene Biotech PowerAmp96 (as Elsa) and ABI 7500 (as Anna); thus requiring two different scripts for the analysis

The goal is to pivot different Genes into their own column (E, RdRp, and RNAse P), remove sample rows that do not have Ct value for both E and RdRp, as well as to check whether there is any contamination in extraction and PCR control. The resulting DataFrame is outputed to an excel file (.xlsx for Elsa and .xls for Anna), which then will be copy-pasted into our ~~Google Sheets~~ **Database**.

## Dependencies
* pandas
* numpy

## How to use
* Download the scripts ([Elsa](https://drive.google.com/file/d/1188WCP-ucjbhiV4Ib9Qh8IMx9RN6DKcY/view?usp=sharing) [Anna](https://drive.google.com/file/d/1hHkjVtMHIxGXo7jDPA7HswbcwscBKhfo/view?usp=sharing))
* Download and install Anaconda (https://www.anaconda.com/products/individual)
* Open anaconda-navigator and launch Jupyterlab
* Open the scripts from within Jupyterlab

then, follow the instruction in the notebook file

(or just ask my help for the setup lol)
