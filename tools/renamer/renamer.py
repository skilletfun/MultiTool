# This Python file uses the following encoding: utf-8
import sys
sys.path.append('../adds')
from basetool import Basetool
from PyQt5.QtCore import pyqtSlot
import os


class Renamer(Basetool):
    @pyqtSlot(str, str, result=bool)
    def rename_files(self, files: str, mask: str):
        """ Rename files by given mask. """
        if files.startswith('file://'):
            files = files[self.SYMBOLS_FOR_DELETE:]

        files = files.split(self.SEPARATOR)  # List of paths to files for renaming.
        new_names = [""] * len(files)  # Result list.

        mask = mask.split('?')  # Mask for renaming:  File_?A:1:1??R:1:1 (example).
        flag = mask[0] == ''  # If flag == True, digit goes the first

        for part_of_name in mask:
            if flag:
                new_names = self.append_numbers(new_names, part_of_name)
            elif part_of_name != '':
                new_names = [el + part_of_name for el in new_names]
            flag = not flag

        parent_dir = os.path.dirname(files[0])
        [os.rename(file, os.path.join(parent_dir, new_names[i] + self.get_suffix(file))) for i,file in enumerate(files)]
        return True

    def append_numbers(self, names: list, mask: str):
        """ Addition numbers to filenames by mask. """
        mask = mask.split(':')
        step = int(mask[2])
        value = int(mask[1]) - step  # Because in comprehension down value increase by step immediately.

        if mask[0] == "A":
            return [el + str(value := value + step) for el in names]  # Arabic counter.
        else:
            return [el + str(self.checkio(value := value + step)) for el in names]  # Rome counter.

    def checkio(self, n: int):
        """ Convert arabic numbers to rome. """
        result = ''
        for arabic, roman in zip((1000, 900, 500, 400, 100, 90, 50, 40, 10, 9, 5, 4, 1),
                                 'M     CM   D    CD   C    XC  L   XL  X   IX V  IV I'.split()):
            result += n // arabic * roman
            n %= arabic
        return result


    def get_suffix(self, fullname: str):
        """ Suffix of file. """
        return os.path.splitext(fullname)[1]