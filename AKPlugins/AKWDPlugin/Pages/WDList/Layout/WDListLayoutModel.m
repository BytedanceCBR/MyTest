//
//  WDListLayoutModel.m
//  TTWenda
//
//  Created by wangqi.kaisa on 2017/12/27.
//

#import "WDListLayoutModel.h"
#import "WDSettingHelper.h"
#import "WDLayoutHelper.h"
#import "WDUIHelper.h"

@implementation WDListLayoutModel

+ (CGFloat)questionDescContentFontSize {
    return WDFontSize(16.0f);
}

+ (CGFloat)questionDescContentLineHeight {
    return ceilf([WDListLayoutModel questionDescContentFontSize] * 1.4);
}

+ (CGFloat)questionFollowCountFontSize {
    if ([TTDeviceHelper is480Screen] || [TTDeviceHelper is568Screen]) {
        return 16.0f;
    } else {
        return WDFontSize(16.0f);
    }
}

+ (CGFloat)questionInviteAnswerImageFontSize {
    return 15;
}

+ (CGFloat)questionInviteAnswerFontSize {
    return 16;
}

+ (CGFloat)questionHeaderFollowFontSize {
    return [WDUIHelper wdUserSettingFontSizeWithFontSize:16.0f];
}

+ (CGFloat)questionHeaderFollowLineHeight {
    return [WDUIHelper wdUserSettingFontSizeWithFontSize:16.0f];
}

@end
