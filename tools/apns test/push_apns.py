#!/usr/bin/env python
#coding=utf8
import sys, binascii, datetime
from APNSWrapper import APNSNotificationWrapper
from APNSWrapper import APNSNotification
from APNSWrapper import APNSAlert
from APNSWrapper import APNSProperty

reload(sys)
sys.setdefaultencoding("utf-8")

MESSAGE_COUNT = 200

def main():
    push('app_name')

def push(app_name):
    wrapper = APNSNotificationWrapper('ck.pem', False)     # True for debug

    # kimi's iphone 45c0afa0c1893a0c74eb36eac7a7d01d0ca1c1a24c4b95bcb4c859491bcce484
    # kimi's iPad   157b0ffb74f43bb62ca9cafa76b38d9a2c7fa88b9a42a40fc6aa5d14393fc2fe
#    deviceToken = '45c0afa0c1893a0c74eb36eac7a7d01d0ca1c1a24c4b95bcb4c859491bcce484'
    deviceToken = 'a0c37b814bac6571c10f8f2a9e02c09db400cae71df981a334e03619c21a4fce'
    deviceToken = '194792fc6d9095909f18b9b6926ec127aa9ea17fe78b372b11e68359ceceabf2'
    deviceToken = '68860aedb7a97845242528c94b3dee75988cf019fc5fa6f43ed6cf4f16dc3647'
    message = APNSNotification()
    message.token(binascii.unhexlify(deviceToken))
    
    # 收到信息声音提醒（每条提示都可以有）：
    message.sound('default')
    
    # 推badge：
    message.badge(100)
    
    # # =========== 通过apn做应用互推，用户点击apn后会启动应用并弹窗：===========
    # c_action = APNSProperty('action', 'http://itunes.apple.com/cn/app/nei-han-duan-zi/id517166184?mt=8')
    # message.appendProperty(c_action)
    # c_rule_id = APNSProperty('rule_id', '1')
    # message.appendProperty(c_rule_id)
    
    # message.alert('通过apn做应用互推，用户点击apn后会启动应用并弹窗')
    
    # o_url，打开schema
    
    base_url = 'snssdk251://'
    
    # # article
    # # iphone&ipad
    # o_url = base_url + 'home'
    # o_url = base_url + 'home/activity'
    # o_url = base_url + 'home/category'
    # o_url = base_url + 'home/left_navi'
    # o_url = base_url + 'profile'
    # o_url = base_url + 'profile/activity'
    # o_url = base_url + 'profile/repin'
    # o_url = base_url + 'profile/comments'
    # o_url = base_url + 'notification'
    # o_url = base_url + 'notification?source=dig_favorite'
    # o_url = base_url + 'detail?groupid=1767498060'
    # o_url = base_url + 'comments?groupid=1767498060?groupid=1767'
    # o_url = base_url + 'comments?groupid=1767730033&type=essay'
    # o_url = base_url + 'comments?groupid=1764320375'
    # o_url = base_url + 'relation'
    # o_url = base_url + 'relation?uid=8'
    # o_url = base_url + 'relation/following'
    # o_url = base_url + 'relation/following?uid=8'
    # o_url = base_url + 'relation/follower'
    # o_url = base_url + 'relation/follower?uid=8'
    # o_url = base_url + 'profile_manager'
    # o_url = base_url + 'add_friend'
    # o_url = base_url + 'invite_friend'
    # o_url = base_url + 'more'
    # o_url = base_url + 'applist'
    # o_url = base_url + 'feedback'
    # o_url = base_url + 'favorite'
    # o_url = base_url + 'favorite?type=image'
    # o_url = base_url + 'favorite?type=essay'
    o_url = base_url + 'category_feed?category=news_sports&name=house'
    # o_url = base_url + 'category_feed?category=image_funny&type=image&name=Funny'
    # # iphone
    # o_url = base_url + 'home/news'
    # o_url = base_url + 'subscribe_category'
    
    # essay
    # o_url = base_url + 'new'
    # o_url = base_url + 'hot'
    # o_url = base_url + 'comments?groupid=2166478216'
    # o_url = base_url + 'comments?groupid=2166478216&type=image'
    # o_url = base_url + 'essay_random'
    # o_url = base_url + 'essay_ugc'
    # o_url = base_url + 'image_ugc'
    # o_url = base_url + 'image_new'
    # o_url = base_url + 'image_hot'
    # o_url = base_url + 'image_random'
    # o_url = base_url + 'image_repin'
    # o_url = base_url + 'image_repin?uid=8'
    # o_url = base_url + 'my_tab'
    # o_url = base_url + 'my_tab?uid=8'
    # o_url = base_url + 'more'
    # o_url = base_url + 'post_joke'
    # o_url = base_url + 'review_joke'
    # o_url = base_url + 'my_post'
    # o_url = base_url + 'my_post?uid=8'
    # o_url = base_url + 'my_comments'
    # o_url = base_url + 'my_comments?uid=8'
    # o_url = base_url + 'profile_manager'
    # o_url = base_url + 'applist'
    # o_url = base_url + 'feedback'
    # o_url = base_url + 'notification'
    # o_url = base_url + 'home/news'
    
    c_url = APNSProperty('o_url', o_url)
    message.appendProperty(c_url)
    message.alert('终于可以了:' + o_url)


    # =========== old logic ===========
    
    # 推新闻，点击后跳新闻详情页：
    # c_id = APNSProperty('id', '1181984206')
    # message.alert('apn跳转旧逻辑:detail')
    # message.appendProperty(c_id)
    
    # 好友关注，跳到该好友profile页面：
    # # notice type
    # c_type = APNSProperty('t', '1')
    # message.appendProperty(c_type)
    # # notice page
    # c_page = APNSProperty('p', '4')
    # message.appendProperty(c_page)
    # c_uid = APNSProperty('uid', '8')
    # message.appendProperty(c_uid)
    
    # 站外好友加入，跳到该好友profile页面：
    # # notice type
    # c_type = APNSProperty('t', '1')
    # message.appendProperty(c_type)
    # # notice page
    # c_page = APNSProperty('p', '4')
    # message.appendProperty(c_page)
    # c_uid = APNSProperty('uid', '8')
    # message.appendProperty(c_uid)
    
    # 评论回复、顶踩消息，跳到自己profile的消息tab：
    # # notice type
    # c_type = APNSProperty('t', '2')
    # message.appendProperty(c_type)
    # # notice page
    # c_page = APNSProperty('p', '5')
    # message.appendProperty(c_page)
    
    # add message to tuple and send it to APNS server
    wrapper.append(message)
    wrapper.notify()

main()


