//
//  FHDetailHeaderView.m
//  FHHouseDetail
//
//  Created by 张元科 on 2019/2/14.
//

#import "FHDetailHeaderView.h"
#import "Masonry.h"
#import "UIFont+House.h"
#import "UIImageView+BDWebImage.h"
#import "FHCommonDefines.h"
#import "UILabel+House.h"
#import "UIColor+Theme.h"
#import "FHHouseDetailViewController.h"
#import "FHHouseOldDetailViewModel.h"
#import "UIView+BTDAdditions.h"

@interface FHDetailHeaderView ()
@property (nonatomic, strong)   UIImageView       *arrowsImg;
@end

@implementation FHDetailHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    _isShowLoadMore = NO;
    _label = [UILabel createLabel:@"" textColor:@"" fontSize:20];
    _label.textColor = [UIColor themeGray1];
    _label.font = [UIFont themeFontMedium:20];
    [self addSubview:_label];
    
    _subTitleLabel = [UILabel createLabel:@"" textColor:@"" fontSize:14];
    _subTitleLabel.textColor = [UIColor themeGray2];
    _subTitleLabel.font = [UIFont themeFontRegular:14];
    _subTitleLabel.hidden = YES;
    [self addSubview:_subTitleLabel];
    
    _loadMore = [UILabel createLabel:@"查看更多" textColor:@"" fontSize:14];
    _loadMore.textColor = [UIColor themeGray3];
    _loadMore.textAlignment = NSTextAlignmentRight;
    _loadMore.hidden = YES;
    [self addSubview:_loadMore];
    
    _arrowsImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrowicon-feed-4"]];
    _arrowsImg.hidden = YES;
    [self addSubview:_arrowsImg];
    
    _showTipButton = [[UIButton alloc] init];
    _showTipButton.hidden = YES;
    _showTipButton.btd_hitTestEdgeInsets = UIEdgeInsetsMake(-7, -7, -7, -7);
    [_showTipButton setBackgroundImage:[UIImage imageNamed:@"ic-question-line-normal"] forState:UIControlStateNormal];
    [_showTipButton setBackgroundImage:[UIImage imageNamed:@"ic-question-line-normal"] forState:UIControlStateHighlighted];
    [self addSubview:_showTipButton];
    [_showTipButton addTarget:self action:@selector(showTipButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(self.loadMore.mas_left).offset(-10);
        make.top.mas_equalTo(20);
        make.height.mas_equalTo(26);
    }];
    
    
    [self.arrowsImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self).offset(-12);
        make.height.width.mas_equalTo(20);
        make.centerY.mas_equalTo(self.label.mas_centerY);
    }];
    [self.loadMore mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.label.mas_centerY);
        make.height.mas_equalTo(14);
        make.width.mas_equalTo(80);
        make.right.mas_equalTo(self.arrowsImg.mas_left);
    }];
    [self.showTipButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(16);
        make.left.equalTo(self).offset(120);
        make.centerY.equalTo(self.label);
    }];
    
    
}

- (void)setIsShowLoadMore:(BOOL)isShowLoadMore {
    _isShowLoadMore = isShowLoadMore;
//    _loadMore.hidden = !isShowLoadMore;
    _arrowsImg.hidden = !isShowLoadMore;
}

- (void)setSubTitleWithTitle:(NSString *)subTitle{ //一定要先设置Label的内容再设置
    _label.textColor = [UIColor themeBlack];
    if (subTitle.length > 0) {
        _subTitleLabel.text = [NSString stringWithFormat:@"| %@",subTitle];
        _subTitleLabel.hidden = NO;
    }
    [_label sizeToFit];
    CGSize itemSize = [_label sizeThatFits:CGSizeMake(200, 23)];
    [_label mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(16);
        make.width.mas_equalTo(itemSize.width);
        make.top.mas_equalTo(25);
        make.height.mas_equalTo(23);
    }];
    [_subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_label.mas_right).offset(6);
        make.height.mas_equalTo(16);
        make.bottom.mas_equalTo(_label).offset(-2);
        make.right.mas_equalTo(self).offset(-12);
    }];
}

- (void)removeSubTitleWithTitle { //移除setSubTitleWithTitle的影响
    _label.textColor = _label.textColor = [UIColor themeGray1];
    _subTitleLabel.hidden = YES;
    [self.label mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(self.loadMore.mas_left).offset(-10);
        make.top.mas_equalTo(20);
        make.height.mas_equalTo(26);
    }];
}

- (void)showTipButtonClick {
    if(self.detailVC){
        if([self.detailVC.viewModel isKindOfClass:[FHHouseOldDetailViewModel class]]) {
            FHHouseOldDetailViewModel *detailVM = (FHHouseOldDetailViewModel *) self.detailVC.viewModel;
            if(self.surveyTipView == nil) {
                self.surveyTipView = [[FHSurveyBubbleView alloc] initWithTitle:detailVM.surveyTipName font:[UIFont themeFontRegular:12]];
                self.surveyTipView.maxWidth = 264;
                self.surveyTipView.labelInsets = UIEdgeInsetsMake(4, 10, 6, 10);
                self.surveyTipView.arrowOffset = 55;
                self.surveyTipView.hidden = YES;
                [self.detailVC.view addSubview:self.surveyTipView];
                [self.detailVC.view bringSubviewToFront:self.surveyTipView];
                detailVM.surveyTipView = self.surveyTipView;
            }
            if(self.surveyTipView.hidden) {
                self.surveyTipView.frame = [self.surveyTipView calcFrameWithSubView:self.showTipButton toView:self.detailVC.view];
                [self.surveyTipView updateView];
                [detailVM showSurveyTip];
                [self addClickOptionsLog];
            } else {
                [detailVM hiddenSurveyTip];
            }
        }
    }
}

//埋点
- (void)addClickOptionsLog {
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"page_type"] = [self.detailVC.viewModel pageTypeString];
    params[@"element_type"] = self.tracerDict[@"element_type"];
    params[@"click_position"] = @"question_mark_explain";
    params[@"event_tracking_id"] = @"104154";
    TRACK_EVENT(@"click_options", params);
}

@end
