
import shlex

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