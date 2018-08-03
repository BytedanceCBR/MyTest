#!/usr/bin/env python
#coding=utf8
import binascii
from APNSWrapper import APNSNotificationWrapper
from APNSWrapper import APNSNotification
from APNSWrapper import APNSProperty

def main():
    push('social')

def push(app_name):
#    wrapper = APNSNotificationWrapper('ck_dis.pem', False)
    wrapper = APNSNotificationWrapper('explore_article_test.pem', False)
    token = '198325a33ca3d85aa7157c297767bd4b4f27ce41f08c2bae1f4ecf1a95c0e42d'
# test msg 反馈

#    message = APNSNotification()
#    message.token(binascii.unhexlify(token))
#    message.sound('default')
#    message.badge(92)
#    message.alert('了你的收顶了你的收顶了你的收收收收收')
#    c_url = APNSProperty('o_url', 'snssdk251://feedback')
#    message.appendProperty(c_url)
#    wrapper.append(message)
#    wrapper.notify()


# test msg 消息

#    message = APNSNotification()
#    message.token(binascii.unhexlify(token))
#    message.sound('default')
#    message.badge(92)
#    message.alert('了你的收顶了你的收顶了你的收收收收收')
#    c_url = APNSProperty('o_url', 'snssdk251://msg')
#    message.appendProperty(c_url)
#    wrapper.append(message)
#    wrapper.notify()

# test msg 通知

    message = APNSNotification()
    message.token(binascii.unhexlify(token))
    message.sound('default')
    message.badge(10)
    message.alert('了你的收顶了你的收顶了你的收收收收收222')
    c_url = APNSProperty('o_url', 'snssdk251://notification')
    message.appendProperty(c_url)
    wrapper.append(message)
    wrapper.notify()

#   新版推送详情页，没有使用

#    message = APNSNotification()
#    message.token(binascii.unhexlify(token))
#    message.sound('default')
#    message.alert('ttt')
#    message.badge(11)
#    c_url = APNSProperty('o_url', 'snssdk141://detail?groupid=3561356470')
#    message.appendProperty(c_url)
#    wrapper.append(message)
#    wrapper.notify()


#   推送详情页，现在使用
#    message = APNSNotification()
#    message.token(binascii.unhexlify(token))
#    message.sound('default')
#    message.alert('ttt')
#    message.badge(11)
#    c_id = APNSProperty('id', '-1550315998')
#    message.appendProperty(c_id)
#    wrapper.append(message)
#    wrapper.notify()


#   推送支持sslocal到详情页

#    message = APNSNotification()
#    message.token(binascii.unhexlify(token))
#    message.sound('default')
#    
#    message.alert('ttt')
#    message.badge(11)
#    c_url = APNSProperty('o_url', 'sslocal://detail?groupid=3103474968')
#    message.appendProperty(c_url)
#
#    message.alert('近日，达赖在日本公然称钓鱼岛为尖阁列岛，诬称“中国大陆反日情势高涨”原因在于“大陆实施反日极端教育”。')
#    c_id = APNSProperty('id', '3265372007')
#    message.appendProperty(c_id)
#
#    wrapper.append(message)
#    wrapper.notify()

main()


