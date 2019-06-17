//
//  FHUGCCellBottomView.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/4.
//

#import "FHArticleCellBottomView.h"
#import <Masonry.h>
#import "UIColor+Theme.h"
#import "UIFont+House.h"
#import "FHFeedOperationView.h"
#import "UIButton+TTAdditions.h"

@interface FHArticleCellBottomView ()

@property(nonatomic ,strong) UIView *positionView;

@end

@implementation FHArticleCellBottomView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initViews];
        [self initConstraints];
    }
    return self;
}

- (void)initViews {
    
    self.positionView = [[UIView alloc] init];
    _positionView.backgroundColor = [[UIColor themeRed3] colorWithAlphaComponent:0.1];
    _positionView.layer.masksToBounds= YES;
    _positionView.layer.cornerRadius = 4;
    [self addSubview:_positionView];
    
    self.position = [self LabelWithFont:[UIFont themeFontRegular:13] textColor:[UIColor themeRed3]];
    [_position sizeToFit];
    [_position setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [_positionView addSubview:_position];
    
    self.descLabel = [self LabelWithFont:[UIFont themeFontRegular:12] textColor:[UIColor themeGray4]];
    [self addSubview:_descLabel];
    
    self.moreBtn = [[UIButton alloc] init];
    [_moreBtn setImage:[UIImage imageNamed:@"fh_ugc_icon_more"] forState:UIControlStateNormal];
    [_moreBtn addTarget:self action:@selector(moreOperation) forControlEvents:UIControlEventTouchUpInside];
    _moreBtn.hitTestEdgeInsets = UIEdgeInsetsMake(-5, -5, -5, -5);
    [self addSubview:_moreBtn];
}

- (void)initConstraints {
    [self.positionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self).offset(20);
        make.top.bottom.mas_equalTo(self);
    }];
    
    [self.position mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.positionView).offset(6);
        make.right.mas_equalTo(self.positionView).offset(-6);
        make.centerY.mas_equalTo(self.positionView);
        make.height.mas_equalTo(18);
    }];
    
    [self.descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.positionView.mas_right).offset(6);
        make.centerY.mas_equalTo(self);
        make.right.mas_equalTo(self.moreBtn.mas_left).offset(-20);
    }];
    
    [self.moreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(16);
        make.centerY.mas_equalTo(self);
        make.right.mas_equalTo(self).offset(-18);
    }];
}

- (UILabel *)LabelWithFont:(UIFont *)font textColor:(UIColor *)textColor {
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.textColor = textColor;
    return label;
}

- (void)moreOperation {
    FHFeedOperationView *dislikeView = [[FHFeedOperationView alloc] init];
    FHFeedOperationViewModel *viewModel = [[FHFeedOperationViewModel alloc] init];
    
    if(self.cellModel){
        viewModel.groupID = self.cellModel.groupId;
        viewModel.categoryID = self.cellModel.categoryId;
    }
    
    [dislikeView refreshWithModel:viewModel];
    CGPoint point = _moreBtn.center;
    [dislikeView showAtPoint:point
                    fromView:_moreBtn
             didDislikeBlock:^(FHFeedOperationView * _Nonnull view) {
                 [self handleItemselected:view];
             }];
}

- (void)handleItemselected:(FHFeedOperationView *) view {
    if(view.selectdWord.type == FHFeedOperationWordTypeReport){
        //举报
        if(self.deleteCellBlock){
            self.deleteCellBlock();
        }
    }else if(view.selectdWord.type == FHFeedOperationWordTypeDelete){
        //调用删除接口
        if(self.deleteCellBlock){
            self.deleteCellBlock();
        }
    }
}

@end
