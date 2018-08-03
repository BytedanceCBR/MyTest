//
//  TTVVideoDetailNatantPGCAuthorView.h
//  Article
//
//  Created by lishuangyang on 2017/5/23.
//
//

#import "SSThemed.h"
#import "TTVVideoDetailNatantPGCViewModel.h"
@class TTVVideoDetailNatantPGCViewController;

@protocol TTVVideoDetailNatantPGCViewDelegate <NSObject>

- (void) relayoutRecommendViewFrame: (BOOL) isSpread isClickArrowImage:(BOOL) clickArrawImage;
- (void) updateRecommendView: (BOOL) isSpread isShowRedPacket:(BOOL) showRedPacket ;

@end

@interface TTVVideoDetailNatantPGCAuthorView : SSThemedView

@property (nonatomic, strong) SSThemedView       *bottomLine;
@property (nonatomic, strong) TTVVideoDetailNatantPGCViewModel *viewModel;
@property (nonatomic, weak) id<TTVVideoDetailNatantPGCViewDelegate> delegate;
@property (nonatomic, assign) BOOL isSpread;                  // 辅助arrowImage 的展开收起动作

- (instancetype)initWithInfoModel: (TTVVideoDetailNatantPGCModel *) PGCInfo andWidth:(float) width;

- (void)subScribButtonMovement;
- (void)stopIndicatorAnimatingShowRedPacket:(BOOL)showRedPacket;
- (void)arrowButtonPressed;

@end
