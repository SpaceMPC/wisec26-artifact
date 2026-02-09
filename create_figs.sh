#!/usr/bin/env bash

cd fig_1/ && python3 make_fig.py
echo "Figure 1 in fig_1/"
cd ../fig_2/ && python3 make_fig.py
echo "Figure 2 in fig_2/"
cd ../fig_3/ && python3 make_fig.py
echo "Figure 3 in fig_3/"
