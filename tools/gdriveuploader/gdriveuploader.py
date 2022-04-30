import os
import sys
import json
from PyQt5.QtCore import pyqtSlot
from tools.adds.basetool import Basetool
from pydrive.auth import GoogleAuth
from pydrive.drive import GoogleDrive


class Gdriveuploader(Basetool):
    def __init__(self):
        super(Gdriveuploader, self).__init__()

        self.dict_favor = {}
        self.path_to_dict_favor = 'tools/gdriveuploader/favorite.json'
        if os.path.exists(self.path_to_dict_favor):
            with open(self.path_to_dict_favor) as file:
                self.dict_favor = json.loads(file.read())

    @pyqtSlot(str, str)
    def upload(self, path, folder):
        if path.startswith("file://"):
            path = path[self.SYMBOLS_FOR_DELETE:]

        array = path.split(self.SEPARATOR)
        gauth = GoogleAuth()

        if os.path.exists("tools/gdriveuploader/mycreds.txt"):
            gauth.LoadCredentialsFile("tools/gdriveuploader/mycreds.txt")
        else:
            gauth.LocalWebserverAuth()
            gauth.SaveCredentialsFile("tools/gdriveuploader/mycreds.txt")

        drive = GoogleDrive(gauth)
        folder = folder.split('/')[-1]
        for file in array:
            file_drive = drive.CreateFile({'title': file.split('/')[-1], 'parents': [{'id': folder}]})
            file_drive.SetContentFile(os.path.join(path, file))
            file_drive.Upload()

        return True

    @pyqtSlot(str, str, result=list)
    def add_favorite(self, key, value):
        self.dict_favor[key] = value
        with open(self.path_to_dict_favor, 'w') as file:
            file.write(json.dumps(self.dict_favor))
        return list(self.dict_favor.keys())

    @pyqtSlot(result=list)
    def get_favorite_list(self):
        return list(self.dict_favor.keys())

    @pyqtSlot(str, result=str)
    def get_favorite(self, key):
        return self.dict_favor[key]

    @pyqtSlot(str, result=list)
    def remove_favorite(self, key):
        self.dict_favor.pop(key)
        with open(self.path_to_dict_favor, 'w') as file:
            file.write(json.dumps(self.dict_favor))
        return list(self.dict_favor.keys())
