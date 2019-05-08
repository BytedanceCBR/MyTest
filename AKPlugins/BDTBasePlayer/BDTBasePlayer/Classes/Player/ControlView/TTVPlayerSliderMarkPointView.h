//
//  TTVPlayerSliderMarkPointView.h
//  Article
//
//  Created by lijun.thinker on 2017/8/13.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    TTVPlayerSliderMarkPointStyleNormal,
    TTVPlayerSliderMarkPointStyleMini,
} TTVPlayerSliderMarkPointStyle;
@class TTVPlayerStateStore;
@interface TTVPlayerSliderMarkPointView: UIView
- (instancetype)initWithFrame:(CGRect)frame style:(TTVPlayerSliderMarkPointStyle)style;
@property (nonatomic, strong) TTVPlayerStateStore *playerStateStore;

- (void)updateFrame;
@end
