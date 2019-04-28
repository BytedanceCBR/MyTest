//
//  TTQQZoneContentItem.m
//  Pods
//
//  Created by 张 延晋 on 16/06/03.
//
//

#import "TTQQZoneContentItem.h"

NSString * const TTActivityContentItemTypeQQZone        =
@"com.toutiao.ActivityContentItem.qqZone";

@implementation TTQQZoneContentItem

- (instancetype)initWithTitle:(NSString *)title
                         desc:(NSString *)desc
                   webPageUrl:(NSString *)webPageUrl
                   thumbImage:(UIImage *)thumbImage
                     imageUrl:(NSString *)imageUrl
                     shareTye:(TTShareType)shareType
{
    if (self = [super init]) {
        self.title = title;
        self.desc = desc;
        self.webPageUrl = webPageUrl;
        self.imageUrl = imageUrl;
        self.thumbImage = thumbImage;
        self.shareType = shareType;
    }
    return self;
}

-(NSString *)contentItemType
{
    return TTActivityContentItemTypeQQZone;
}

@end
