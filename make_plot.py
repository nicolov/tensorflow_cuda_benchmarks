#!/usr/bin/env python

from __future__ import print_function

import glob
import os

from matplotlib import pyplot as plt
from IPython import embed
import pandas as pd
import seaborn as sns

def main():
    log_files = glob.glob('output/*.txt')
    data = []
    for lf in sorted(log_files):
        compiler = os.path.basename(lf).split('-')[0]
        num_gpus = os.path.basename(lf).split('-')[1][0]

        with open(lf) as f:
            lines = f.readlines()

        images_sec = float(lines[-2].split()[-1])
        data.append({
            'Compiler': compiler,
            'GPUs': num_gpus + ' GPU' + ('s' if int(num_gpus) > 1 else ''),
            'Images_sec': images_sec,
        })

    df = pd.DataFrame.from_records(data)
    # Get columns like 'clang', 'nvcc'
    df = df.set_index(['GPUs', 'Compiler']).unstack()

    sns.set()
    f, ax = plt.subplots(figsize=(5, 3.5))
    df.plot(ax=ax, kind='bar', rot=0, width=0.4)
    ax.set_title('CNN training, nvcc vs clang')
    ax.set_xlabel('')
    ax.set_ylabel('Images/sec')
    ax.legend(df.columns.levels[1], loc='upper left')

    plt.tight_layout()
    f.savefig('plot.png', bbox_inches='tight')


if __name__ == '__main__':
    main()
