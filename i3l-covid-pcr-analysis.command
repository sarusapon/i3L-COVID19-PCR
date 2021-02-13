#! /usr/bin/env python
# import packages

import pandas as pd
import numpy as np
import os
import warnings
import time


def readMe():
    m = input("Before using this script, please read ' THINGS TO MAKE SURE BEFORE USING THE SCRIPT '\nPress enter to proceed, or type 'm' to read ('x' to abort) ")

    if m == 'x':
        exit()
    elif m == 'm':
        print(

"""

Things to make sure before using this script:
* No duplicate sample ID

For elsa:
* Ensure positive and PCR controls (NTC) are properly named

For anna:
* All genes (E, RDRP, RNAse P) are included when exporting
* The run is exported as it is (you don't have to remove parameters/columns from the export tool)


        """
        )
        input('Press enter to proceed')
        return False
    elif m == '':
        return False
    else:
        return True


def detect_machine():
    # import the raw export file from Elsa into pandas DataFrame
    global file_directory
    file_directory = input("\nPaste the file path here (without '' mark; change '\\' to '/ for Win; type 'x' to abort): \n")

    # determine elsa or anna export file

    if file_directory == 'x':
        exit()
    elif file_directory.endswith('xlsx'):
        elsa()
        return False

    elif file_directory.endswith('xls'):
        anna()
        return False

    else:
        print('File input error, please try again')
        return True

def elsa():
    warnings.simplefilter("ignore")
    
    try:
        global df
        global machine
        machine = 'elsa'
        df = pd.read_excel(file_directory)
        print('\nFile detected for ELSA 🥶')

    except FileNotFoundError:
        print('File input error, please try again')
        exit()

    # replace '-' to 0

    df['Ct'].replace(['-'],0.00,inplace=True)

def anna():
    warnings.simplefilter("ignore")
    
    try:
        global df
        global machine
        machine = 'anna'
        df = pd.read_excel(file_directory, header=7, sheet_name='Results')
        print('\nFile detected for ANNA 👧🏼')
  
    except FileNotFoundError:
        print('File input error, please try again')
        exit()

    df.rename(columns = {'Sample Name':'Sample ID','Target Name':'Gene','Cт':'Ct'},inplace = True)
    df['Gene'].replace({'E': 'E ', 'RdRp': 'RDRP'},inplace = True)
    df['Ct'].replace(['Undetermined'],0.00,inplace=True)



def determine_EC():
    batch_df = df[(df['Sample ID'].str.endswith('A')==False) & (df['Sample ID'].str.contains('NTC')==False) & (df['Sample ID'].str.contains('POS')==False)]['Sample ID'].str[:-3]
    batch_list = sorted(list(set(batch_df)))
    print('Batch: ' + str(batch_list))

    global eclist
    eclist = []

    for i in range(len(batch_list)):
        defineEC = sorted(list(set(df[df['Sample ID'].str.startswith(batch_list[i],na=False)]['Sample ID'])))
        extractioncontrol = defineEC[-1]
        eclist.append(extractioncontrol)
        i += 1


    # exclude blank rows, NTCs, and extraction controls
