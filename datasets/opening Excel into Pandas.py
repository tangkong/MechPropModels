# -*- coding: utf-8 -*-
"""
Created on Mon Jul 16 10:52:50 2018
This is just meant to be easy code to grab and open Excel datafiles
the second part is used to compare two different workbooks and generate
a list of literal overlaps.

The bottom part was used to clean up the excel worksheet. The ensuing
workbook is ALMOST usable by Magpie.

@author: jrh8
"""

import math
import pandas as pd
import os
import numpy as np

path = "C:\\Users\\jrh8\\Documents\\Documents\\Projects\\Metallic Glasses\\SLAC-CSM-NREL-NIST project\\Elastic Properties\\"
os.chdir( path )
SLAC_Elastic = pd.read_excel('SLAC Mechnical properties v23.5.xlsx', header = 0)

NIST_Elastic = pd.read_excel('elastic_modulus_data.xlsx', header = 0)
#%%
Iter = len(NIST_Elastic) -1
columns = list(range(0,Iter))
index = list(range(0,len(SLAC_Elastic)))
logic = pd.DataFrame(index = index, columns = columns)
#%%
CompsNIST = NIST_Elastic['Composition']

CompsSLAC = SLAC_Elastic['Compositions']

CNIST = set(CompsNIST)
CSLAC = set(CompsSLAC)

DIFF = CNIST.difference(CSLAC)
AsList = list(DIFF)
DIFF2 = CSLAC.difference(CNIST)
AsList2 = list(DIFF2)
#%%
'''
There are only about 19 entries in Ryan's data set that may be distinct
from Suchi's. (They were not), but rather were due to spacing problems
I will now filter Suchi's to focus on data that only have
elastic modulus.

first we remove the blanks and not numbers
'''
#%%
SLAC_Elastic['Youngs_Modulus_Gpa'].replace('', np.nan, inplace=True)
SLAC_Elastic.dropna(subset =['Youngs_Modulus_Gpa'], inplace = True)
SLAC_Elastic.Youngs_Modulus_Gpa.astype(float)

'''
now to address the extra spaces problem in the compositions
A problem is that there is a special byte codec that ASCII
This is something of a stopping point right now, I will instead focus on
cleaning out the "normal" text

I could have done this a couple of more Pythonic ways but this seems to get the
job done


'''
#%%
SLAC_Elastic['Compositions'].to_string()

SLAC_Elastic_wo_words = SLAC_Elastic.loc[SLAC_Elastic['Compositions'].str.contains("lass")!=True]
SLAC_Elastic_wo_words = SLAC_Elastic_wo_words[SLAC_Elastic_wo_words['Compositions'].str.contains("used")!=True]
SLAC_Elastic_wo_words = SLAC_Elastic_wo_words[SLAC_Elastic_wo_words['Compositions'].str.contains("=")!=True]
SLAC_Elastic_wo_words = SLAC_Elastic_wo_words[SLAC_Elastic_wo_words['Compositions'].str.contains("mor.")!=True]
SLAC_Elastic_wo_words = SLAC_Elastic_wo_words[SLAC_Elastic_wo_words['Compositions'].str.contains("Vit1")!=True]
SLAC_Elastic_wo_words = SLAC_Elastic_wo_words[SLAC_Elastic_wo_words['Compositions'].str.contains("nnealed")!=True]
SLAC_Elastic_wo_words = SLAC_Elastic_wo_words[SLAC_Elastic_wo_words['Compositions'].str.contains("-")!=True]
SLAC_Elastic_wo_words = SLAC_Elastic_wo_words[SLAC_Elastic_wo_words['Compositions'].str.contains("L SS")!=True]
SLAC_Elastic_wo_words = SLAC_Elastic_wo_words[SLAC_Elastic_wo_words['Compositions'].str.contains("bone")!=True]

'''
Save the data as a CSV
'''
SLAC_Elastic_wo_words.to_excel("SLAC_Elastic_Cleaned.xlsx")


#%%

