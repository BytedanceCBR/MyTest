//
//  TTVPlayerControlViewFactory.h
//  ScreenRotate
//
//  Created by lisa on 2019/3/26.
//  Copyright © 2019 zuiye. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "TTVPlayerDefine.h"
#import "TTVPlayerCustomViewDelegate.h"

NS_ASSUME_NONNULL_BEGIN

/**
 外部可自定义内置view 的创建工厂
 */
@interface TTVPlayerControlViewFactory : NSObject<TTVPlayerCustomViewDelegate>

+ (instancetype _Nonnull)sharedInstance;

@property (nonatomic, weak) NSObject<TTVPlayerCustomViewDelegate> *customViewDelegate;

- (UIView<TTVButtonProtocol> *)createButtonForKey:(TTVPlayerPartControlKey)key;
- (UIView<TTVToggledButtonProtocol> *)createToggledButtonForKey:(TTVPlayerPartControlKey)key;
- (UILabel *)createLabelForKey:(TTVPlayerPartControlKey)key;

- (UIView <TTVPlayerLoadingViewProtocol> *)createLoadingView;
- (UIView <TTVPlayerErrorViewProtocol> *)createPlayerErrorFinishView;
- (UIView <TTVFlowTipViewProtocol> *)createCellularNetTipView;


- (UIView<TTVSliderControlProtocol> *)createSliderView;
- (UIView<TTVProgressHudOfSliderProtocol> *)createSliderHUDView;
- (UIView<TTVProgressViewOfSliderProtocol> *)createProgressView;


- (TTVTouchIgoringView<TTVBarProtocol> *)createTopNavBar;
- (TTVTouchIgoringView<TTVBarProtocol> *)createBottomToolBar;

/// 当没有指定明确 type 时
- (UIView *)createOtherViewForKey:(TTVPlayerPartControlKey)key;

@end

NS_ASSUME_NONNULL_END
