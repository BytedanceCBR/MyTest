//
//  TTQQFriendContentItem.m
//  Pods
//
//  Created by 张 延晋 on 16/06/03.
//
//

#import "TTQQFriendContentItem.h"
#import "TTShareAdapterSetting.h"

NSString * const TTActivityContentItemTypeQQFriend      =
@"com.toutiao.ActivityContentItem.qqFriend";

@implementation TTQQFriendContentItem

- (instancetype)initWithTitle:(NSString *)title
                         desc:(NSString *)desc
                   webPageUrl:(NSString *)webPageUr
                   thumbImage:(UIImage *)thumbImage
                     imageUrl:(NSString *)imageUrl
                     shareTye:(TTShareType)shareType
{
    if (self = [super init]) {
        self.title = title;
        self.desc = desc;
        self.webPageUrl = webPageUr;
        self.imageUrl = imageUrl;
        self.thumbImage = thumbImage;
        self.shareType = shareType;
    }
    return self;
}

-(NSString *)contentItemType
{
    return TTActivityContentItemTypeQQFriend;
}

- (NSString *)contentTitle
{
    if ([[TTShareAdapterSetting sharedService] isZoneVersion]) {
        return NSLocalizedString(@"QQ好友", nil);
    }else{
        return NSLocalizedString(@"QQ", nil);
    }
}

@end
