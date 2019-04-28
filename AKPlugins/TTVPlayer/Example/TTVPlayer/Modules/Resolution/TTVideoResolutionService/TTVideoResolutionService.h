//
//  TTVideoResolutionService.h
//  Article
//
//  Created by liuty on 2017/1/11.
//
//

#import <Foundation/Foundation.h>
#import <TTVideoEngineModelDef.h>

@interface TTVideoResolutionService : NSObject

+ (TTVideoEngineResolutionType)defaultResolutionType;

+ (void)setDefaultResolutionType:(TTVideoEngineResolutionType)type;

+ (NSString *)stringForType:(TTVideoEngineResolutionType)type;

+ (CGFloat)progressWhenResolutionChanged;

+ (void)saveProgressWhenResolutionChanged:(CGFloat)progress;

+ (BOOL)autoModeEnable;

+ (void)setAutoModeEnable:(BOOL)enable;

@end
