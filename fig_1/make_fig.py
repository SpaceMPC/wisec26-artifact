import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from statistics import mean
import numpy as np
import pandas as pd

text_size = 22
color_hatch1 = ('tab:blue','')
color_hatch2 = ('tab:red', '')

def replace_rep_mal(label:str) -> str:
    '''Takes a label and replaces "replicated" with rep, and "malicious" with mal. If not there returns just a copy of the original'''
    label = label.replace('replicated','rep')
    return label.replace('malicious','mal')

def build_graph(data_dict:dict, round_vals:int, y_label:str, protocols:dict, sec_guarantee:dict,  ax, label_type=float, text_size_over_labels=0, xlabel_size=0, standard_deviation=None):
    #order everything nicely -- Data
    semi_honest_data = []
    semi_honest_label = []
    semi_honest_sd = []
    mal_data = []
    mal_labels = []
    mal_sd = []
    for protocol in protocols:
        if sec_guarantee[protocol]==0:
            #means we are semi-honest
            semi_honest_data.append(data_dict[protocol])
            semi_honest_label.append(protocol.replace('-','\n'))
            if standard_deviation is not None:
                semi_honest_sd.append(standard_deviation[protocol])
        else:
            mal_data.append(data_dict[protocol])
            mal_labels.append(protocol.replace('-','\n'))
            if standard_deviation is not None:
                mal_sd.append(standard_deviation[protocol])

    # Make the plot
    height = semi_honest_data + mal_data
    labels = [replace_rep_mal(x) for x in (semi_honest_label + mal_labels)]
    barlist = ax.bar(labels, height);
    if standard_deviation is not None:
        ax.errorbar(labels, height, yerr=semi_honest_sd+mal_sd, linestyle='none', solid_capstyle='projecting', capsize=5, color='black', elinewidth=3)
    for i in range(len(semi_honest_data)):
        barlist[i].set_color(color_hatch1[0])
        barlist[i].set_edgecolor("black")
        barlist[i].set_hatch(color_hatch1[1])
    for i in range(len(semi_honest_data),len(labels)):
        barlist[i].set_color(color_hatch2[0])
        barlist[i].set_edgecolor("black")
        barlist[i].set_hatch(color_hatch2[1])

    ax.set_ylabel(y_label,fontsize=text_size+12)
    ax.set_xticks(ax.get_xticks(),labels=labels, fontsize=text_size+xlabel_size)
    if label_type == float:
        ax.set_yticks(ax.get_yticks(),labels=np.round(ax.get_yticks(),2),fontsize=text_size)
    elif label_type == int:
        ax.set_yticks(ax.get_yticks(),labels=[int(x) for x in np.round(ax.get_yticks(),0)],fontsize=text_size)
    ax.set_ylim(0,ax.get_ylim()[1]+ax.get_ylim()[1]*0.05)

    #text over bars
    for i in range(len(labels)):
        up_shift = ax.get_ylim()[1]*0.015
        # ax.text(i,height[i]+ up_shift,round(height[i],round_vals).astype(label_type), ha='center',fontsize=text_size+1)
        if label_type == int:
            ax.text(i,height[i]+ up_shift,round(height[i],round_vals).astype(label_type), ha='center',fontsize=text_size+text_size_over_labels)
        else:
            ax.text(i,height[i]+ up_shift,f"{height[i]:.2E}", ha='center',fontsize=text_size+text_size_over_labels)


protocols = ['semi','hemi','soho','temi','mascot','spdz2k', 'semi2k']
#0=semi-honest 1=malicious
sec_guarantee = {'mascot':1,'spdz2k':1,'semi':0,'hemi':0,'temi':0,'soho':0,'semi2k':0}

time_dict_combined = {}
time_dict_std_combined = {}
for protocol in protocols:
    time_df = pd.read_csv(f'../final_data/apf-noise-direct-flag/{protocol}_time.csv')
    time_online = np.mean(np.asarray(time_df['online']))
    time_offline = np.mean(np.asarray(time_df[' offline']))
    time_dict_combined[protocol] = time_online + time_offline
    time_dict_std_combined[protocol] = np.std(np.asarray(time_df['online']) + np.asarray(time_df[' offline']))
    

data_dict_combined = {}
for protocol in protocols:
    data_df = pd.read_csv(f'../final_data/apf-noise-direct-flag/{protocol}_data.csv')
    data_online = np.mean(np.asarray(data_df['online']))
    data_offline = np.mean(np.asarray(data_df[' offline']))
    data_dict_combined[protocol] = data_online + data_offline

rounds_dict_combined = {}
for protocol in protocols:
    rounds_df = pd.read_csv(f'../final_data/apf-noise-direct-flag/{protocol}_rounds.csv')
    rounds_online = np.mean(np.asarray(rounds_df['online']))
    rounds_offline = np.mean(np.asarray(rounds_df[' offline']))
    rounds_dict_combined[protocol] = rounds_online + rounds_offline

fig, ax = plt.subplots(3, 1, figsize=(20, 12))

#####################################################################################################

#order everything nicely -- TIME
build_graph(time_dict_combined, 2, 'Total\nSeconds (s)', protocols, sec_guarantee, ax[0])

#####################################################################################################

#order everything nicely -- DATA 
build_graph(data_dict_combined, 2, 'Data Sent\nParty 0 (MB)', protocols, sec_guarantee, ax[1])

#####################################################################################################

#order everything nicely -- ROUNDS
build_graph(rounds_dict_combined, 2, 'Total\nComm. Rounds', protocols, sec_guarantee, ax[2], label_type=int)

#####################################################################################################



##legend
blue_patch = mpatches.Patch(facecolor=color_hatch1[0],edgecolor='black',hatch=color_hatch1[1], label='Semi-Honest')
red_patch = mpatches.Patch(facecolor=color_hatch2[0],edgecolor='black',hatch=color_hatch2[1], label='Malicious')
ax[2].legend(ncol=2,handles=[blue_patch, red_patch],fontsize=text_size+8,loc='lower center',bbox_to_anchor=(.5, -0.5),)
fig.tight_layout()

plt.savefig('./fig_1.pdf')
