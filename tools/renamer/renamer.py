# This Python file uses the following encoding: utf-8
from tools.adds.basetool import Basetool
from PyQt5.QtCore import pyqtSlot
import os


class Renamer(Basetool):
    @pyqtSlot(str, str, result=bool)
    def rename_files(self, files: str, mask: str) -> bool:
        """ Rename files by given mask. """
        if files.startswith('file://'):
            files = files[self.SYMBOLS_FOR_DELETE:]

        files = files.split(self.SEPARATOR)  # List of paths to files for renaming.

        # If should to remove some substr from files
        if mask.startswith(':'):
            mask = mask[1:].split(':')
            self.remove_part_of_name(files, mask)
            return True

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

    def append_numbers(self, names: list[str], mask: str) -> list[str]:
        """ Addition numbers to filenames by mask. """
        mask = mask.split(':')
        step = int(mask[2])
        value = int(mask[1]) - step  # Because in comprehension down value increase by step immediately.

        if mask[0] == "A":
            return [el + str(value := value + step) for el in names]  # Arabic counter.
        else:
            return [el + str(self.checkio(value := value + step)) for el in names]  # Rome counter.

    def remove_part_of_name(self, files: list[str], mask: list[str]):
        for file in files:
            new_name = file.replace(mask[0], mask[1])
            if not os.path.exists(new_name):
                os.rename(file, new_name)

    def checkio(self, number: int) -> str:
        """ Convert arabic numbers to rome. """
        result = ''
        for arabic, roman in zip((1000, 900, 500, 400, 100, 90, 50, 40, 10, 9, 5, 4, 1),
                                 'M     CM   D    CD   C    XC  L   XL  X   IX V  IV I'.split()):
            result += number // arabic * roman
            number %= arabic
        return result


    def get_suffix(self, fullname: str) -> str:
        """ Suffix of file. """
        return os.path.splitext(fullname)[1]