//
//  TTVNetTrafficFreeFlowTipViewNew.h
//  Article
//
//  Created by lijun.thinker on 2017/7/10.
//

#import <UIKit/UIKit.h>
#import "TTVPlayerCustomViewDelegate.h"


@interface TTVNetTrafficFreeFlowTipViewNew : UIView<TTVFlowTipViewProtocol>
- (instancetype)initWithFrame:(CGRect)frame tipText:(NSString *)text isSubscribe:(BOOL)isSubscribe;
@property (nonatomic, copy) dispatch_block_t continuePlayBlock;
@property (nonatomic, copy) dispatch_block_t subscribeBlock;
@property (nonatomic, assign) BOOL isSubscribe;
@end
