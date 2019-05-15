//
//  TTVideoBrightnessService.h
//  Article
//
//  Created by 赵晶鑫 on 27/08/2017.
//
//

#import <Foundation/Foundation.h>

@interface TTVideoBrightnessService : NSObject

//default NO
@property (nonatomic) BOOL enableBrightnessView;

//volume changed callback
@property (nonatomic, strong) void (^brightnessDidChange)(float brightness);

//return current system volume, in [0, 1]
- (CGFloat)currentBrightness;

//value in [0, 1]
- (void)updateBrightnessValue:(CGFloat)value;

@end
