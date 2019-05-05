//
//  TTWechatContentItem.m
//  Pods
//
//  Created by 延晋 张 on 16/6/6.
//
//

#import "TTWechatContentItem.h"

NSString * const TTActivityContentItemTypeWechat        =
@"com.toutiao.ActivityContentItem.wechat";

@implementation TTWechatContentItem

- (instancetype)initWithTitle:(NSString *)title
                         desc:(NSString *)desc
                   webPageUrl:(NSString *)webPageUrl
                   thumbImage:(UIImage *)thumbImage
                    shareType:(TTShareType)shareType
{
    if (self = [super init]) {
        self.title = title;
        self.desc = desc;
        self.webPageUrl = webPageUrl;
        self.thumbImage = thumbImage;
        self.shareType = shareType;
    }
    return self;
}

-(NSString *)contentItemType
{
    return TTActivityContentItemTypeWechat;
}

@end
