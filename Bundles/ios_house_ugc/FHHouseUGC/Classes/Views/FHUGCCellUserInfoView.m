//
//  FHUGCCellUserInfoView.m
//  AKCommentPlugin
//
//  Created by 谢思铭 on 2019/6/4.
//

#import "FHUGCCellUserInfoView.h"
#import <Masonry.h>
#import "UIColor+Theme.h"
#import "UIFont+House.h"
#import "FHFeedOperationView.h"

@implementation FHUGCCellUserInfoView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initViews];
        [self initConstraints];
    }
    return self;
}

- (void)initViews {
    self.icon = [[UIImageView alloc] init];
    _icon.backgroundColor = [UIColor themeGray7];
    _icon.contentMode = UIViewContentModeScaleAspectFill;
    _icon.layer.masksToBounds = YES;
    _icon.layer.cornerRadius = 20;
    [self addSubview:_icon];
    
    self.userName = [self LabelWithFont:[UIFont themeFontMedium:16] textColor:[UIColor themeGray1]];
    [self addSubview:_userName];
    
    self.descLabel = [self LabelWithFont:[UIFont themeFontRegular:12] textColor:[UIColor themeGray3]];
    [self addSubview:_descLabel];
    
    self.moreBtn = [[UIButton alloc] init];
    [_moreBtn setImage:[UIImage imageNamed:@"fh_ugc_icon_more"] forState:UIControlStateNormal];
    [_moreBtn addTarget:self action:@selector(moreOperation) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_moreBtn];
}

- (void)initConstraints {
    [self.icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self);
        make.left.mas_equalTo(self).offset(20);
        make.width.height.mas_equalTo(40);
    }];
    
    [self.moreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self);
        make.right.mas_equalTo(self).offset(-20);
        make.width.height.mas_equalTo(20);
    }];
    
    [self.userName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.icon);
        make.left.mas_equalTo(self.icon.mas_right).offset(10);
        make.right.mas_equalTo(self.moreBtn.mas_left).offset(-20);
        make.height.mas_equalTo(22);
    }];
    
    [self.descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.icon);
        make.left.mas_equalTo(self.icon.mas_right).offset(10);
        make.right.mas_equalTo(self.moreBtn.mas_left).offset(-20);
        make.height.mas_equalTo(17);
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
    
    NSMutableArray *keywords = [NSMutableArray array];
    NSDictionary *operation1 = @{
                                @"id": @"7:",
                                @"is_selected": @(0),
                                @"name": @"举报"
                                };
    
//    NSDictionary *operation2 = @{
//                                @"id": @"7:",
//                                @"is_selected": @(0),
//                                @"name": @"举报"
//                                };
    
    [keywords addObject:operation1];
//    [keywords addObject:operation2];
    
//    viewModel.keywords = keywords;
    viewModel.keywords = @[@"1"];
//    viewModel.commnads = self.orderedData.raw_ad.dislikeCommands;
//    viewModel.groupID = [NSString stringWithFormat:@"%lld", self.orderedData.card.uniqueID];
//    viewModel.categoryID = self.orderedData.categoryID;
//    viewModel.adID = self.orderedData.raw_ad.ad_id;
//    viewModel.logExtra = self.orderedData.log_extra;
    [dislikeView refreshWithModel:viewModel];
    CGPoint point = _moreBtn.center;
    [dislikeView showAtPoint:point
                    fromView:_moreBtn
             didDislikeBlock:^(FHFeedOperationView * _Nonnull view) {
//                 [self exploreDislikeViewOKBtnClicked:view];
             }];
}

@end
