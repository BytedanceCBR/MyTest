#!/usr/bin/env python
#coding=utf8
import sys, binascii, datetime
from APNSWrapper import APNSNotificationWrapper
from APNSWrapper import APNSNotification
from APNSWrapper import APNSAlert

reload(sys)
sys.setdefaultencoding("utf-8")

MESSAGE_COUNT = 200

def main():
    push('joke_essay')

def push(app_name):
    wrapper = APNSNotificationWrapper('food_dev.pem', True)

    deviceToken = 'd3d81a7a7b569d353c589c4fd9765e7361514dfbe496edbf576af61c608a9612'
    # deviceToken = '48d00f9ba1ac35e5759f8e518810cf35dd3059b4dd14ed8b7913632338779141'
                   
    # create message
    message = APNSNotification()
    message.token(binascii.unhexlify(deviceToken))
    message.badge(98)

#    alert = APNSAlert()
#    alert.alertBody = "kimi push alert!"
#    alert.action_loc_key = "acme2"
#    alert.loc_key = "GAME_PLAY_REQUEST_FORMAT"
#    alert.loc_args = ["Jenna", "Frank"]

#    message.alert(alert)

    # add message to tuple and send it to APNS server
    wrapper.append(message)
    wrapper.notify()

main()

