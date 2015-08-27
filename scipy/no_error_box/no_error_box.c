#include <Python.h>
#include <windows.h>

LONG WINAPI no_error_box(LPEXCEPTION_POINTERS ep) {
  fputs(" Build crashed with unhandled exception!\n", stderr);
  _exit(1);
}

PyMODINIT_FUNC
initno_error_box(void)
{
    Py_InitModule("no_error_box", 0);
    SetErrorMode(SEM_FAILCRITICALERRORS |
                 SEM_NOALIGNMENTFAULTEXCEPT |
                 SEM_NOGPFAULTERRORBOX |
                 SEM_NOOPENFILEERRORBOX);
    SetUnhandledExceptionFilter(no_error_box);
}
