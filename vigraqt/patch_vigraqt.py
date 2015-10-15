import sys, re

srcdir = sys.argv[1] + '/src/vigraqt/'

filename = srcdir + 'vigraqt.pro'
print "    patching ", filename
# Fix include dir
s = open(filename).read()
s = re.sub(r'include\(\.\./\.\./VigraQt\.pri\)', r'''include(../../VigraQt.pri)

win* {
   dlltarget.path=%s/bin
   INSTALLS += dlltarget
}
''' % sys.argv[2], s)
s = re.sub(r'TARGET\s*=\s*VigraQt', r'TARGET             = VigraQt\nwin*:INCLUDEPATH  += %s/include' % sys.argv[2], s)
s = re.sub(r'INSTALLS\s*=\s*target\s*headers', r'INSTALLS       = dlltarget target headers', s)
open(filename, "w").write(s)

# Fix round()
for file in ['cmgradient.cxx', 'qimageviewer.hxx', 'qimageviewer.cxx']:
    filename = srcdir + file
    print "    patching ", filename
    s = open(filename).read()
    s = re.sub(r'\(int\)round', r'vigra::roundi', s)
    s = re.sub(r'#include\s*\<math\.h\>', r'#include <math.h>\n#include <vigra/mathutil.hxx>', s)
    open(filename, "w").write(s)

srcdir = sys.argv[1] + '/src/sip/'

filename = srcdir + 'configure.py'
print "    patching ", filename
# Fix include dir
s = open(filename).read()
s = re.sub(r'config.sip_bin', r'config.sip_bin + ".exe"', s)
s = re.sub(r'os\.popen\("vigra-config --include-path"\)\.read\(\)\.strip\(\)', '"%s/include"' % sys.argv[2], s)
s = re.sub(r'(\s+)makefile\.extra_libs.*', r'\1makefile.extra_cxxflags    += ["-EHsc"]\1makefile.extra_libs         = ["%s/lib/VigraQt0"]' % sys.argv[2], s)
open(filename, "w").write(s)

filename = srcdir + 'VigraQtMod.sip'
print "    patching ", filename
# Fix include dir
s = open(filename).read()
s = re.sub(r'%Include qglimageviewer.sip.*', r'', s)
open(filename, "w").write(s)
