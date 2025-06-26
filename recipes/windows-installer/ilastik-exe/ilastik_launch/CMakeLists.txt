cmake_minimum_required(VERSION 3.10)
 
project(ilastik_launch)

add_definitions(-D_CRT_SECURE_NO_WARNINGS)
 
add_executable(ilastik 
               ilastik_launch.cxx ilastik_launch.rc)

INSTALL_TARGETS(/. ilastik)
