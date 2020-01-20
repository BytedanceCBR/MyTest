//
//  BDTFPSBar.h
//  Article
//
//  Created by pei yun on 2018/4/8.
//

#if INHOUSE

#import <UIKit/UIKit.h>

@protocol METFPSBarDelegate <NSObject>

- (void)FPSBarDidReceiveTimeConsumeInterval:(NSTimeInterval)time;

@end

@interface BDTFPSBar : UIWindow

@property (nonatomic, weak) id<METFPSBarDelegate> fpsDelegate;

/**
 *  默认0.5秒刷新一次
 */
@property (nonatomic, readwrite) NSTimeInterval refreshInterval;

/**
 *  默认平均1秒钟的帧数
 */
@property (nonatomic, readwrite) NSUInteger avgCount;

/**
 *  默认default_timeConsumeLimit
 */
@property (nonatomic, readwrite) NSTimeInterval timeConsumeLimit;

+ (instancetype)sharedInstance;

- (void)setHidden:(BOOL)hidden;

@end

#endif
