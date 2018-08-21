//
//  TTFontSettingContentItem.m
//  Article
//
//  Created by 延晋 张 on 2017/1/12.
//
//

#import "TTFontSettingContentItem.h"

NSString * const TTActivityContentItemTypeFontSetting         =
@"com.toutiao.ActivityContentItem.FontSetting";

@implementation TTFontSettingContentItem

- (NSString *)contentItemType
{
    return TTActivityContentItemTypeFontSetting;
}

@end
