#!/usr/bin/env python
#coding=utf8
import binascii
from APNSWrapper.feedback import APNSFeedbackWrapper

feedback = APNSFeedbackWrapper('news.pem', True)
feedback.receive()
for t, v in feedback.tuples():
    token = binascii.b2a_hex(v)
    print token, t

