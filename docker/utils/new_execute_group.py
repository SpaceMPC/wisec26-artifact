import os
import subprocess
import argparse
import tqdm
from pathlib import Path

#protocols that cannot accept the -N parameter for number of parties
NO_DASH_N_PROTOCOLS = {'replicated-ring','replicated-field','brain','malicious-rep-field','malicious-rep-ring','ps-rep-field','ps-rep-ring','sy-rep-field','sy-rep-ring'}

#set up the argparser
parser = argparse.ArgumentParser()
parser.add_argument("path",help='path to the .sch program to execute')
parser.add_argument('-n','--execution-count',required=False,default=100,type=int,help='number of times to execute the program')
parser.add_argument('-N',required=False,default=2,type=int,help='Number of Players')
parser.add_argument('-M','-path-to-mp',required=False,default='~/git/MP-SPDZ/', help='the path to MP-SPDZ on the system')
parser.add_argument('-o', default='./', help='the location to output the file')
parser.add_argument('-I', default='192.168.1.2', help='the IP address to the host device (Party 0)')
parser.add_argument('-U', default='ubuntu', help='the user to login to the other systems')
parser.add_argument('-F', defualt='',help='pass any compile flags in "" quotes')
args = parser.parse_args()

################# Check to ensure all passed paths are valid ###################################

#if MP-SPDZ doesn't exits complain
if os.path.exists(os.path.expanduser(args.M)):
    #make sure the trailing slash is there
    pathToMP = os.path.join(args.M,'')
    args.M = os.path.expanduser(args.M)
else:
    raise FileNotFoundError('MP-SPDZ directory not found!')

#check the path to the program to execute is formatted correctly
if os.path.exists(os.path.join(args.M,'Programs/Source',args.path)) == False:
    #if no .mpc passed add it and check
    if os.path.exists(os.path.join(args.M,'Programs/Source',f'{args.path}.mpc')):
        pass
    else:
        #if we get here no recovering print an error
        raise FileNotFoundError(f'File {os.path.join(args.M,"Programs/Source",args.path)} does not exist.')

#check the output directory and create it if needed
output_path = os.path.join(args.o,args.path)
if os.path.exists(output_path):
    pass
else:
    print(f'Making directory: {output_path}')
    os.makedirs(output_path)

################################################################################################

################### Helper functions ###########################################################

#function that makes sure the first number seen is pulled out. Must have no leading whitespaces
def custom_strip(string) -> int:
    num_length = 0
    for char in string:
        if char.isspace():
            num_length+=1
            break
        else:
            num_length+=1
    return num_length

################################################################################################

