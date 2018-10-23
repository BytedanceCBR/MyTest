//
//  FRUIAdapter.m
//  Article
//
//  Created by 王霖 on 16/7/15.
//
//

#import "FRUIAdapter.h"
#import "TTDeviceHelper.h"

@implementation FRUIAdapter

static inline CGFLOAT_TYPE CGFloat_ceil(CGFLOAT_TYPE cgfloat) {
#if CGFLOAT_IS_DOUBLE
    return ceil(cgfloat);
#else
    return ceilf(cgfloat);
#endif
}

+ (CGFloat)tt_fontSize:(CGFloat)normalSize {
    CGFloat size = normalSize;
    switch ([TTDeviceHelper getDeviceType]) {
        case TTDeviceModePad: return CGFloat_ceil(size * 1.3f);
        case TTDeviceMode812:
        case TTDeviceMode736:
        case TTDeviceMode667: return CGFloat_ceil(size);
        case TTDeviceMode568:
        case TTDeviceMode480: return CGFloat_ceil(size * 0.9f);
    }

    return normalSize;
}

+ (CGFloat)tt_padding:(CGFloat)normalPadding {
    CGFloat size = normalPadding;
    switch ([TTDeviceHelper getDeviceType]) {
        case TTDeviceModePad: return CGFloat_ceil(size * 1.3f);
        case TTDeviceMode812:
        case TTDeviceMode736:
        case TTDeviceMode667: return CGFloat_ceil(size);
        case TTDeviceMode568:
        case TTDeviceMode480: return CGFloat_ceil(size * 0.9f);
    }

    return normalPadding;
}

@end
