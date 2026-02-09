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
parser.add_argument('-M','-path-to-mp',required=False,default='~/git/MP-SPDZ/')
parser.add_argument('-o', default='./')
parser.add_argument('-Fc', default="", help='Flags to pass to the compile step')
parser.add_argument('-Fe', default="", help='Flags to pass to the execution step')
parser.add_argument('--with-verbose-printing', type=bool, default=False)
parser.add_argument('-I', required=True, help="Host IP address")
parser.add_argument('-U', required=True, help="The user to run as")
parser.add_argument('--protocols', type=lambda s: s.split(','), help='Comma‑separated list of items')
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

# if args.with_verbose_execution is True make sure -Fe (the execution flags include -v (for verbose printing))
if args.with_verbose_printing == True:
    args.Fe = args.Fe+' -v '

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

# Which protocols do you want to test

protocols = args.protocols

## APF semi-honest
    # don't take the -R flag
#protocols = ['hemi','semi','soho','temi']
    # take the -R flag
#protocols = ['semi2k']
## APF malicious
    # take the -R flag
#protocols = ['spdz2k']
    # don't take the -R flag
#protocols += ['mascot']

### QP That do not take -R flag
#protocols = ['atlas', 'replicated-field', 'shamir', 'malicious-rep-field', 'ps-rep-field','sy-rep-field','sy-shamir', 'malicious-shamir']
## QP  THAT DO take the -R flag
#protocols = ['replicated-ring','brain','malicious-rep-ring','ps-rep-ring','sy-rep-ring']

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
                output = subprocess.getstatusoutput(f'./run -e {protocol} -p {args.path} -M {pathToMP} -F "{args.Fc}" -W "{args.Fe}" -I {args.I} -U {args.U}')
            else:
                print(f'./run -e {protocol} -N {args.N} -p {args.path} -M {pathToMP} -F "{args.Fc}" -W "{args.Fe}" -I {args.I} -U {args.U}')
                output = subprocess.getstatusoutput(f'./run -e {protocol} -N {args.N} -p {args.path} -M {pathToMP} -F "{args.Fc}" -W "{args.Fe}" -I {args.I} -U {args.U}')
            try:
                if args.with_verbose_printing==True:
                    ######    Online Execution Time  #################
                    index = str(output[1]).find('Spent ')
                    string = output[1][index+6:index+45].strip()
                    #make sure no chars slip in at the end
                    num_length = custom_strip(string)
                    execution_time_list_online.append(float(string[0:num_length]))

                    #####   Online Data Sent    ######################
                    start = index+6+num_length+9
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

                    try:
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
                    except ValueError:
                        print(f'Verify Offline is really gives no Data and Rounds for {protocol}')
                        data_offline.append(0)
                        rounds_offline.append(0)

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

                else:
                    #if with verbose printing is not True, just grab the three things
                    ######    Online Execution Time  #################
                    index = str(output[1]).find('Time = ')
                    string = output[1][index+7:index+45].strip()
                    #make sure no chars slip in at the end
                    num_length = custom_strip(string)
                    execution_time_list_CPU.append(float(string[0:num_length]))
                    ######    Total Rounds   #######################
                    index = str(output[1]).find('~')
                    string = output[1][index+1:index+30].strip()
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
    if args.with_verbose_printing==True:
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

        with open(os.path.join(output_path,f'{protocol}_sample_output.csv'),'w') as file:
            file.write(f'({output[0]}, {output[1]})')

    else:
        #with verbose printing is false
        with open(os.path.join(output_path,f'{protocol}_time.csv'),'w') as file:
            file.write('time\n')
            for i in range(len(execution_time_list_CPU)):
                file.write(f'{execution_time_list_CPU[i]}\n')


        with open(os.path.join(output_path,f'{protocol}_rounds.csv'),'w') as file:
            file.write(' total \n')
            for i in range(len(communication_rounds)):
                file.write(f'{communication_rounds[i]} \n')


        with open(os.path.join(output_path,f'{protocol}_data.csv'),'w') as file:
            file.write(' global \n')
            for i in range(len(global_data)):
                file.write(f'{global_data[i]} \n')

        with open(os.path.join(output_path,f'{protocol}_sample_output.csv'),'w') as file:
            file.write(f'({output[0]}, {output[1]})')
