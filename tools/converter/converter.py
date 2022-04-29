# This Python file uses the following encoding: utf-8
from PyQt5.QtCore import pyqtSlot
from tools.adds.basetool import Basetool
from PIL import Image
import sys
import os


class Converter(Basetool):
    @pyqtSlot(str, str)
    def convert(self, files, dest_sfx):
        if files.startswith("file://"):
            files = files[self.SYMBOLS_FOR_DELETE:]

        array = []
        if not os.path.isdir(files):
            array = files.split(self.SEPARATOR)

        save_dir = os.path.join(os.path.dirname(array[0]), "converted_files")
        if not os.path.exists(save_dir):
            os.makedirs(save_dir)

        for file in array:
            img = Image.open(file).convert("RGB")
            file_path = os.path.basename(file)
            file_path = file_path[:file_path.rfind('.') + 1]
            converted_path = os.path.join(save_dir,  file_path + dest_sfx)

            kwargs = { "format": dest_sfx.lower() }
            if dest_sfx == 'ico':
                sizes = [(255, 255), (128, 128), (64, 64), (48, 48), (32, 32), (24, 24), (16, 16)]
                index = next(x[0] for x in enumerate(sizes) if x[1] < img.size)
                kwargs['sizes'] = [sizes[index-1]]

            img.save(converted_path, **kwargs)