def sample_analysis():

    filtered_df = df[(df['Sample ID'].str.contains('NTC')==False) & (df['Sample ID'].str.contains('POS')==False) & (df['Sample ID'].isin(eclist)==False)]


    # pivot the DataFrame (E, RDRP, and RNAse P became the columns)


    df1 = filtered_df[['Sample ID','Gene','Ct']]
    df1piv = df1.pivot(index = 'Sample ID', columns = 'Gene', values = 'Ct')

    # check pivot table (to excel file)
    #df1piv.to_excel('pivot_table_check.xlsx',index=True,header=True)



    # exclude rows when the Ct value of both E and RDRP equals to 0
    # retains rows when RNAse P is higher than 35 and retains rows from repeated extraction

 
    try:
        global df2
        df2 = df1piv[((df1piv['E '] != 0)|(df1piv['RDRP'] != 0))|(df1piv['RNAse P'] > 35)|(df1piv['RNAse P'] == 0)|df1piv.index.str.endswith('A')][['E ','RDRP','RNAse P']]
    except KeyError:            # RNAse P not found
        print('RNAse P is probably not exported, please export all target genes and retry!')
        exit()
    
    # describe PCR result into a new column 'POS/NEG'

    conditionsPN = [
        # invalid

        ((df2['RNAse P'] == 0)),  # no Ct value for RNAse P, invalid

        # negative

        ((df2['E '] == 0) & (df2['RDRP'] == 0)),  # E and RDRP = 0, negative

        ((df2['E '] > 38) & (df2['RDRP'] > 38)),  # E and RDRP both more than 38, negative

        ((df2['E '] == 0) & (df2['RDRP'] > 38)),  # E = 0 and RDRP more than 38, negative

        ((df2['E '] > 38) & (df2['RDRP'] == 0)),  # E more than 38 and RDRP = 0, negative

        # inconclusive

        ((df2['E '] < 38) & (df2['RDRP'] > 38)),  # E less than 38, RDRP more than 38, inconclusive          

        #((df2['E '] > 38) & (df2['RDRP'] < 38)),  # E more than 38, RDRP less than 38, inconclusive         -> Positive

        #((df2['E '] == 0) & (df2['RDRP'] < 38)),  # E = 0, RDRP less than 38, inconclusive                  -> Positive

        ((df2['E '] < 38) & (df2['RDRP'] == 0)),  # E less than 38, RDRP = 0, inconclusive

        # positive

        ((df2['E '] > 38) & (df2['RDRP'] < 38)),  # E more than 38, RDRP less than 38, positive

        ((df2['E '] == 0) & (df2['RDRP'] < 38)),  # E = 0, RDRP less than 38, positive

        ((df2['E '] < 38) & (df2['RDRP'] < 38))  # E dan RDRP both less than 38, positive
    ]

    valuesPN = ['Invalid', 'Negative', 'Negative', 'Negative', 'Negative', 'Inconclusive', 'Inconclusive', 'Positive',
                'Positive', 'Positive']
    df2['POS/NEG'] = np.select(conditionsPN, valuesPN)

    # describe HRP status into a new column 'Aman?'

    conditionsHRP = [
        ((df2['RNAse P'] == 0)),  # no Ct value for HRP, 'Gk naik'

        ((df2['RNAse P'] > 35)),  # High HRP Ct: 'Di atas 35'

        ((df2['RNAse P'] <= 35))  # Normal HRP, blank
    ]

    valuesHRP = ['Gk naik', 'Di atas 35', '']
    df2['Aman?'] = np.select(conditionsHRP, valuesHRP)

    # moving 'RNAse P' column to the rightmost for easier copy-pasting
    df2 = df2[['E ', 'RDRP', 'POS/NEG', 'Aman?', 'RNAse P']]




def negative_control(princess):

    # new DataFrame for EC and NTC

    if princess == 'elsa':

        dfcekNTC = df[df['Sample ID'].str.contains('NTC')][['Sample ID','Gene','Ct']]

        try:
            dfcekNTCpiv = dfcekNTC.pivot(index = 'Sample ID',columns = 'Gene',values = 'Ct')

        except ValueError:          # omit EC and NTC analysis in case there is any pivoting error
            print('\n!!! POS AND NTC PROBABLY ARE NOT NAMED PROPERLY !!!\n!!! PLEASE MANUALLY CHECK THE POSITIVE, EXTRACTION, AND PCR CONTROLS !!!\n')
            global dfOutput
            dfOutput = df2
            print('PCR SUMMARY:')
            print(dfOutput)
            return
    elif princess == 'anna':

        # NTC only table
        dfcekNTC = df[df['Sample ID'].str.contains('NTC')][['Well', 'Gene', 'Ct']]
        # pivoted NTC table
        dfcekNTCpiv = dfcekNTC.pivot(index='Well', columns='Gene', values='Ct')

        # add Sample ID back to the table

        # count the number of NTC
        totalNTC = dfcekNTCpiv.count().at['E ']
        # make a list based on the number of NTC
        nameNTC = []
        for i in range(totalNTC):
            nameNTC.append('NTC0' + str(i + 1))
            i + 1
        # insert the sample ID to the DataFrame
        dfcekNTCpiv.insert(0, 'Sample ID', nameNTC)
        # reassign Sample ID as the index
        dfcekNTCpiv = dfcekNTCpiv[['Sample ID', 'E ', 'RDRP', 'RNAse P']].set_index('Sample ID')

    global eclist
    dfcekEC = df[df['Sample ID'].isin(eclist)]
    dfcekECpiv = dfcekEC.pivot(index = 'Sample ID',columns = 'Gene',values = 'Ct')


    # make column: 'Aman?' --> 'Naik' if HRP, E, and RDRP not equal to 0
    #                      --> 'Aman' if all equal to 0

    dfcekNTCpiv['Aman?'] = np.where((dfcekNTCpiv['RNAse P'] == 0) & (dfcekNTCpiv['E '] == 0) & (dfcekNTCpiv['RDRP'] == 0),'Aman','Naik')
    dfcekECpiv['Aman?'] = np.where((dfcekECpiv['RNAse P'] == 0) & (dfcekECpiv['E '] == 0) & (dfcekECpiv['RDRP'] == 0),'Aman','Naik')


    # new combined DataFrame

    dfcek = pd.concat([dfcekECpiv,dfcekNTCpiv])
    print('\nEC & NTC status:')
    print(dfcek)


    # filter only for those where the status is Naik

    global dfNaik
    dfNaik = dfcek[dfcek['Aman?']=='Naik']

    
