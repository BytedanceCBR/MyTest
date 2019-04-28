//
//  TTVProgressHudOfSlider.h
//  TTVPlayerPod
//
//  Created by lisa on 2019/4/22.
//

#import <UIKit/UIKit.h>
#import "TTVPlayerCustomViewDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface TTVProgressHudOfSlider : UIView<TTVProgressHudOfSliderProtocol>

@property (nonatomic, strong) UIView * progressContainer;

@property (nonatomic, strong) UIView *cancelContainer;
@property (nonatomic, strong) UIImageView *cancelView;
@property (nonatomic, strong) UILabel *cancelLabel;

@end

NS_ASSUME_NONNULL_END
