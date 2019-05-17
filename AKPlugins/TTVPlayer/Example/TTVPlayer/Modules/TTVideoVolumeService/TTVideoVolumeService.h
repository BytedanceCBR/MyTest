//
//  TTVideoVolumeService.h
//  Article
//
//  Created by liuty on 2017/1/9.
//
//

#import <Foundation/Foundation.h>

@interface TTVideoVolumeService : NSObject

//volume changed callback
@property (nonatomic, strong) void (^volumeDidChange)(float volume, BOOL changedBySystemVolumeButton, BOOL shouldShowTips);

//return current system volume, in [0, 1]
- (CGFloat)currentVolume;

//value in [0, 1]
- (void)updateVolumeValue:(CGFloat)value;
- (void)updateVolumeValueWithoutTipsShow:(CGFloat)value;

- (void)showAnimated:(BOOL)animated;
- (void)dismissAnimated:(BOOL)animated;

- (void)dismiss; // dismiss animted

/**
 旋转音量浮层

 @param rotation 旋转矩阵
 */
- (void)rotate:(CGAffineTransform)rotation;

@end
