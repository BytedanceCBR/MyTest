//
//  TTVideoCommon.h
//  Article
//
//  Created by 刘廷勇 on 15/11/30.
//
//

#import <Foundation/Foundation.h>
#import "TTActivity.h"


typedef NS_ENUM(NSInteger,TTActivitySectionType){
    TTActivitySectionTypePlayerMore = 0,
    TTActivitySectionTypePlayerShare,
    TTActivitySectionTypeCentreButton,
    TTActivitySectionTypeListMore,
    TTActivitySectionTypeListShare,
    TTActivitySectionTypeDetailVideoOver,
    TTActivitySectionTypeListVideoOver,
    TTActivitySectionTypeDetailBottomBar,
    TTActivitySectionTypeListDirect,
    TTActivitySectionTypePlayerDirect
};



@interface TTVideoCommon : NSObject

+ (void) setCurrentFullScreen:(BOOL)isFull;
+ (BOOL) MovieWiewIsFullScreen;
+ (NSString *)PGCOpenURLWithMediaID:(NSString *)mediaID enterType:(NSString *)enterType;

+ (NSString *)videoListlabelNameForShareActivityType:(TTActivityType )activityType;

+ (NSString *)videoSectionNameForShareActivityType:(TTActivitySectionType )activityType;

+ (NSString *)videoListlabelNameForShareActivityType:(TTActivityType )activityType withCategoryId:(NSString *)categoryId;

+ (NSString *)newshareItemContentTypeFromActivityType:(TTActivityType )activityType;

+ (TTActivityType)activityTypeFromNewshareItemContentTypeFrom:(NSString *)contentType;

@end
