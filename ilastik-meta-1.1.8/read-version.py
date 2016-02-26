import sys, re

s = open(sys.argv[1]).read()
version_line = re.findall(r'__version_info__ *=.*', s)[0]
exec version_line
print '.'.join(map(str,__version_info__))
