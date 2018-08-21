//
//  TTSettingMineTabGroup.h
//  Article
//
//  Created by fengyadong on 16/11/2.
//
//

#import "TTSettingGeneralGroup.h"

static NSString *const kAKIdenfitierPhotoCarouselKey = @"mine_photo_carousel";

typedef NS_ENUM(NSUInteger, TTSettingMineTabGroupType){
    TTSettingMineTabGroupTypeiPhoneTopFuction = 0,//iPhone上收藏历史日夜间section
    TTSettingMineTabGroupTypeiPadTopFuction,//iPad上收藏历史日夜间section
    TTSettingMineTabGroupTypeMessage,//消息通知 group
    TTSettingMineTabGroupTypeMall,//头条商城 iPhone only
    TTSettingMineTabGroupTypeSettings,//设置
    TTSettingMineTabGroupTypePhotoCarousel,//轮播图
};

@interface TTSettingMineTabGroup : TTSettingGeneralGroup

- (instancetype)initWithArray:(NSArray *)array;
+ (instancetype)initWithGroupType:(TTSettingMineTabGroupType)type;

@end
