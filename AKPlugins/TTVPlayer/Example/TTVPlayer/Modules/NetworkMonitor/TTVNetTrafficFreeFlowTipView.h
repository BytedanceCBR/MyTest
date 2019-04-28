//
//  TTVNetTrafficFreeFlowTipView.h
//  Article
//
//  Created by lijun.thinker on 2017/7/10.
//

#import <UIKit/UIKit.h>

@protocol TTVNetTrafficFreeFlowTipView <NSObject>

@property (nonatomic, copy) dispatch_block_t continuePlayBlock;
@property (nonatomic, copy) NSString *tipText;

- (void)refreshTipLabel:(CGFloat)mergin;
- (void)refreshTipLabelText:(NSString *)tipLabelText;

@optional
// 不一定会有获取流量
@property (nonatomic, copy) dispatch_block_t subscribeBlock;
@property (nonatomic, assign) BOOL isSubscribe;

@end


@interface TTVNetTrafficFreeFlowTipView : UIView<TTVNetTrafficFreeFlowTipView>
- (instancetype)initWithFrame:(CGRect)frame tipText:(NSString *)text isSubscribe:(BOOL)isSubscribe;
@property (nonatomic, copy) dispatch_block_t continuePlayBlock;
@property (nonatomic, copy) dispatch_block_t subscribeBlock;
@property (nonatomic, assign) BOOL isSubscribe;
@property (nonatomic, copy) NSString *tipText;
@end
