//
//  TSVAdaptivePointValue.c
//  AFgzipRequestSerializer
//
//  Created by Zuyang Kou on 19/12/2017.
//

#include "TSVAdaptivePointValue.h"
#import "TTDeviceHelper.h"

YGValue TSVAdaptivePointValue(CGFloat value)
{
    if ([TTDeviceHelper isScreenWidthLarge320]) {
        return (YGValue) { .value = value, .unit = YGUnitPoint };
    } else {
        return (YGValue) { .value = ceil(value * 0.9), .unit = YGUnitPoint };
    }
}

CGFloat TSVAdaptiveGeometry(CGFloat value)
{
    if ([TTDeviceHelper isScreenWidthLarge320]) {
        return value;
    } else {
        return ceil(value * 0.9);
    }
}
