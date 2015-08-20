import os, sys, re, urllib, zipfile

# retrieve the MSVC build files
archive  = 'fftw-3.3-libs-visual-studio-2010.zip'
url      = "ftp://ftp.fftw.org/pub/fftw/"
fftwdir  = sys.argv[1]
builddir = fftwdir + "/fftw-3.3-libs"
print "    patching ", builddir

os.chdir(fftwdir)
urllib.urlretrieve(url + archive, archive)
zipfile.ZipFile(archive).extractall()

# set the right platform toolset
for proj in [builddir + "/libfftw-3.3/libfftw-3.3.vcxproj", builddir + "/libfftwf-3.3/libfftwf-3.3.vcxproj"]:
    s = open(proj).read()
    s = re.sub(r'\<PlatformToolset\>.+\</PlatformToolset\>', '<PlatformToolset>v100</PlatformToolset>', s)
    s = re.sub(r'\<ClCompile Include="([^"]*)mkprinter-file.c"\>', 
    '<ClCompile Include="\\1mkprinter-str.c" />\n<ClCompile Include="\\1mkprinter-file.c">', s)
    open(proj, "w").write(s)
