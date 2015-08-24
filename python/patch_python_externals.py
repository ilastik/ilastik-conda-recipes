import sys, re, glob

sqlite_path = re.sub(r'.*(sqlite-.*)', r'\1', glob.glob('../externals/sqlite*')[0])

filename = "pyproject.props"
print "    patching ", filename
s = open(filename).read()
s = re.sub(r'sqlite-3\.6\.21', sqlite_path, s)
open(filename, "w").write(s)

filename = "x64.props"
print "    patching ", filename
s = open(filename).read()
s = re.sub(r"\<PythonExe\>[^<]*\</PythonExe\>", r"<PythonExe>amd64\\python.exe</PythonExe>", s)
open(filename, "w").write(s)

filename = "build_ssl.py"
print "    patching ", filename
s = open(filename).read()
s = re.sub(r'-e "use Win32;"', r"-v", s)
s = re.sub(r'if line\.startswith\("CFLAG="\):', r'if False: # line.startswith("CFLAG="):', s)
open(filename, "w").write(s)
