cmake_minimum_required(VERSION 2.6)

PROJECT(emulate_c99)

ADD_LIBRARY(emulate_c99 STATIC c99.c)

INSTALL(TARGETS emulate_c99
        RUNTIME DESTINATION bin 
        LIBRARY DESTINATION lib 
        ARCHIVE DESTINATION lib)
