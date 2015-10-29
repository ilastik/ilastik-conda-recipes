cmake_minimum_required(VERSION 2.6)

PROJECT(no_error_box)

INCLUDE_DIRECTORIES(${PYTHON_INC})
ADD_LIBRARY(no_error_box SHARED no_error_box.c)
TARGET_LINK_LIBRARIES(no_error_box ${PYTHON_LIB})
SET_TARGET_PROPERTIES(no_error_box PROPERTIES 
                         OUTPUT_NAME "no_error_box" 
                         PREFIX "" SUFFIX  ".pyd")
INSTALL(TARGETS no_error_box RUNTIME DESTINATION ${INSTALL_DIR})
