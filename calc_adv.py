import numpy as np
import pandas as pd
from scipy.stats import norm
import statsmodels.api as sm
from statsmodels.stats.proportion import proportion_confint

from dataclasses import dataclass
from typing import List, Any
import datetime
import matplotlib as mpl
import matplotlib.dates as mdates
import matplotlib.pyplot as plt
from matplotlib.axes import Axes
from matplotlib.figure import Figure
from pathlib import Path
import json
import warnings
from tqdm import tqdm

import os
# os.chdir('~/plotting_growth_advantage')
from base_classes import *
from utils import *


seq = pd.read_csv('results/sequence_combine.csv')

def calc_adv_add(k,n):
    date_t=[i for i in range(len(k))]
    generation_time = 7 
    reproduction_number = 1
    alpha=0.95
    adv = statsmodel_fit(alpha,date_t, k, n,generation_time, reproduction_number)
    mle = adv.fd_mle
    lower_bound = adv.fd_ci.lower
    upper_bound = adv.fd_ci.upper
    return mle, lower_bound, upper_bound

df = pd.DataFrame(columns=['variant', 'variant_base', 'adv_mle','adv_low','adv_high'])
for variant1 in ['MC.10.1', 'LP.8.1', 'LP.8', 'NP.1','MV.1', 'LF.7', 'LF.7.2.1','XEC']:
    for variant2 in ['KP.3.1.1']:
        adv_mle, adv_low, adv_high = calc_adv_add(seq[variant1].tolist(), (seq[variant1]+seq[variant2]).tolist())
        new_row = pd.DataFrame({'variant':[variant1], 'variant_base':[variant2], 'adv_mle':[adv_mle],'adv_low':[adv_low],'adv_high':[adv_high]})
        df = df.append(new_row, ignore_index=True)
df.to_csv('results/adv.csv',index=False)
