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
    push('joke_essay')

def push(app_name):

    wrapper = APNSNotificationWrapper('../iphone/essay/joke/joke_essay_iphone_dev.pem', True)

    deviceToken = '70002cefa60a6b15831e0632234497f362bf18956dd7b189c59dd49674ca80a6' 
                   
    # create message
    message = APNSNotification()
    message.token(binascii.unhexlify(deviceToken))

    message.badge(98)

    message.alert('Test message!')

    c_action = APNSProperty('action', 'itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=517166184')
    message.appendProperty(c_action)

    c_rule_id = APNSProperty('rule_id', '1')
    message.appendProperty(c_rule_id)

    # add message to tuple and send it to APNS server
    wrapper.append(message)
    wrapper.notify()

main()