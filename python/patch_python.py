import sys, re

filename = sys.argv[1]
print "    patching ", filename
s = open(filename).read()
# enable support for Visual Studio 2010/2012 (note that the RE won't match twice)
if s.find("'/MANIFEST'") == -1:  # patch was not previously applied
    s = re.sub(r"(\s+)(ld_args\.append\('/MANIFESTFILE:'.*)", r"\1\2\1ld_args.append('/MANIFEST')", s)
open(filename, "w").write(s)

filename = sys.argv[2]
print "    patching ", filename
s = open(filename).read()
replacement = '''return ['msvcr90']
        elif msc_ver == '1600':
            # VS2010 / MSVC 10.0
            return ['msvcr100']
        elif msc_ver == '1700':
            # VS2012 / MSVC 11.0
            return ['msvcr110']'''
# enable support for Visual Studio 2010/2012
if s.find("'msvcr100'") == -1:  # patch was not previously applied
    s = re.sub(r"return \['msvcr90'\]", replacement, s)
open(filename, "w").write(s)
