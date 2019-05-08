//
//  TTVOrientationMonitor.h
//  Article
//
//  Created by panxiang on 2017/6/2.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class TTVPlayerStateStore;
@protocol TTVOrientationMonitorDelegate <NSObject>

- (void)changeOrientationToFull:(BOOL)isFull;
- (void)changeRotationOfLandscape;
- (BOOL)videoPlayerCanRotate;

@end
@interface TTVOrientationMonitor : NSObject
@property (nonatomic, weak) TTVPlayerStateStore *playerStateStore;
@property (nonatomic, weak) NSObject <TTVOrientationMonitorDelegate> *delegate;
@property (nonatomic, weak) UIView *rotateView;
@end


@interface TTVOrientationStatus : NSObject
- (BOOL)shouldRotateByCommonState;
- (BOOL)shouldRotateByPlayState;
@property (nonatomic, strong) TTVPlayerStateStore *playerStateStore;
@property (nonatomic, weak) UIView *rotateView;
@end
