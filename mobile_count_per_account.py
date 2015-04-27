from matplotlib import pylab as plt
import numpy as np
from itertools import cycle, islice

count = {"1": 241820,
         "2": 62168,
         "3": 19679,
         "4": 7851,
         "5": 3978,
         "6": 1813,
         "7": 1030,
         "8": 658,
         "9": 394,
         "10": 385,
         "11": 179,
         "12": 142,
         "13": 115,
         "14": 82,
         "15": 83,
         "16": 40,
         "17": 38,
         "18": 38,
         "19": 23,
         "20": 38,
         "21": 18,
         "22": 12,
         "23": 9,
         "24": 6,
         "25": 12,
         "26": 7,
         "27": 6,
         "28": 6,
         "29": 6,
         "30": 4,
         "31": 3,
         "32": 3,
         "33": 1,
         "34": 2,
         "35": 7,
         "36": 5,
         "37": 1,
         "38": 1,
         "39": 1,
         "40": 5,
         "42": 3,
         "43": 4,
         "44": 1,
         "45": 1,
         "50": 2,
         "51": 1,
         "53": 1,
         "54": 1,
         "55": 3,
         "68": 1,
         "69": 1,
         "70": 1,
         "75": 1,
         "80": 1,
         "84": 1,
         "87": 1,
         "90": 1,
         "98": 1,
         "105": 1,
         "114": 1,
         "162": 1}

total = 340698

mob, acc = [], [] 

for i in sorted(count, key=count.get):
    mob.append(int(i))
    acc.append(str(count[i]))


for j in range(len(acc)):
    if acc[j] == "1":
        acc[j] = "Unique"
    else:
        acc[j] = acc[j] + " Accs"
            

# my_colors =  list(islice(cycle(['b', 'g', 'c', 'm']), None, len(acc)))
# my_colors =  list(islice(cycle(['b', 'r', 'g', 'r', 'c', 'y', 'm']), None, len(acc)))
my_colors = [(x/64.0, x/74.0, 0.75) for x in range(len(acc))]

x_pos = np.arange(len(acc))


plt.bar(x_pos, mob, color=my_colors)
plt.xlim([0, x_pos.size])
plt.suptitle('Depositor Mobiles per Range of Accounts', fontsize=14)
plt.xticks(x_pos, acc, rotation=45)
plt.ylabel('Number of Mobile Phones Used', fontsize=12)
plt.xlabel('Range of Accounts', fontsize=12) 
plt.show()
