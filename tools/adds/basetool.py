import sys

from PyQt5.QtCore import QObject, pyqtSlot


class Basetool(QObject):
    SYMBOLS_FOR_DELETE = 7
    SEPARATOR = ",file://"

    def __init__(self):
        super(Basetool, self).__init__()
        if not sys.platform.startswith("linux"):
            self.SYMBOLS_FOR_DELETE = 8
            self.SEPARATOR = ",file:///"