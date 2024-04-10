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