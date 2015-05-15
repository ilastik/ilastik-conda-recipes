import os
from os.path import basename, join

import subprocess
import conda_build.macho as macho


PREFIX = os.getenv('PREFIX')
BIN = join(PREFIX, 'bin')
LIBVTK = join(PREFIX, 'lib/vtk-5.10')

# Use the prefix python to locate the vtk python package (it resides in an egg)
PREFIX_PYTHON = join(PREFIX, 'bin/python')
SP_VTK = subprocess.check_output(
    [PREFIX_PYTHON, "-c", "import imp; print imp.find_module('vtk')[1]"]).strip()

def ch_link_libvtk(path, link):
    if link.startswith('libpython'):
        return '@loader_path/../%s' % basename(link)

    if (   link.startswith('libpng') 
        or link.startswith('libtiff')
        or link.startswith('libxml2')
        or link.startswith('libjpeg')
        or link.startswith('libz')):
        return '@loader_path/../%s' % basename(link)

    if link.startswith('lib'):
        return '@loader_path/./%s' % basename(link)

def ch_link_bin(path, link):
    if not basename(path).startswith('vtk'):
        return

    if link.startswith('libpython'):
        return '@loader_path/../lib/%s' % basename(link)

    if (   link.startswith('libpng') 
        or link.startswith('libtiff')
        or link.startswith('libxml2')
        or link.startswith('libjpeg')
        or link.startswith('libz')):
        return '@loader_path/../lib/%s' % basename(link)

    if link.startswith('lib'):
        return '@loader_path/../lib/vtk-5.10/%s' % basename(link)

def ch_link_spvtk(path, link):
    if (   link.startswith('libpng') 
        or link.startswith('libtiff')
        or link.startswith('libxml2')
        or link.startswith('libjpeg')
        or link.startswith('libz')):
        return '@loader_path/../../../%s' % basename(link)

    if '/VTK5.10.1/' in link:
        return '@loader_path/../../../vtk-5.10/%s' % basename(link)

def main():
    for fn in os.listdir(LIBVTK):
        path = join(LIBVTK, fn)
        if macho.is_macho(path):
            macho.install_name_change(path, ch_link_libvtk)

    for fn in os.listdir(BIN):
        path = join(BIN, fn)
        if macho.is_macho(path):
            macho.install_name_change(path, ch_link_bin)

    for fn in os.listdir(SP_VTK):
        path = join(SP_VTK, fn)
        if macho.is_macho(path):
            macho.install_name_change(path, ch_link_spvtk)

if __name__ == '__main__':
    main()

