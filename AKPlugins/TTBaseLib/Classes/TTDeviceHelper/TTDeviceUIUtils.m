//
//  TTDeviceUIUtils.m
//  Pods
//
//  Created by 冯靖君 on 17/5/16.
//
//

#import "TTDeviceUIUtils.h"

@implementation TTDeviceUIUtils

+ (CGFloat)tt_fontSize:(CGFloat)normalSize {
    CGFloat size = normalSize;
    switch ([TTDeviceHelper getDeviceType]) {
        case TTDeviceModePad: return size + (size > 15 ? 5 : 2);
        case TTDeviceMode736: return size;
        case TTDeviceMode667:
        case TTDeviceMode812: return size;
        case TTDeviceMode568: return size + (size > 15 ? -2 : -1);
        case TTDeviceMode480: return size + (size > 15 ? -2 : -1);
    }
    return normalSize;
}

+ (CGFloat)tt_padding:(CGFloat)normalPadding {
    CGFloat size = normalPadding;
    switch ([TTDeviceHelper getDeviceType]) {
        case TTDeviceModePad: return ceil(size * 1.3);
        case TTDeviceMode736: return ceil(size * 1.1);
        case TTDeviceMode667:
        case TTDeviceMode812: return ceil(size);
        case TTDeviceMode568: return ceil(size * 0.85);
        case TTDeviceMode480: return ceil(size * 0.85);
    }
}

+ (CGFloat)tt_lineHeight:(CGFloat)normalHeight {
    return ceil(normalHeight);
}

+ (CGFloat)tt_fontSizeForMoment:(CGFloat)normalSize {
    CGFloat size = normalSize;
    switch ([TTDeviceHelper getDeviceType]) {
        case TTDeviceModePad: return size + (size > 15 ? 5 : 2);
        case TTDeviceMode736: return size;
        case TTDeviceMode667:
        case TTDeviceMode812: return size;
        case TTDeviceMode568: return size + (size > 15 ? -2 : -1);
        case TTDeviceMode480: return size + (size > 15 ? -2 : -1);
    }
    return normalSize;
}

+ (CGFloat)tt_paddingForMoment:(CGFloat)normalPadding {
    CGFloat size = normalPadding;
    switch ([TTDeviceHelper getDeviceType]) {
        case TTDeviceModePad: return ceil(size * 1.3);
        case TTDeviceMode736: return ceil(size);
        case TTDeviceMode667:
        case TTDeviceMode812: return ceil(size);
        case TTDeviceMode568: return ceil(size * 0.85);
        case TTDeviceMode480: return ceil(size * 0.85);
    }
}

+ (CGFloat)tt_newFontSize:(CGFloat)normalSize {
    CGFloat size = normalSize;
    switch ([TTDeviceHelper getDeviceType]) {
        case TTDeviceModePad: return ceil(size * 1.3);
        case TTDeviceMode736: return ceil(size);
        case TTDeviceMode667:
        case TTDeviceMode812: return ceil(size);
        case TTDeviceMode568: return ceil(size * 0.9);
        case TTDeviceMode480: return ceil(size * 0.9);
    }
    return normalSize;
}

+ (CGFloat)tt_newPadding:(CGFloat)normalPadding{
    CGFloat size = normalPadding;
    switch ([TTDeviceHelper getDeviceType]) {
        case TTDeviceModePad: return ceil(size * 1.3);
        case TTDeviceMode736: return ceil(size);
        case TTDeviceMode667:
        case TTDeviceMode812: return ceil(size);
        case TTDeviceMode568: return ceil(size * 0.9);
        case TTDeviceMode480: return ceil(size * 0.9);
    }
}

+ (CGFloat)tt_newPaddingSpecialElement:(CGFloat)normalPadding{
    CGFloat size = normalPadding;
    switch ([TTDeviceHelper getDeviceType]) {
        case TTDeviceModePad: return ceil(size * 1.3);
        case TTDeviceMode736: return ceil(size);
        case TTDeviceMode667:
        case TTDeviceMode812: return ceil(size);
        case TTDeviceMode568: return ceil(size);
        case TTDeviceMode480: return ceil(size);
    }
}

+ (TTSplitScreenMode)currentSplitScreenWithSize:(CGSize)size {
    TTSplitScreenMode splitScreen = TTSplitScreenFullMode;
    if ([TTDeviceHelper isIpadProDevice]) {
        if (size.width == 981 || size.width == 639) {
            return TTSplitScreenBigMode;
        } else if (size.width == 678) {
            return TTSplitScreenMiddleMode;
        } else if (size.width == 375) {
            return TTSplitScreenSmallMode;
        }
    } else if ([TTDeviceHelper isPadDevice]) {
        if (size.width == 694 || size.width == 438) {
            return TTSplitScreenBigMode;
        } else if (size.width == 507) {
            return TTSplitScreenMiddleMode;
        } else if (size.width == 320) {
            return TTSplitScreenSmallMode;
        }
    }
    return splitScreen;
}

@end

