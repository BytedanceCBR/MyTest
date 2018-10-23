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
    push('news_explore')

def push(app_name):
    # wrapper = APNSNotificationWrapper('../iphone/essay/joke/joke_essay_iphone_dev.pem', True)
    wrapper = APNSNotificationWrapper('ck_explore_dist.pem', False)

    deviceToken = '9c6d06837e87067a03db6c96ecc4d495de010c1a071aa8d16baad3cd0600adf2'
    # create message
    message = APNSNotification()
    message.token(binascii.unhexlify(deviceToken))
#    c_url = APNSProperty('o_url', 'snssdk141://detail?groupid=1514045373')
#    message.appendProperty(c_url)
#
    c_id = APNSProperty('id', '1181984206')
    message.appendProperty(c_id)
    message.badge(98)

    #message.alert('Test message!')
    #c_rule_id = APNSProperty('rule_id', '1')
    #message.appendProperty(c_rule_id)
    #c_id = APNSProperty("id", "1170427089")
    #message.appendProperty(c_id)
#好友关注
    #message.alert('xx 关注了你')
# notice type
    #c_type = APNSProperty('t', '1')                                        
    #message.appendProperty(c_type)                                                      
# notice page
    #c_page = APNSProperty('p', '4')                                        
    #message.appendProperty(c_page)        
    #c_uid = APNSProperty('uid', '1028278749')                                     
    #message.appendProperty(c_uid)
    

    message.alert('xx xx')
    message
# notice type
#    c_type = APNSProperty('t', '2')                                        
#    message.appendProperty(c_type)
# notice page
#    c_page = APNSProperty('p', '5')                                        
#    message.appendProperty(c_page)
    # add message to tuple and send it to APNS server
    wrapper.append(message)
    wrapper.notify()

main()
