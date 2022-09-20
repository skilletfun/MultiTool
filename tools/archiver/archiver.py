import os
import patoolib

from PyQt5.QtCore import pyqtSlot

from tools.adds.basetool import Basetool


class Archiver(Basetool):
    @pyqtSlot(str, result=bool)
    def extract(self, path: str):
        """
        Extract archive(-s).
        From 'Archive.zip' to 'Archive.zip_extracted/*'.
        """
        if path.startswith('file://'):
            path = path[self.SYMBOLS_FOR_DELETE:]

        array = path.split(self.SEPARATOR)
        for url in array:
            out_url = url + "_extracted"
            if not os.path.exists(out_url):
                os.makedirs(out_url)
            patoolib.extract_archive(url, outdir=out_url)
        return True

    @pyqtSlot(str, result=bool)
    def pack(self, path: str):
        """ Pack files to 'Archive.zip'. """
        if path.startswith('file://'):
            path = path[self.SYMBOLS_FOR_DELETE:]

        array = path.split(self.SEPARATOR)
        path = os.path.dirname(array[0])

        save_path = os.path.join(path, "Archive.zip")
        if os.path.exists(save_path):
            os.remove(save_path)

        patoolib.create_archive(save_path, array)
        return True
