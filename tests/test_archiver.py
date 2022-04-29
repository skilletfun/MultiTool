from unittest import TestCase, main
import sys, os, shutil
sys.path.append('../tools/archiver')
sys.path.append('../tools/adds')
from archiver import Archiver


class ExtractTest(TestCase):
    def test_extract_one(self):
        archiver = Archiver()
        self.assertEqual(archiver.extract('./archiver_golds/gold.zip'), True)
        self.assertEqual(os.path.exists('archiver_golds/gold.zip_extracted'), True)
        self.assertEqual(set(os.listdir('archiver_golds/gold.zip_extracted')),
                         {'file_1.txt', 'file_2.txt', 'file_3.txt'})
        shutil.rmtree('archiver_golds/gold.zip_extracted')

    def test_extract_multi(self):
        archiver = Archiver()
        archiver.SEPARATOR = ','

        self.assertEqual(archiver.extract('./archiver_golds/gold.zip,./archiver_golds/gold_2.zip'), True)

        self.assertEqual(os.path.exists('archiver_golds/gold.zip_extracted'), True)
        self.assertEqual(os.path.exists('archiver_golds/gold_2.zip_extracted'), True)

        self.assertEqual(set(os.listdir('archiver_golds/gold.zip_extracted')),
                         {'file_1.txt', 'file_2.txt', 'file_3.txt'})
        self.assertEqual(set(os.listdir('archiver_golds/gold_2.zip_extracted')),
                         {'file_1.txt', 'file_2.txt', 'file_3.txt'})

        shutil.rmtree('archiver_golds/gold.zip_extracted')
        shutil.rmtree('archiver_golds/gold_2.zip_extracted')


    def test_pack(self):
        archiver = Archiver()
        archiver.SEPARATOR = ','
        files_list = os.listdir('./archiver_golds/gold_files')
        files_list = ','.join([os.path.join('./archiver_golds/gold_files', el) for el in files_list])
        self.assertEqual(archiver.pack(files_list), True)
        self.assertEqual(os.path.exists('./archiver_golds/gold_files/Archive.zip'), True)
        os.remove('./archiver_golds/gold_files/Archive.zip')


if __name__ == '__main__':
    main()
