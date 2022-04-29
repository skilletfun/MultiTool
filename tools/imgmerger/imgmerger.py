# This Python file uses the following encoding: utf-8
from tools.adds.basetool import Basetool
from PyQt5.QtCore import pyqtSlot
from PIL import Image
import os
import json
import re


class Imgmerger(Basetool):
    counter = 0  # While cut - increment it
    flag = False  # For delete _temp.png

    @pyqtSlot(str, result=str)
    @pyqtSlot(str, int, int, result=str)
    def merge_images(self, filepaths: str, cut_position=None, visible_height=None):
        self.counter += 1
        if filepaths.startswith('file://'):
            filepaths = filepaths[self.SYMBOLS_FOR_DELETE:]

        # Define variables
        images_paths = filepaths.split(self.SEPARATOR)
        new_height = 0
        images = []
        result_url = ''

        # Create save folder
        dir_name = os.path.dirname(os.path.abspath(images_paths[0]))
        save_path = os.path.join(dir_name, "Appended_images") if not dir_name.endswith('Appended_images') else dir_name
        if not os.path.exists(save_path):
            os.makedirs(save_path)

        # Open images
        for path in images_paths:
            image = Image.open(path)
            new_height = new_height + image.size[1]
            images.append(image)

        if cut_position:
            new_height -= images[-1].size[1]
            cut_height = int(visible_height / images[-1].size[1] * cut_position)
            new_height += cut_height
        new_width = images[0].size[0]

        # Save image
        save_image = Image.new('RGB', (new_width, new_height), 'white')
        new_height = 0
        for image in images:
            save_image.paste(image, (0, new_height))
            new_height = new_height + image.size[1]
            image.close()
        save_image.save(os.path.join(save_path, str(self.counter) + ".png"))
        save_image.close()

        if cut_position:
            result_url = self.cut(images_paths[-1], cut_height, new_width, save_path)

        if not cut_position:
            self.counter = 0
            temp_path = os.path.join(save_path, '_temp.png')
            if os.path.exists(temp_path): os.remove(temp_path)
        return result_url

    def cut(self, image, cut_height, width, save_path):
        # cut_position - needed height, but height of visible image and original image
        # may be different, so it should be multiplied by coefficient.
        image = Image.open(image)
        temp_img = Image.new('RGB', (width, image.size[1] - cut_height), 'white')
        crop_area = (0, cut_height, width, image.size[1])
        temp_img.paste(image.crop(crop_area), (0, 0))

        temp_path = os.path.join(save_path, "_temp.png")
        if os.path.exists(temp_path):
            os.remove(temp_path)

        temp_img.save(temp_path)
        temp_img.close()
        return self.SEPARATOR[1:] + temp_path

    @pyqtSlot(str, result=str)
    def get_list_from_url(self, url: str):
        """ Return to qml list of image's urls. """
        if url.startswith('file://'):
            url = url[self.SYMBOLS_FOR_DELETE:]
        sorted_files = self.sort_alphanumerically(os.listdir(url))
        files_with_full_paths = [self.SEPARATOR[1:] + os.path.join(url, file) for file in sorted_files]
        return json.dumps({"urls": files_with_full_paths})

    def sort_alphanumerically(self, data: list):
        """ Sort given list. """
        convert = lambda text: int(text) if text.isdigit() else text.lower()
        alphanum_key = lambda key: [convert(c) for c in re.split('([0-9]+)', key)]
        return sorted(data, key=alphanum_key)
