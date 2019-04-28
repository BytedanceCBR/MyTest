//
//  TTVSeekPart.h
//  TTVPlayer
//
//  Created by lisa on 2019/1/17.
//

#import <Foundation/Foundation.h>
#import "TTVPlayerContextNew.h"
#import "TTVReduxKit.h"
#import "TTVPlayerPartProtocol.h"

// UI 
#import "TTVPlayerCustomViewDelegate.h"


NS_ASSUME_NONNULL_BEGIN

@interface TTVSeekPart : NSObject<TTVPlayerContextNew, TTVReduxStateObserver, TTVPlayerPartProtocol>

// UI
@property (nonatomic, strong) UIView<TTVSliderControlProtocol> *slider;
@property (nonatomic, strong) UIView<TTVProgressHudOfSliderProtocol>   *hud;
@property (nonatomic, strong) UILabel                   *currentTimeLabel;          // 当前时间
@property (nonatomic, strong) UILabel                   *totalTimeLabel;            // 总时间
@property (nonatomic, strong) UILabel                   *currentAndTotoalTimeLabel; // 当前时间 / 总时间 总和
/// 沉浸态下的进度条,没有进度点
@property (nonatomic, strong) UIView<TTVProgressViewOfSliderProtocol> * immersiveSlider;

@end

NS_ASSUME_NONNULL_END
