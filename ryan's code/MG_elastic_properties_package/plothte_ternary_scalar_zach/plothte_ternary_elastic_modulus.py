# -*- coding: utf-8 -*-
"""
Created on Wed May 30 09:00:38 2018

@author: jrh8
"""
#%%
import requests
requests.packages.urllib3.disable_warnings()
import json
from collections import OrderedDict
import matplotlib
import matplotlib.pyplot as plt
import os
import pandas as pd
import pprint
import numpy

path = "C:\\Users\\rws6\\Machine learning\\Elastic_modulus_magpie\\plothte_ternary_scalar_zach\\"
os.chdir( path )
from ternarpy import *
nist_df = pd.read_csv('C:\\Users\\rws6\\Machine learning\\Elastic_modulus_magpie\\ref_elastic_modulus_NiTiAl.csv', header = 0)
#%%

columns = list(nist_df)


basis = make_basis()
nist_X = nist_df.iloc[:,0:3].as_matrix()
nist_Xt = transform(nist_X,basis)
#%%

fig, ax = pylab.subplots(figsize=(10,10))
setup_plot(ax, side_labels= columns[0:3], grid_values=np.arange(0.1,1,0.1))
points = ax.scatter(nist_Xt[:,0],nist_Xt[:,1],c=nist_df['elastic_modulus'], cmap='magma', vmin=nist_df['elastic_modulus'].min(), vmax=nist_df['elastic_modulus'].max());
plt.colorbar(points).ax.set_title('Elastic Modulus')
os.chdir("C:\\Users\\rws6\\Machine learning\\Elastic_modulus_magpie\\")
plt.savefig("elastic_modulus_NiTiAl.pdf", bbox_inches='tight')
plt.show(points)

