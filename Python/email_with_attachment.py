#!/usr/bin/python

import os
import os.path
#import models
import base64
import smtplib
import mimetypes
from email.mime.multipart import MIMEMultipart
from email.mime.image import MIMEImage
from email.mime.base import MIMEBase
from email import encoders

class Mail():
    def __init__(self,parent):
        self.parent = parent
        self.db = self.parent.application.settings['db']
        self.user = 'bpopovich4@gmail.com'
        self.password = 'Creep!n44'
        self.to = 'bpopovich4@gmail.com'
        self.fromx = 'bpopovich4@gmail.com'

    def send(self, files=False):

        msg = MIMEMultipart()
        msg['Subject'] = 'Excel'

        msg['From'] = 'bpopovich4@gmail.com'
        msg['To'] = 'bpopovich4@gmail.com'
        msg.preamble = 'excel test'

        filename = 'test+file.xls'

        fp = open('tmp/'+filename, 'rb')
        xls = MIMEBase('application', 'vnd.ms-excel')
        xls.set_payload(fp.read())
        fp.close()
        encoders.encode_base64(xls)
        xls.add_header('Content-Disposition', 'attachment', filename=filename)
        msg.attach(xls)

        s = smtplib.SMTP('bar.com:26')
        s.ehlo
        s.login(self.user,self.password)
        s.sendmail(self.to, self.fromx, msg.as_string())
        s.close()
