if conda list pyqt | grep 'pyqt *4' > /dev/null; then
    export QT_DRIVER=PyQt4
elif conda list pyqt | grep 'pyqt *5' > /dev/null; then
    export QT_DRIVER=PyQt5
elif conda list pyside | grep 'pyside' > /dev/null; then
    export QT_DRIVER=PyQt5
fi

nosetests test
