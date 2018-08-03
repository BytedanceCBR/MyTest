//
//  NewsUserSettingManager.h
//  Article
//
//  Created by Hu Dianwei on 6/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SSUserSettingManager.h"

@interface NewsUserSettingManager : SSUserSettingManager

// whether force min_behot_time to 0
+ (void)setNeedLoadDataFromStart:(BOOL)fromStart;
+ (BOOL)needLoadDataFromStart;

+ (void)setHasShownHelp:(BOOL)shown;
+ (BOOL)hasShownHelp;

+ (BOOL)hasShownAutoRefresh;
+ (void)setHasShownAutoRefresh:(BOOL)shown;


// font settings
+ (NSArray*)fontSettings;
+ (NSString*)settedFontShortString;

+ (CGFloat)fontSizeFromNormalSize:(CGFloat)normalSize isWidescreen:(BOOL)isWide;

+ (float)settedEssayTextFontSize;
+ (float)settedEssayDetailViewTextFontSize;
+ (float)settedEssayTextFontLineHeight;
+ (float)settedEssayDetailViewTextFontLineHeight;

/*
 *  动态列表字体差值
 */

+ (float)settedMomentDiggCommentFontSize;

@end
