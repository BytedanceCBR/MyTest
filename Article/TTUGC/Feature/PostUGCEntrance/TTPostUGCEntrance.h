//
//  TTPostUGCEntrance.h
//  Article
//
//  Created by 王霖 on 16/10/21.
//
//

#import <SSThemed.h>

extern NSString *kTTSpringShortVideoEntranceDidTap;

typedef NS_ENUM(NSInteger, TTPostUGCEntranceButtonType) {
    TTPostUGCEntranceButtonTypeText,
    TTPostUGCEntranceButtonTypeImage,
    TTPostUGCEntranceButtonTypeVideo,
    TTPostUGCEntranceButtonTypeWenda,
    TTPostUGCEntranceButtonTypeImageAndText,
    TTPostUGCEntranceButtonTypeShortVideo,
    TTPostUGCEntranceButtonTypeXiguaLive
};

@class PopoverAction;
@interface TTPostUGCEntrance : SSThemedView

+ (void)showMainPostUGCEntrance;//主发布器

+ (void)showPostUGCEntrance; //其它发布器

+ (void)showConcernPagePostUGCEntranceWithModels:(NSArray <FRPublishConfigStructModel *> *)models tapActionParams:(NSDictionary *)tapActionParams; //关心主页发布器

+ (BOOL)isShowing;

- (NSArray<PopoverAction *> *)topBarPublishActions;

@end
