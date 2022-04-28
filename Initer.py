# This Python file uses the following encoding: utf-8
from PyQt5.QtCore import QObject, pyqtSlot
import os


class Initer(QObject):
    def __init__(self):
        super(Initer, self).__init__()
        parent_dir = 'tools'
        tools = os.listdir(parent_dir)  # list of folders with tools

        for useless in ['__init__.py', '__pycache__', 'adds']:
            tools.remove(useless)     # its not tool, so it removed

        self.model = []     # list with [icon, qml] for ListView in main.qml
        self.commands = []  # commands for set contextProperty in main.py by exec

        # fill self.model and self.commands
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
        """ Return model to qml """
        return self.model

    def get_commands(self):
        """ Return commands to execute in main.py """
        return self.commands
