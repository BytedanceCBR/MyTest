//
//  FHDetailHeaderView.h
//  FHHouseDetail
//
//  Created by 张元科 on 2019/2/14.
//

#import <UIKit/UIKit.h>
#import "FHDetailBaseCell.h"
#import "FHBubbleView.h"
NS_ASSUME_NONNULL_BEGIN

// 使用的时候布局需要设置高度：>= 46
@interface FHDetailHeaderView : UIButton

@property (nonatomic, strong)   UILabel       *label;

@property (nonatomic, strong)   UILabel       *subTitleLabel;

@property (nonatomic, strong)   UILabel       *loadMore;

@property (nonatomic, assign)   BOOL       isShowLoadMore;
@property (nonatomic, strong) UIButton *showTipButton;
@property (nonatomic ,strong) FHBubbleView *tipView;
@property(nonatomic, strong) NSDictionary *tracerDict;
-(void)setSubTitleWithTitle:(NSString *)subTitle;
- (void)removeSubTitleWithTitle;
@end

NS_ASSUME_NONNULL_END
