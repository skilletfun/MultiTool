import os
from unittest import TestCase, main
import sys
sys.path.append('../tools/renamer')
sys.path.append('../tools/adds')
from renamer import Renamer


class RenamerTest(TestCase):
    renamer = Renamer()

    def test_suffix(self):
        self.assertEqual(self.renamer.get_suffix('file.txt'), '.txt')

    def test_checkio(self):
        self.assertEqual(self.renamer.checkio(7), 'VII')
        self.assertEqual(self.renamer.checkio(501), 'DI')
        self.assertEqual(self.renamer.checkio(27), 'XXVII')

    def test_append_numbers(self):
        self.assertEqual(self.renamer.append_numbers(['File_', 'File_'], 'A:1:1'), ['File_1', 'File_2'])
        self.assertEqual(self.renamer.append_numbers(['File_', 'File_'], 'R:1:1'), ['File_I', 'File_II'])

    def test_rename_files(self):
        self.renamer.SEPARATOR = ','
        files = ','.join([os.path.join('./renamer_golds', el) for el in os.listdir('./renamer_golds')])

        self.assertEqual(self.renamer.rename_files(files, 'File_?A:1:1??R:1:1'), True)
        self.assertEqual(set(os.listdir('./renamer_golds')), {'File_1I.txt', 'File_2II.txt'})

        files = ','.join([os.path.join('./renamer_golds', el) for el in os.listdir('./renamer_golds')])

        self.assertEqual(self.renamer.rename_files(files, 'file_?A:1:1'), True)
        self.assertEqual(set(os.listdir('./renamer_golds')), {'file_1.txt', 'file_2.txt'})


if __name__ == '__main__':
    main()