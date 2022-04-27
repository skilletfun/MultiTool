# This Python file uses the following encoding: utf-8
from PyQt5.QtCore import QObject, pyqtSlot
import patoolib
import os
import sys


class Archiver(QObject):
    countOfDeletedSymbols = 7
    splitSeparator = ",file://"

    def __init__(self):
        super().__init__()
        if not sys.platform.startswith("linux"):
            self.countOfDeletedSymbols = 8
            self.splitSeparator = ",file:///"

    @pyqtSlot(str)
    def extract(self, path):
        array = path[self.countOfDeletedSymbols:].split(self.splitSeparator)
        print(array)
        for url in array:
            out_url = url + "_extracted"
            if not os.path.exists(out_url):
                os.makedirs(out_url)
            patoolib.extract_archive(url, outdir=out_url)

    @pyqtSlot(str)
    def pack(self, path):
        array = path[self.countOfDeletedSymbols:].split(self.splitSeparator)
        path = os.path.dirname(array[0])
        patoolib.create_archive(os.path.join(path, "Archive.zip"), array)
