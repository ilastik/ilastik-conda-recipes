# From http://zetcode.com/gui/pyqt4/firstprograms/
import sys
from PyQt4 import QtGui
from PyQt4 import QtCore

def main():    
    app = QtGui.QApplication(sys.argv)

    w = QtGui.QWidget()
    w.resize(250, 150)
    w.move(300, 300)
    w.setWindowTitle('Simple')
    w.show()

    QtCore.QTimer.singleShot(2000, app.quit)
    sys.exit(app.exec_())

if __name__ == '__main__':
    main()
