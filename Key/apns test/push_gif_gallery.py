#!/usr/bin/env python
#coding=utf8
import binascii
from APNSWrapper import APNSNotificationWrapper
from APNSWrapper import APNSNotification
from APNSWrapper import APNSProperty

# import sys, binascii, datetime
# from APNSWrapper import APNSNotificationWrapper
# from APNSWrapper import APNSNotification
# from APNSWrapper import APNSAlert

# reload(sys)
# sys.setdefaultencoding("utf-8")

# MESSAGE_COUNT = 200

def main():
    push('gallery_gif')

def push(app_name):
    # wrapper = APNSNotificationWrapper('../iphone/essay/joke/joke_essay_iphone_dev.pem', True)
    wrapper = APNSNotificationWrapper('gifck.pem', True)

    # deviceToken = 'd3d81a7a7b569d353c589c4fd9765e7361514dfbe496edbf576af61c608a9612'
    # '48d00f9ba1ac35e5759f8e518810cf35dd3059b4dd14ed8b7913632338779141'
    deviceToken = '48d00f9ba1ac35e5759f8e518810cf35dd3059b4dd14ed8b7913632338779141'
                   
    # create message
    message = APNSNotification()
    message.token(binascii.unhexlify(deviceToken))

    message.badge(99)

    message.alert('Test message!')

    c_action = APNSProperty('action', 'itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=517166184')
    message.appendProperty(c_action)

    c_rule_id = APNSProperty('rule_id', '1')
    message.appendProperty(c_rule_id)

    # add message to tuple and send it to APNS server
    wrapper.append(message)
    wrapper.notify()

main()