def positive_control():

    # make a new pivot DataFrame (column Sample Id, E, RDRP, RNAse P) for positive control rows

    dfPos = df[df['Sample ID'].str.contains('POS',na=False)][['Well', 'Gene', 'Ct']].sort_index()

    try:
        dfPosPivot = dfPos.pivot(index='Well', columns='Gene', values='Ct')

        # make a new DataFrame for the mean of the Ct value of each gene in the positive control
        global dfPosMean
        dfPosMean = pd.DataFrame({'E ': dfPosPivot[['E ']].mean().at['E '],
                                  'RDRP': dfPosPivot[['RDRP']].mean().at['RDRP'],
                                  'RNAse P': dfPosPivot[['RNAse P']].mean().at['RNAse P']

                                  }, index=['Positive Control'])

    except ValueError:
        # if ValueError, probably positive control is not named properly
        # taking only 1 positive control instead of the mean

        print(
            '\n!!! POSITIVE CONTROL PROBABLY IS NOT NAMED PROPERLY!!!\nFIRST POSITIVE CONTROL Ct IS TAKEN INSTEAD OF THE MEAN. PLEASE CHECK THE POSITIVE CONTROL AGAIN\n')

        dfPosMean = pd.DataFrame({'E ': dfPos.head(3).loc[dfPos['Gene'] == 'E ', 'Ct'].values[0],
                                  'RDRP': dfPos.head(3).loc[dfPos['Gene'] == 'RDRP', 'Ct'].values[0],
                                  'RNAse P': dfPos.head(3).loc[dfPos['Gene'] == 'RNAse P', 'Ct'].values[0],
                                  }, index=['Positive Control'])


    
def pcr_summary():

    # concatenating sample tables, flagged EC/NTC, and mean of positive control
    dfOut = pd.concat([df2,dfNaik]).sort_index()
    global dfOutput
    dfOutput = pd.concat([dfOut,dfPosMean]).fillna('')
    print('\nPCR SUMMARY:')
    print(dfOutput)


def export():

    wantexport = input('\n\nWould you like to export the analysis?(y/n)')
    if wantexport == 'y':
        # filename for the output file
        outputFilename = 'SUMMARY_' + os.path.basename(os.path.splitext(file_directory)[0])

        # export dfOutput to a new excel file
        global dfOutput
        dfOutput.to_excel(outputFilename + '.xlsx',
                          index=True, header=True)
        print('File has been exported successfully!')
        return False
    elif wantexport == 'n':
        print('Understandable, have a nice day')
        return False
    else:
        return True

    exit()






print('\n\n\n\n~~~~~WELCOME TO I3L COVID LAB ANALYSIS~~~~~\n\n\n\n')
time.sleep(1)

print('Halo sobat PCR 👋\n')
while readMe():
    pass

while detect_machine():
    pass

determine_EC()

sample_analysis()

negative_control(machine)

positive_control()

pcr_summary()

while export():
    pass
