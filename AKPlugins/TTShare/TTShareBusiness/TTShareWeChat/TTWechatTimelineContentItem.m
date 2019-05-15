//
//  TTWechatTimelineContentItem.m
//  Pods
//
//  Created by 延晋 张 on 16/6/6.
//
//

#import "TTWechatTimelineContentItem.h"

NSString * const TTActivityContentItemTypeWechatTimeLine    =
@"com.toutiao.ActivityContentItem.wechatTimeLine";

@implementation TTWechatTimelineContentItem

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
    return TTActivityContentItemTypeWechatTimeLine;
}

@end
