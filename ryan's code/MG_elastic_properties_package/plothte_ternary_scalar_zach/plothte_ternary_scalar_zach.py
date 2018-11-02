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

path = "C:\\Users\\jrh8\\Desktop\\Python Library\\HTE-MC MDCS Code\\"
os.chdir( path )
from ternarpy import *
nist_df = pd.read_excel('C:\\Users\\jrh8\\Documents\\Documents\\Projects\\NREL-NIST MVL\\NIST MVL Data\\Round Robin Data\\Editing Figures for Paper\\NIST sample Scalar Summary as a function of composition.xlsx', header = 0)
#%%

columns = list(nist_df)


basis = make_basis()
nist_X = nist_df.iloc[:,0:3].as_matrix()
nist_Xt = transform(nist_X,basis)
#%%

fig, ax = pylab.subplots(figsize=(10,10))
setup_plot(ax, side_labels= columns[0:3], grid_values=np.arange(0.1,1,0.1))
points = ax.scatter(nist_Xt[:,0],nist_Xt[:,1],c=nist_df['cluster labels (1:6)'], cmap='Set1', vmin=1, vmax=6);
plt.colorbar(points).ax.set_title('Cluster Label')
plt.savefig("thickness-NIST-syn-NIST-meas.pdf", bbox_inches='tight')
plt.show(points)

