//
//  TTRImpression.h
//  Article
//
//  Created by Chen Hong on 2017/6/27.
//
//

//https://wiki.bytedance.net/pages/viewpage.action?title=Impression%20Lib&spaceKey=TTRD
/*
 前端通过JsBridge传递impression相关数据，客户端负责进行时长统计（包括对页面跳转、前后台切换处理）和数据打包上传处理
 前端传输格式如下：
 func: impression
 params:
 {
 "imp_group_list_type":1,
 "imp_group_key_name":"key",
 "imp_group_extra":{},
 "impressions_in":[
 {
 "imp_item_type":1,
 "imp_item_id":"id",
 "imp_item_extra":{}
 }
 ],
 "impressions_out":[
 {
 "imp_item_type":1,
 "imp_item_id":"id",
 "imp_item_extra":{}
 }
 ]
 }
 其中 impressions_in 代表当前展示的item，impressions_out 代表滑出屏幕的item
 
 客户端通过ImpressionManager#onWebImpression(JSONObject params)接收
 */

#import <Foundation/Foundation.h>
#import <TTRexxar/TTRDynamicPlugin.h>

@interface TTRImpression : TTRDynamicPlugin

TTR_EXPORT_HANDLER(onWebImpression)
//TTR_EXPORT_HANDLER(onWebRect)

@end
