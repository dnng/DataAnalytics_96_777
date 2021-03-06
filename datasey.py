from matplotlib import pylab as plt
import numpy as np
from itertools import cycle, islice
import pandas as pd
import sys

def read_dataset(f):
    return pd.read_csv(f, dtype=str)


def main():
    try:
        f = sys.argv[1]
    except:
        print "Usage:"
        print "   python dataset.py dataset.csv"

    if f != "SBI.csv":
        print "Only one dataset is allowed for this script: SBI.csv"
        print "Please refer to the Google Drive folder and get the proper dataset"
        return -1 

    amount_and_account = {}
    mobile_and_account = {}

    sbi = read_dataset(f)

    # Iterate through the sbi object and create dict of account:total_amount_transfered
    for i in range(len(sbi)):
        idx = sbi.loc[i, 'SBI_Account']
        if idx in amount_and_account:
            amount_and_account[idx] += float(sbi.loc[i, 'Amount'])
        else:
            amount_and_account[idx] = float(sbi.loc[i, 'Amount'])
    
    # Iterate through the sbi object and create dict of account:list_of_mobile_numbers
    for i in range(len(sbi)):
        idx = sbi.loc[i, 'SBI_Account']
        if idx in mobile_and_account:
            mobile_and_account[idx] += [sbi.loc[i, 'Depositor_Mobile']]
        else:
            mobile_and_account[idx] = [sbi.loc[i, 'Depositor_Mobile']]
    
    return amount_and_account, mobile_and_account


amount_and_account, mobile_and_account = main()
top20_amoacc = []
top20_mobacc = []

# Get top 20 amounts transfered and their respective accounts
for i in amount_and_account.iteritems():
    if len(top20_amoacc) < 20:
        top20_amoacc.append([i[1], i[0]])
    else:
        if i[1] > min(top20_amoacc)[0]:
            top20_amoacc[top20_amoacc.index(min(top20_amoacc))] = [i[1], i[0]]


# From the top20 accounts in the previous step, get their list of mobiles
for j in range(len(top20_amoacc)):
    top20_mobacc.append([mobile_and_account[top20_amoacc[j][1]], top20_amoacc[j][0]])

# print top20_amoacc
# print top20_mobacc

accs = []
tots = []

for i in range(len(top20_mobacc)):
    accs.append(str(top20_mobacc[i][1]))
    tots.append(len(top20_mobacc[i][0]))
    print top20_mobacc[i][1], len(top20_mobacc[i][0])


my_colors = [(x/128.0, x/148.0, 0.25) for x in range(len(accs))]

x_pos = np.arange(len(accs))

plt.bar(x_pos, tots, color=my_colors)
plt.xlim([0, x_pos.size])
plt.suptitle('Top 20 Accounts with most associated mobile Numbers per Total Transfered Amount', fontsize=14)
plt.xticks(x_pos, tots, rotation=45)
plt.ylabel('Total Amount', fontsize=12)
plt.xlabel('Account', fontsize=12) 
plt.show()
