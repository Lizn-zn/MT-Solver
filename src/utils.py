
import shlex
import os
import signal
import subprocess
import random

def parse_args(arg_str):
    """ parse args in string format into dict """
    parts = shlex.split(arg_str)    
    args_dict = {}
    current_option = None    
    for part in parts:
        if part.startswith('--'):
            current_option = part[2:]  
            args_dict[current_option] = None  
        else:
            if current_option:
                args_dict[current_option] = part
                current_option = None    
    return args_dict

def parse_string(s, start_marker, end_marker):
    """ parse the string between start_marker and end_marker
    """
    start_index = s.find(start_marker)
    end_index = s.find(end_marker)
    if start_index != -1 and end_index != -1:
        s = s[start_index + len(start_marker):end_index].strip()
        return s
    else:
        return ""
    
def normalize(args, solver_name):
    # for key in args:
        # if key == "timeout":
            # args[key] = int(args[key])
    args = {}
    return args
    
def wrap_exec(cmd, args, timeout, pid_mgr):
    """ wrap the execution of command with timeout """
    process = subprocess.Popen(cmd, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE, preexec_fn=os.setpgrp)
    pid = os.getpgid(process.pid)
    pid_mgr.append(pid)
    stdout_, stderr_ = process.communicate(args.encode(), timeout=timeout)
    pid_mgr.remove(pid) # if execute successfully, remove it from pid_mgr
    return stdout_.decode("utf-8"), stderr_.decode("utf-8")


def predict_next(polys, vars):
    """select the next variable for projection(random version currently)"""
    # TODO: combine with RL prediction model.
    selected_var = random.choice(vars)
    vars.remove(selected_var)
    vars.extend(selected_var)
    final_str = '[' + ','.join(vars) + ']'
    return final_str
    
    