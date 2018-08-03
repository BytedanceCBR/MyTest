//
//  WDDetailNatantLayout.m
//  Article
//
//  Created by Ray on 16/5/9.
//
//

#import "WDDetailNatantLayout.h"
#import "TTDeviceHelper.h"

@implementation WDDetailNatantLayout


- (CGFloat)leftMargin{
    return 15;
}

- (CGFloat)rightMargin{
    return 15;
}

- (CGFloat)topMargin{
    CGFloat value;
    if ([TTDeviceHelper isPadDevice]) {
        value = 16.f;
    } else if ([TTDeviceHelper is736Screen] || [TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]) {
        value = 21.f;
    } else {
        value = 16.0;
    }
    return value;
}

- (CGFloat)bottomMargin{
    CGFloat value;
    if ([TTDeviceHelper isPadDevice]) {
        value = 14.f;
    } else if ([TTDeviceHelper is736Screen] || [TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]) {
        value = 16.f;
    } else {
        value = 14.0;
    }
    return value;
}

- (CGFloat)spaceBeweenNantants{
    CGFloat value;
    if ([TTDeviceHelper isPadDevice]) {
        value = 39.f;
    } else if ([TTDeviceHelper is736Screen] || [TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]) {
        value = 30.f;
    } else {
        value = 27.0;
    }
    return value;
}

- (CGFloat)riskLabelFontSize{
    CGFloat value;
    if ([TTDeviceHelper isPadDevice]) {
        value = 16.f;
    } else if ([TTDeviceHelper is736Screen] || [TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]) {
        value = 18.f;
    } else {
        value = 16.0;
    }
    return value;
}

@end

@implementation WDDetailNatantLayout (WDNatantLayout)

- (CGFloat) wd_topMargin{
    const CGFloat value = 15.0f;
    return value;
}

- (CGFloat) wd_bottomMargin{
    const CGFloat value = 16.0f;
    return value;
}

@end
