//
//  TTVideoTip.h
//  Article
//
//  Created by panxiang on 16/12/20.
//
//

#import <Foundation/Foundation.h>

static NSString * _Nonnull const kVideoTipCanShowKey = @"kVideoTipCanShowKey";
static NSString * _Nonnull const kVideoTipLastShowDateKey = @"kVideoTipLastShowDateKey";

@interface TTVideoTip : NSObject
#pragma mark -
#pragma mark Video tip

+ (BOOL)shouldShowVideoTip;

+ (void)saveVideoTipShowDate;

+ (NSTimeInterval)lastVideoTipShowDate;

+ (void)setCanShowVideoTip:(BOOL)canShow;

+ (void)setHasShownVideoTip:(BOOL)hasShown;

+ (BOOL)hasShownVideoTip;

#pragma mark -
#pragma mark Fav login tip

+ (void)setHasTipFavLoginUserDefaultKey:(BOOL)hasTip;

+ (BOOL)hasTipFavLoginUserDefaultKey;
@end
