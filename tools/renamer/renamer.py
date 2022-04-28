# This Python file uses the following encoding: utf-8
from PyQt5.QtCore import QObject, pyqtSlot
import os
import sys


class Renamer(QObject):

    countOfDeletedSymbols = 7
    splitSeparator = ",file://"

    def __init__(self):
        super(Renamer, self).__init__()
        if sys.platform.startswith("linux"):
            self.countOfDeletedSymbols = 7
        else:
            self.countOfDeletedSymbols = 8
            self.splitSeparator = ",file:///"

    @pyqtSlot(str, str)
    def rename_files(self, files, mask):
        """ Rename files by given mask. """
        files = files[self.countOfDeletedSymbols:].split(self.splitSeparator)   # list of paths of files
        new_names = [""] * len(files)   # list of empty new paths of files

        # mask for rename:  File_?A:1:1??R:1:1 (example)
        mask = mask.split('?')
        flag = mask[0] == ''    # true if ? first

        for part_of_name in mask:
            if flag:
                new_names = self.append_numbers(new_names, part_of_name)
            elif part_of_name != '':
                new_names = [el + part_of_name for el in new_names]
            flag = not flag

        i = 0
        for file in files:
            new_path = os.path.join(os.path.dirname(file), new_names[i] + self.suffix(file))
            os.rename(file, new_path)
            i += 1

    def append_numbers(self, names, mask):
        """ Append numbers to paths. """
        mask = mask.split(':')
        step = int(mask[2])
        value = int(mask[1]) - step    # because init value we are needed but it can be loused in list comprehension

        if mask[0] == "A":
            return [el + str(value := value + step) for el in names]
        else:
            return [el + str(self.checkio(value := value + step)) for el in names]

    def checkio(self, n):
        """ Convert arabic number to rome number. """
        result = ''
        for arabic, roman in zip((1000, 900, 500, 400, 100, 90, 50, 40, 10, 9, 5, 4, 1),
                                 'M     CM   D    CD   C    XC  L   XL  X   IX V  IV I'.split()):
            result += n // arabic * roman
            n %= arabic
        return result


    def suffix(self, fullname):
        """ Get suffix of file. """
        return os.path.splitext(fullname)[1]