file(INSTALL ${PYTHON_BIN}/python.exe ${PYTHON_BIN}/python27.dll DESTINATION ${PYTHON_INSTALL_PREFIX})
file(INSTALL ../Include/ ../PC/pyconfig.h DESTINATION ${PYTHON_INSTALL_PREFIX}/include)
file(INSTALL ${PYTHON_BIN}/sqlite3.dll DESTINATION ${PYTHON_INSTALL_PREFIX}/DLLs)
file(INSTALL ${PYTHON_BIN}/ DESTINATION ${PYTHON_INSTALL_PREFIX}/DLLs FILES_MATCHING PATTERN *.pyd)
file(INSTALL ${PYTHON_BIN}/ DESTINATION ${PYTHON_INSTALL_PREFIX}/libs FILES_MATCHING PATTERN *.lib)
file(INSTALL ../Lib DESTINATION ${PYTHON_INSTALL_PREFIX})