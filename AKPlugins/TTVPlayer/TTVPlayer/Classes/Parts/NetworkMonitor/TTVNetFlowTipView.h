//
//  TTVNetFlowTipView.h
//  Article
//
//  Created by lijun.thinker on 2017/7/10.
//

#import <UIKit/UIKit.h>
#import "TTVPlayerCustomViewDelegate.h"


@interface TTVNetFlowTipView : UIView<TTVFlowTipViewProtocol>
- (instancetype)initWithFrame:(CGRect)frame tipText:(NSString *)text;
@property (nonatomic, copy) dispatch_block_t continuePlayBlock;
@end
