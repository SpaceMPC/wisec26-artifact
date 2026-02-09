Readme for reproducibility submission of paper ID 45

A) Source code info
Repository: https://gitfront.io/r/c1234/opZTeh23ij6F/wisec26-artifact/
List of Programming Languages: Python/Bash
Compiler Info: Python
Packages/Libraries Needed: matplotlib, numpy, pandas, docker

B) Datasets info
Repository: final_data/ (Included in the VM and github repository)
Data generators: docker

C) Hardware Info
[Here you should include any details and comments about the hardware used, in order to be able to accommodate the reproducibility effort. Any information about non-standard hardware should also be included. You should also include at least the following info:]
C1) Processor (architecture, type, and number of processors/sockets)
C2) Caches (number of levels, and size of each level)
C3) Memory (size and speed)
C4) Secondary Storage (type: SSD/HDD/other, size, performance: random read/sequential read/random write/sequential write)
C5) Network (if applicable: type and bandwidth)
C6) GPU: N/A
C7) SDR: N/A
C8) Profiling Boards: 3 Jetson Nano Developer Kits

D) Experimentation Info
D1) VM Credentials [Usernames, Passwords)
D2) Scripts to recreate graphs
bash create_figs.sh
D3) Scripts and how-tos to prepare the software for system
bash prepareSoftware.sh
D4) Scripts and how-tos to run experiments in the paper
bash runExperiments.sh

E) Software License [Encouraged but optional]

F) Additional Information
We have included in the VM final data from our experiments as well as scripts to generate the graphs found in the paper. We additionally include a docker-ized version of our code and testing environment to generate new data. This, however, will give different results from our experiments given the hardware our tests were executed on. 

Addtionally, docker must be installed and must not be running rootless.
