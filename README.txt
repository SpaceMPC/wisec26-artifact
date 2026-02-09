
Readme for reproducibility submission of paper ID 45

A) Source code info
Repository: https://gitfront.io/r/c1234/opZTeh23ij6F/wisec26-artifact/
Link to VM: https://www.dropbox.com/scl/fi/t4dakfrf5h09amqjxthxe/MP-SPDZ_WiSEC_artifacts.ova?rlkey=3wj35tobltvc0cu2k0jhxwgjy&st=1c4dn90l&dl=0
List of Programming Languages: Python/Bash
Compiler Info: Python
Packages/Libraries Needed: matplotlib, numpy, pandas, docker

B) Datasets info
Repository: final_data/ (Included in the VM and github repository)
Data generators: docker

C) Hardware Info
C1) Processor: Intel Core Ultra 7 155H × 22; 4 cores
C2) Caches: L1 112 KB per core; L2 12 MB per core; L3 24 MB shared 
C3) Memory: 4 GB
C4) Secondary Storage: 30 GB 
C5) GPU: N/A
C6) SDR: N/A
C7) Profiling Boards: 3 Jetson Nano Developer Kits

D) Experimentation Info
D1) VM Credentials [Usernames, Passwords)
D2) Scripts to recreate graphs; output is written in fig_X/ directories
    bash create_figs.sh
D3) Scripts and how-tos to prepare the software for system
    bash prepareSoftware.sh
D4) Scripts and how-tos to run experiments in the paper; ouput is written to the docker/with-direct and docker/no-direct directories
    bash runExperiments.sh

E) Additional Information
We have included in the VM final data from our experiments as well as scripts to generate the graphs found in the paper. We additionally include a docker-ized version of our code and testing environment to generate new data. This, however, will give different results from our experiments given the hardware our tests were executed on. 

Docker must be installed on the system.
