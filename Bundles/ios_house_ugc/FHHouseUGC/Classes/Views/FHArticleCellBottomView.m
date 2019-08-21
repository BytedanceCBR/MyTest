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
#import "FHCommunityFeedListController.h"
#import "FHUserTracker.h"

@interface FHArticleCellBottomView ()

@property(nonatomic ,strong) UIView *bottomSepView;
@property(nonatomic ,strong) UIImageView *positionImageView;

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
    
    self.positionImageView = [[UIImageView alloc] init];
    _positionImageView.image = [UIImage imageNamed:@"fh_ugc_community_icon"];
    [self.positionView addSubview:_positionImageView];
    
    self.position = [self LabelWithFont:[UIFont themeFontRegular:13] textColor:[UIColor themeRed3]];
    [_position sizeToFit];
    [_position setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [_position setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [_positionView addSubview:_position];
    
    self.descLabel = [self LabelWithFont:[UIFont themeFontRegular:12] textColor:[UIColor themeGray4]];
    [self addSubview:_descLabel];
    
    self.moreBtn = [[UIButton alloc] init];
    [_moreBtn setImage:[UIImage imageNamed:@"fh_ugc_icon_more"] forState:UIControlStateNormal];
    [_moreBtn addTarget:self action:@selector(moreOperation) forControlEvents:UIControlEventTouchUpInside];
    _moreBtn.hitTestEdgeInsets = UIEdgeInsetsMake(-5, -5, -5, -5);
    [self addSubview:_moreBtn];
    
    self.bottomSepView = [[UIView alloc] init];
    _bottomSepView.backgroundColor = [UIColor themeGray7];
    [self addSubview:_bottomSepView];
}

- (FHUGCFeedGuideView *)guideView {
    if(!_guideView){
        _guideView = [[FHUGCFeedGuideView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 42)];
        [self addSubview:_guideView];
    }
    return _guideView;
}

- (void)initConstraints {
    [self.positionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self).offset(20);
        make.top.mas_equalTo(self);
        make.height.mas_equalTo(24);
    }];
    
    [self.positionImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.positionView).offset(6);
        make.centerY.mas_equalTo(self.positionView);
        make.width.height.mas_equalTo(12);
    }];
    
    [self.position mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.positionImageView.mas_right).offset(2);
        make.right.mas_equalTo(self.positionView).offset(-6);
        make.centerY.mas_equalTo(self.positionView);
        make.height.mas_equalTo(18);
    }];
    
    [self.descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.positionView.mas_right).offset(6);
        make.centerY.mas_equalTo(self.positionView);
        make.right.mas_equalTo(self.moreBtn.mas_left).offset(-20);
    }];
    
    [self.moreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(20);
        make.centerY.mas_equalTo(self.positionView);
        make.right.mas_equalTo(self).offset(-18);
    }];
    
    [self.bottomSepView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.positionView.mas_bottom).offset(10);
        make.left.right.mas_equalTo(self);
        make.height.mas_equalTo(5);
    }];
}

- (UILabel *)LabelWithFont:(UIFont *)font textColor:(UIColor *)textColor {
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.textColor = textColor;
    return label;
}

- (void)setCellModel:(FHFeedUGCCellModel *)cellModel {
    _cellModel = cellModel;
    //设置是否显示引导
    if(cellModel.isInsertGuideCell){
        self.guideView.hidden = NO;
        [self.guideView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.positionView.mas_bottom);
            make.left.right.mas_equalTo(self);
            make.height.mas_equalTo(42);
        }];
    }else{
        self.guideView.hidden = YES;
    }
}

- (void)showPositionView:(BOOL)isShow {
    self.positionView.hidden = !isShow;
    if(isShow){
        [self.descLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.positionView.mas_right).offset(6);
            make.centerY.mas_equalTo(self.positionView);
            make.right.mas_equalTo(self.moreBtn.mas_left).offset(-20);
        }];
    }else{
        [self.descLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self).offset(20);
            make.centerY.mas_equalTo(self.positionView);
            make.right.mas_equalTo(self.moreBtn.mas_left).offset(-20);
        }];
    }
}

- (void)moreOperation {
    __weak typeof(self) wself = self;
    
    [self trackClickOptions];
    FHFeedOperationView *dislikeView = [[FHFeedOperationView alloc] init];
    FHFeedOperationViewModel *viewModel = [[FHFeedOperationViewModel alloc] init];
    
    dislikeView.dislikeTracerBlock = ^{
        [wself trackClickReport];
    };
    
    if(self.cellModel){
        viewModel.groupID = self.cellModel.groupId;
        viewModel.categoryID = self.cellModel.categoryId;
    }
    
    [dislikeView refreshWithModel:viewModel];
    CGPoint point = _moreBtn.center;
    [dislikeView showAtPoint:point
                    fromView:_moreBtn
             didDislikeBlock:^(FHFeedOperationView * _Nonnull view) {
                 [wself handleItemselected:view];
             }];
}

//文章只处理举报，没有删除
- (void)handleItemselected:(FHFeedOperationView *) view {
    if(view.selectdWord.type == FHFeedOperationWordTypeReport){
        //举报
        if(self.deleteCellBlock){
            self.deleteCellBlock();
        }
    }
}

#pragma mark - 埋点

- (void)trackClickOptions {
    NSMutableDictionary *dict = [self.cellModel.tracerDic mutableCopy];
    dict[@"click_position"] = @"feed_more";
    TRACK_EVENT(@"click_options", dict);
}

- (void)trackClickReport {
    NSMutableDictionary *dict = [self.cellModel.tracerDic mutableCopy];
    dict[@"click_position"] = @"feed_report";
    TRACK_EVENT(@"click_report", dict);
}

@end
