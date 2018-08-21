//
//  TTAdCanvasUtils.m
//  Article
//
//  Created by yin on 2017/4/6.
//
//

#import "TTAdCanvasUtils.h"
#import "UIColor+TTThemeExtension.h"
#import "SSCommonLogic.h"

@implementation TTAdCanvasUtils

+ (UIColor*)colorWithCanvasRGBAString:(NSString *)string {
    if (isEmptyString(string)) {
        return nil;
    }
    NSMutableString* mString = [NSMutableString stringWithString:string];
    if ([mString hasPrefix:@"rgb("]&&[string hasSuffix:@")"]) {
        mString = [[[mString stringByReplacingOccurrencesOfString:@"rgb(" withString:@""] stringByReplacingOccurrencesOfString:@")" withString:@""] mutableCopy];
        NSArray* numberArray = [mString componentsSeparatedByString:@","];
        if (numberArray.count == 3) {
            if ([numberArray[0] floatValue]>=0 && [numberArray[1] floatValue]>=0 && [numberArray[2] floatValue]>=0) {
                return [UIColor colorWithRed:[numberArray[0] floatValue] green:[numberArray[1] floatValue] blue:[numberArray[2] floatValue] alpha:1];
            }
        }
    } else if ([mString hasPrefix:@"rgba("]&&[string hasSuffix:@")"]) {
        mString = [[[mString stringByReplacingOccurrencesOfString:@"rgba(" withString:@""] stringByReplacingOccurrencesOfString:@")" withString:@""] mutableCopy];
        NSArray* numberArray = [mString componentsSeparatedByString:@","];
        if (numberArray.count == 4) {
            if ([numberArray[0] floatValue]>=0 && [numberArray[1] floatValue]>=0 && [numberArray[2] floatValue]>=0 && [numberArray[3] floatValue]>=0) {
                return [UIColor colorWithRed:[numberArray[0] floatValue] green:[numberArray[1] floatValue] blue:[numberArray[2] floatValue] alpha:[numberArray[3] floatValue]];
            }
        }
    } else if ([mString hasPrefix:@"#"]) {
        return [UIColor colorWithHexString:mString];
    }
    return nil;
}

+ (BOOL)nativeEnable {
    return [SSCommonLogic isCanvasNativeEnable];
}

+ (BOOL)canvasEnable {
    if (![SSCommonLogic isCanvasEnable]) {
        return NO;
    }
    
    if ([TTDeviceHelper isPadDevice]) {
        return NO;
    }
    if ([TTDeviceHelper OSVersionNumber] < 8.0f) {
        return NO;
    }
    
    return YES;
}

+ (TTAdCanvasOpenStrategy)openStrategy {
    NSDictionary *dict = [SSCommonLogic canvasPreloadStrategy];
    static NSString const *strategy = @"category";
    if (dict[strategy]) {
        return [dict[strategy] integerValue];
    }
    return TTAdCanvasOpenStrategyAllResource;
}

@end

@implementation SSSimpleCache (TTAdImageModel)

- (NSData *)data4AdImageModel:(TTAdImageModel *)imageModel {
    if (!imageModel || ![imageModel isKindOfClass:[TTAdImageModel class]]) {
        return nil;
    }
    NSData *imageData = [[SSSimpleCache sharedCache] dataForUrl:imageModel.uri];
    if (!imageData) {
        imageData = [[SSSimpleCache sharedCache] dataForUrl:imageModel.url];
    }
    return imageData;
}

@end
