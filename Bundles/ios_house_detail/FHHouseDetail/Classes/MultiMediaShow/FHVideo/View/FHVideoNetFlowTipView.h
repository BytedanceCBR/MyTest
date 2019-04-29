//
//  FHVideoNetFlowTipView.h
//  FHHouseDetail
//
//  Created by 谢思铭 on 2019/4/29.
//

#import <UIKit/UIKit.h>
#import "TTVPlayerCustomViewDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHVideoNetFlowTipView : UIView<TTVFlowTipViewProtocol>
- (instancetype)initWithFrame:(CGRect)frame tipText:(NSString *)text isSubscribe:(BOOL)isSubscribe;
@property (nonatomic, copy) dispatch_block_t continuePlayBlock;
@property (nonatomic, copy) dispatch_block_t subscribeBlock;
@property (nonatomic, assign) BOOL isSubscribe;
@end

NS_ASSUME_NONNULL_END


