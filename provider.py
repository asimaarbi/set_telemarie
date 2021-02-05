import multiprocessing
import shlex
import subprocess
import sys

from PySide2.QtWidgets import QApplication, QMessageBox

from flask import Flask
from flask_sqlalchemy import SQLAlchemy

from autobahn.twisted.wamp import ApplicationSession, ApplicationRunner
from autobahn.wamp import register

app = Flask(__name__)

urls = []


class OpenerSession(ApplicationSession):
    @register('url.open')
    def _url_open(self, url):
        if url in urls:
            print('link already opened')
        else:
            if url == 'https://meet.jit.si/tm/1#config.prejoinPageEnabled=false':
                urls.append(url)
            p = multiprocessing.Process(target=self.open, args=(url,))
            p.start()

    def open(self, url):
        subprocess.check_call(shlex.split(f"chromium-browser --start-fullscreen {url}"))

    @register(None)
    def message(self, message):
        p = multiprocessing.Process(target=self._show_message, args=(message,))
        p.start()

    def _show_message(self, message):
        _app = QApplication([])
        msg_box = QMessageBox()
        msg_box.setText(message)
        msg_box.show()
        msg_box.exec_()

    @register(None)
    def power(self, command):
        if command == 'poweroff':
            subprocess.check_call(shlex.split(f"{command}"))
        elif command == 'reboot':
            subprocess.check_call(shlex.split(f"{command}"))

    async def onJoin(self, _details):
        regs = await self.register(self, prefix="tm.1.")
        for reg in regs:
            self.log.info("Registered procedure {procedure}", procedure=reg.procedure)


if __name__ == '__main__':
    runner = ApplicationRunner("ws://94.130.187.90:8080/ws", realm="realm1")
    runner.run(OpenerSession)
