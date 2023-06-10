import glob 
import os
import matplotlib.pyplot as plt
import matplotlib.pylab as pylab
from scipy.io import loadmat

totals = glob.glob("save/*.*")

names = [os.path.splitext(os.path.basename(total))[0]  for total in totals]

dataset = [name.split('_')[0] for name in names]
dataset = set(dataset)
dataset_dict = {}

for n in dataset:
    dataset_dict[n] = []
print(dataset_dict)
for total in totals:
    name = os.path.splitext(os.path.basename(total))[0]
    dataset = name.split('_')[0]
    dataset_dict[dataset].append(total)

sorted(dataset_dict.keys())
                             
myparams = {
# Set x axis
'xtick.direction' : 'in',
'xtick.major.size' : '3',
'xtick.major.width' : '0.5',
'xtick.minor.size' : '1.5',
'xtick.minor.width' : '0.5',
'xtick.minor.visible' : 'True',
'xtick.top' : 'True',
'ytick.direction' : 'in',
'ytick.major.size' : '3',
'ytick.major.width' : '0.5',
'ytick.minor.size' : '1.5',
'ytick.minor.width' : '0.5',
'ytick.minor.visible' : 'True',
'ytick.right' : 'True',
'axes.linewidth' : '0.5',
'grid.linewidth' : '0.5',
'lines.linewidth' : '1.',
'lines.markersize': '3',
'legend.frameon' : 'False',
'savefig.bbox' : 'tight',
'savefig.pad_inches' : '0.05',
'font.family' : 'Times New Roman',
'mathtext.fontset' : 'dejavusans',
'axes.labelsize': '7',
'xtick.labelsize': '7',
'ytick.labelsize': '7',
'legend.fontsize': '7',
'font.size': '7'
}


pylab.rcParams.update(myparams)


for dataset in dataset_dict.keys():
    style = ['r','g','b','c','m','y','k','b--','r--','c--','m--','y--','k--','g:d','b--<','c--*','m:x','g--+','k:*','y-->','r--s','go--','b--p','c:d','m--*','r:d','k--^','r:.']
    style.reverse()
    plt.figure(figsize=(5, 6))
    data_info = []
    for i, total in enumerate(dataset_dict[dataset]):
        fun = os.path.splitext(os.path.basename(total))[0].split('_')[1]
        data = loadmat(total)
        auc = data['auc'].tolist()[0][0]
        fpr = data['fpr'].tolist()[0]
        tpr = data['tpr'].tolist()[0]
        auc = round(auc, 3)
        data_info.append((fun, auc, fpr, tpr, style[i]))
    data_info.sort(key=lambda x: x[1], reverse=True)
    
    for fun, auc, fpr, tpr, ty in data_info:
        plt.plot(fpr, tpr, ty, label=fun+f' [{str(auc)}]')
    plt.grid(linestyle='-.')
    plt.legend()
    plt.xlabel('False Positive Rate')
    plt.ylabel('True Positive Rate')
    plt.savefig(f"results/{dataset}_roc.png", dpi=500)
    plt.close()  