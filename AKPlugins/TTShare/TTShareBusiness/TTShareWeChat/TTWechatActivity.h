//
//  TTWechatActivity.h
//  TTActivityViewControllerDemo
//
//  Created by 延晋 张 on 16/6/6.
//
//

#import "TTActivityProtocol.h"
#import "TTWechatContentItem.h"

extern NSString * const TTActivityTypePostToWechat;

@interface TTWechatActivity : NSObject <TTActivityProtocol>

@property (nonatomic, strong) TTWechatContentItem *contentItem;

@end
