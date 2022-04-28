# This Python file uses the following encoding: utf-8
import sys
import os
from PyQt5.QtGui import QGuiApplication, QIcon
from PyQt5.QtQml import QQmlApplicationEngine
from Initer import Initer


if __name__ == "__main__":
    app = QGuiApplication(sys.argv)
    app.setWindowIcon(QIcon('icon.png'))

    engine = QQmlApplicationEngine()
    ctx = engine.rootContext()

    initer = Initer()

    # Init all tools.
    # initer generate commands above and here they will be executed
    for command in initer.get_commands():
        exec(command)

    ctx.setContextProperty('initer', initer)
    engine.load(os.path.join(os.path.dirname(__file__), "main.qml"))

    if not engine.rootObjects():
        sys.exit(-1)
    sys.exit(app.exec_())