#Which protocols do you want to test
#protocols = ['hemi']
#protocols = ['mascot','spdz2k']
#protocols = ['semi','mascot','mama','soho','temi','hemi','chaigear','cowgear']
#protocols = ['cowgear','mama','soho','temi','hemi','chaigear','semi']
#protocols = ['semi2k']
#protocols = ['atlas','shamir']
## APF semi-honest
#protocols = ['hemi','semi','semi2k','soho','temi']
## APF malicious
protocols = ['mascot','mama','spdz2k']
## QP dishonest majority, SH
#protocols = ['hemi','semi','soho','temi']
## QP dishonest majority, malicious
#protocols = ['mama','mascot','spdz2k']
## QP honest majority, sh
#protocols = ['atlas','replicated-field','replicated-ring','shamir']
## QP honest majority, mal
#protocols = ['brain','malicious-rep-field','malicious-rep-ring','ps-rep-field','ps-rep-ring','sy-rep-field','sy-rep-ring']
## non ring hm, mal protocols
#protocols = ['sy-shamir','malicious-shamir']
for protocol in protocols:
    try:
        #set up lists to hold execution time, communication rounds, and amount of data passed
        execution_time_list_online = []
        execution_time_list_offline = []
        execution_time_list_CPU = []

        communication_rounds = []
        rounds_online = []
        rounds_offline = []

        data_online = []
        data_offline = []
        global_data = []

        #for each protocol execute it the apropriate number of times by calling the shell script run, which copies the program over to the other boards, compiles, and executes.
        for i in tqdm.tqdm(range(args.execution_count),desc=f'{protocol}:'):
            if protocol in NO_DASH_N_PROTOCOLS:
                #ignore the dash N flag and do not pass it, this will cause this protocol to error
                output = subprocess.getstatusoutput(f'./run -e {protocol} -p {args.path} -M {pathToMP} -I {args.I} -U {args.U} -F "{args.F}"')
            else:
                output = subprocess.getstatusoutput(f'./run -e {protocol} -N {args.N} -p {args.path} -M {pathToMP} -I {args.I} -U {args.U} -F "{args.F}"')
            try:

                ######    Online Execution Time  #################
                index = str(output[1]).find('Spent ')
                string = output[1][index+6:index+45].strip()
                #make sure no chars slip in at the end
                num_length = custom_strip(string)
                execution_time_list_online.append(float(string[0:num_length]))

                #####   Online Data Sent    ######################
                start = index+6+num_length+10
                string = output[1][start:start+30].strip()
                num_length = custom_strip(string)
                data_online.append(float(string[0:num_length]))

                #####   Online Rounds     ####################### 
                start = start+num_length+4
                string = output[1][start:start+30].strip()
                num_length = custom_strip(string)
                rounds_online.append(float(string[0:num_length]))


                ######   Offline Execution Time  ###################

                index = str(output[1]).find('the online phase and ')
                string = output[1][index+21:index+45].strip()
                #make sure no chars slip in at the end
                num_length = custom_strip(string)
                execution_time_list_offline.append(float(string[0:num_length]))

                #####   Offline Data     ####################### 
                start = index+21+num_length+9
                string = output[1][start:start+30].strip()
                num_length = custom_strip(string)
                data_offline.append(float(string[0:num_length]))

                #####   Offline Rounds     ####################### 
                start = start+num_length+4
                string = output[1][start:start+30].strip()
                num_length = custom_strip(string)
                rounds_offline.append(float(string[0:num_length]))

                ######    CPU Time   #######################

                index = str(output[1]).find('CPU time = ')
                string = output[1][index+11:index+30].strip()
                #make sure no chars slip in at the end
                num_length = custom_strip(string)
                execution_time_list_CPU.append(float(string[0:num_length]))

                ######    Total Rounds   #######################

                index = str(output[1]).find('in ~')
                string = output[1][index+4:index+30].strip()
                #make sure no chars slip in at the end
                num_length = custom_strip(string)
                communication_rounds.append(float(string[0:num_length]))

                ######    Global Data Sent   #######################

                index = str(output[1]).find('Global data sent =')
                string = output[1][index+18:index+30].strip()
                #make sure no chars slip in at the end
                num_length = custom_strip(string)
                global_data.append(float(string[0:num_length]))

            except ValueError as e:
                print(e)
                print(f'({output[0]}, {output[1]})')
    except KeyboardInterrupt:
        ## pass to allow for neat cleanup
        pass

    with open(os.path.join(output_path,f'{protocol}_time.csv'),'w') as file:
        file.write('online, offline, cpu \n')
        for i in range(len(execution_time_list_CPU)):
            file.write(f'{execution_time_list_online[i]}, {execution_time_list_offline[i]}, {execution_time_list_CPU[i]}  \n')


    with open(os.path.join(output_path,f'{protocol}_rounds.csv'),'w') as file:
        file.write('online, offline, total \n')
        for i in range(len(communication_rounds)):
            file.write(f'{rounds_online[i]}, {rounds_offline[i]}, {communication_rounds[i]} \n')


    with open(os.path.join(output_path,f'{protocol}_data.csv'),'w') as file:
        file.write('online, offline, global \n')
        for i in range(len(global_data)):
            file.write(f'{data_online[i]}, {data_offline[i]}, {global_data[i]} \n')
