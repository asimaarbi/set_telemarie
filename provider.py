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
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///recipient.db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
db = SQLAlchemy(app)


class Recipient(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    uid = db.Column(db.Integer)
    email = db.Column(db.String(50), nullable=True)
    phone = db.Column(db.String(255), nullable=True)


users = Recipient.query.all()
for user in users:
    print(user.email, user.phone)

urls = []
class OpenerSession(ApplicationSession):
    @register('url.open')
    def _url_open(self, url):
        if url in urls:
            print('link already opened')
        else:
            if url == 'https://meet.jit.si/meet-grandma-hertau#config.prejoinPageEnabled=false':
                urls.append(url)
            p = multiprocessing.Process(target=self.open, args=(url,))
            p.start()

    def open(self, url):
        subprocess.check_call(shlex.split(f"chromium-browser {url}"))

    @register(None)
    def recipient(self, uid, email, phone, status):
        if status == 'delete':
            recipient = Recipient.query.filter((Recipient.email == email)).first()
            print(recipient.email)
            db.session.delete(recipient)
            db.session.commit()
            print("delete")
        elif status == 'update':
            recipient = Recipient.query.filter((Recipient.uid == uid)).first()
            recipient.email = email
            recipient.phone = phone
            db.session.commit()
            print("update")
        else:
            recipient = Recipient()
            recipient.uid = uid
            recipient.email = email
            recipient.phone = phone
            db.session.add(recipient)
            db.session.commit()
            print("created")

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

    async def onJoin(self, _details):
        regs = await self.register(self, prefix="org.deskconn.")
        for reg in regs:
            self.log.info("Registered procedure {procedure}", procedure=reg.procedure)

if __name__ == '__main__':
    runner = ApplicationRunner("ws://codebase.pk:9002/ws", realm="realm1")
    runner.run(OpenerSession)

