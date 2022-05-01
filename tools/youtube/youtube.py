from PyQt5.QtCore import QObject, pyqtSlot, QThread
from pytube import YouTube
from pytube import Playlist
import json
import os
import sys


class Worker(QObject):
    def __init__(self, url=None, save_path=None):
        super(Worker, self).__init__()
        self.js_videos_str = ''
        self.url = url
        self.js_videos = []
        self.save_path = save_path
        self.total_download = 0

    @pyqtSlot()
    def start_loading(self):
        if "playlist" in self.url or 'list=' in self.url:
            video_urls = [video for video in Playlist(self.url).video_urls]
        else:
            video_urls = [self.url]
        for url in video_urls:
            ytVideo = YouTube(url)
            title = ''.join([el for el in ytVideo.title if el not in '.,?!<>\\/"\'|:;'])
            self.js_videos.append({
                "title": title,
                "url": url,
                "image_url": ytVideo.thumbnail_url,
                "audio_state": "no",
                "video_state": "no"
            })
        self.js_videos_str = json.dumps(self.js_videos)

    @pyqtSlot()
    def download(self):
        if not self.save_path:
            self.save_path = os.getcwd()

        elif not os.path.exists(self.save_path):
            os.mkdir(self.save_path)

        for video in self.js_videos:
            src = name = None
            if video["audio_state"] == "yes":
                src = YouTube(video["url"]).streams.get_audio_only()
                name = '_audio.mp3'
            if video["video_state"] == "yes":
                src = YouTube(video["url"]).streams.get_highest_resolution()
                name = '_video.mp4'
            print('Start downloading')
            src.download(output_path=os.path.join(self.save_path, video["title"]), filename=video["title"] + name)
            self.total_download += 1


class Youtube(QObject):
    def __init__(self):
        super(Youtube, self).__init__()
        self.countOfDeletedSymbols = 7
        self.save_path = ""
        self.js_videos = []

        if not sys.platform.startswith("linux"):
            self.countOfDeletedSymbols = 8

    @pyqtSlot(str)
    def load(self, url):
        self.my_thread = QThread()
        self.worker = Worker(url, self.save_path)
        self.my_thread.started.connect(self.worker.start_loading)
        self.worker.moveToThread(self.my_thread)
        self.my_thread.start()

    @pyqtSlot(result=str)
    def check_response(self):
        res = self.worker.js_videos_str
        if res:
            self.close_thread()
        return res

    def close_thread(self):
        self.my_thread.terminate()
        self.my_thread.quit()
        self.my_thread = None

    @pyqtSlot(int)
    def remove_by_index(self, index):
        self.worker.js_videos.pop(index)

    @pyqtSlot(int, str)
    def set_audio_state(self, index, state):
        self.worker.js_videos[index]["audio_state"] = state

    @pyqtSlot(int, str)
    def set_video_state(self, index, state):
        self.worker.js_videos[index]["video_state"] = state

    @pyqtSlot(str)
    def set_save_folder(self, folder):
        if folder.startswith("file://"):
            folder = folder[self.countOfDeletedSymbols:]
        self.save_path = folder

    @pyqtSlot()
    def download(self):
        self.my_thread = QThread()
        videos = self.worker.js_videos
        self.worker = Worker(save_path=self.save_path)
        self.worker.js_videos = videos
        self.my_thread.started.connect(self.worker.download)
        self.worker.moveToThread(self.my_thread)
        self.my_thread.start()

    @pyqtSlot(result=int)
    def get_stats(self):
        return self.worker.total_download
