# This Python file uses the following encoding: utf-8
from PyQt5.QtCore import QObject, pyqtSlot
import os


class Initer(QObject):
    def __init__(self):
        super(Initer, self).__init__()
        parent_dir = 'tools'
        tools = os.listdir(parent_dir)
        tools.remove('__init__.py')
        tools.remove('__pycache__')
        self.model = []
        self.commands = []

        for tool in tools:
            self.commands.append(f'from tools.{tool}.{tool} import {tool.capitalize()}')
            self.commands.append(f'{tool} = {tool.capitalize()}()')
            self.commands.append(f'ctx.setContextProperty("{tool}", {tool})')

            self.model.append([
                os.path.join(parent_dir, tool, 'icon.png'),
                os.path.join(parent_dir, tool, f'{tool}.qml')
            ])
    
    
    @pyqtSlot(result=list)
    def get_model(self):
        return self.model

    def get_commands(self):
        return self.commands
