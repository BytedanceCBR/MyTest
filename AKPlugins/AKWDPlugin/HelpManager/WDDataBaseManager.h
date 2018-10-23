//
//  WDDataBaseManager.h
//  Article
//
//  Created by xuzichao on 2016/12/6.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, WDDataBasePageType) {
    WDDataBasePageType_Category = 1,//默认为0，所以从1开始
    WDDataBasePageType_NeedToAnswer,
    WDDataBasePageType_InMessageInvite,
    WDDataBasePageType_Feed,
};

@interface WDDataBaseManager : NSObject

+ (NSString *)wenDaDBName;

+ (NSInteger)wenDaDBVersion;

@end
