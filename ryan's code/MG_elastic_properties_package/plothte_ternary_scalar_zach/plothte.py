"""
(c) Kamal Choudhary
NIST
"""
#Import some packages
import glob,json 
from pymatgen.core.periodic_table import Element
from pymatgen.core.composition import Composition
import matplotlib.pyplot as plt
import matplotlib.tri as tri
plt.switch_backend('agg')
import numpy as np
from ternarpy import *
import pandas as pd
import matplotlib.cm as cm
from mpl_toolkits.axes_grid1 import make_axes_locatable
from sklearn.metrics import mean_absolute_error,r2_score,mean_squared_error



#print len(d['library']['sample'])
def regr_scores(pred,test):
   rmse=np.sqrt(mean_squared_error(test, pred))
   r2=r2_score(test, pred)
   mae=(mean_absolute_error(test, pred))
   info={}
   info['mae']=mae
   info['rmse']=rmse
   info['r2']=r2
   return info


def give_composition(arr=[]):
  comp=''
  for i in arr:
    if 'quantity' in i:
      comp=comp+str(i['chemical-formula'])+str(i['quantity'])
  comp=Composition(comp)
  return comp

def get_property(arr=[],prop='band gap'):
   val='na' #not available
   for i in arr:
     if i['name']==prop:
       if 'value' in i:
         val=i['value']
   return val

def giv_plot(js=''):
 f=open(js,'r')
 d=json.load(f)
 f.close()
 fnm=js.split('json')[0]+str('png')
 test_data=[]
 for i in d['library']['sample']:
   id=i['identifier']
   grid_x=i['coordinates']['x']['value']
   grid_y=i['coordinates']['y']['value']
   band_gap=get_property(i['property'],prop='band gap')
   sheet_resistance=get_property(i['property'],prop='sheet resistance')
   cond=get_property(i['property'],prop='conductivity')
   thick=get_property(i['property'],prop='film thickness')
   comp=give_composition(i['composition']['constituent'])
   print 'grid_x grid_y',grid_x,grid_y
   print 'band_gap',band_gap
   print 'sheet_resistance',sheet_resistance
   print 'cond',cond
   print 'thick',thick
   ti=comp.get_atomic_fraction(Element('Ti'))
   zn=comp.get_atomic_fraction(Element('Zn'))
   sn=comp.get_atomic_fraction(Element('Sn'))
   arr=[ti,zn,sn,band_gap]
   test_data.append(arr)
 df=pd.DataFrame(np.array(test_data),columns=['Ti','Zn','Sn','val'])
 print df
 X = df[["Ti","Zn","Sn"]].as_matrix()
 #X = df[["Sn","Ti","Zn"]].as_matrix()

 basis = make_basis()
 Xt = transform(X,basis)
 v = [0,0.5,1.5,2.5,3.5,4.0] #np.linspace(2, 4.0, 10, endpoint=True)
 fig, ax = plt.subplots(figsize=(10,10))
 setup_plot(ax, side_labels=["Ti","Zn","Sn"], grid_values=np.arange(0.1,1,.1))
 #setup_plot(ax, side_labels=["Sn","Ti","Zn"], grid_values=np.arange(0.1,1,.1))
 points = ax.scatter(Xt[:,0],Xt[:,1],c=df['val'],cmap=cm.jet);
 divider = make_axes_locatable(ax)
 cax = divider.append_axes("right", size="5%", pad=0.05)
 plt.colorbar(points,cax=cax).ax.set_title('bandgap (eV)')
 #plt.colorbar(points,cax=cax,ticks=v).ax.set_title('bandgap (eV)')
 plt.savefig(fnm)
 plt.close()

def line_plot(libs=[]):
 js1=libs[0] 
 js2=libs[1] 
 f1=open(js1,'r')
 d1=json.load(f1)
 f1.close()

 f2=open(js2,'r')
 d2=json.load(f2)
 f2.close()

 fnm=str('line-')+str(js1)+str(js2)+str('.png')
 test_data1=[]
 test_data2=[]
 for i in d1['library']['sample']:
   id=i['identifier']
   grid_x1=i['coordinates']['x']['value']
   grid_y1=i['coordinates']['y']['value']
   band_gap1=get_property(i['property'],prop='band gap')

   for j in d2['library']['sample']:
     id=j['identifier']
     grid_x2=j['coordinates']['x']['value']
     grid_y2=j['coordinates']['y']['value']
     if grid_x1==grid_x2 and grid_y1==grid_y2:
       band_gap2=get_property(j['property'],prop='band gap')
       test_data2.append(band_gap2)
       test_data1.append(band_gap1)
       print grid_x1,grid_y1,grid_x2,grid_y2,band_gap1,band_gap2
       break
 accur= regr_scores(test_data1,test_data2)
 print accur
 mad=str('MAD: ')+str(round(accur['mae'],2))
 plt.plot(test_data1,test_data2,'*')
 plt.text(3,3,mad)
 plt.plot(test_data1,test_data1)
 plt.xlabel('NIST')
 plt.ylabel('NREL')
 plt.xlim([2,4])
 plt.ylim([2,4])
 plt.savefig(fnm)
 plt.close()



#MAIN

line_plot(['lib.2015.f8bd1613.json','lib.2015.905a015c.json'])
#line_plot(['lib.2016.188ba2d2.json','lib.2016.af8adec9.json'])
#line_plot(['lib.2016.5d631f5b.json','lib.2016.d27e2aee.json'])
#line_plot(['lib.2016.c2665929.json','lib.2016.810a5ccc.json'])

"""
for i in glob.glob("*.json"):
 giv_plot(i)

"""

