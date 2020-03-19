//
//  FHUGCCellAttachCardView.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2020/3/19.
//

#import "FHUGCCellAttachCardView.h"
#import "Masonry.h"
#import "UIColor+Theme.h"
#import "UIFont+House.h"
#import "FHCommonApi.h"
#import "ToastManager.h"
#import "TTReachability.h"
#import "TTAccountManager.h"
#import "UIButton+TTAdditions.h"
#import "FHUserTracker.h"
#import "UIImageView+BDWebImage.h"
#import "TTRoute.h"
#import "JSONAdditions.h"
#import "FHUGCCellHelper.h"

@interface FHUGCCellAttachCardView ()

@property(nonatomic ,strong) UIImageView *iconView;
@property(nonatomic ,strong) UILabel *titleLabel;
@property(nonatomic ,strong) UILabel *descLabel;
@property(nonatomic ,strong) UIView *spLine;
@property(nonatomic ,strong) UIButton *button;

@end

@implementation FHUGCCellAttachCardView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initViews];
        [self initConstraints];
    }
    return self;
}

- (void)initViews {
    self.backgroundColor = [UIColor themeGray7];
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 4;
    
    //这里有个坑，加上手势会导致@不能点击
    self.userInteractionEnabled = YES;
    UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToDetail)];
    [self addGestureRecognizer:singleTap];
    
    self.iconView = [[UIImageView alloc] init];
    _iconView.backgroundColor = [UIColor whiteColor];
    _iconView.contentMode = UIViewContentModeScaleAspectFill;
    _iconView.layer.cornerRadius = 4;
    _iconView.layer.masksToBounds = YES;
    _iconView.clipsToBounds = YES;
    [self addSubview:_iconView];
    
    self.titleLabel = [self LabelWithFont:[UIFont themeFontRegular:16] textColor:[UIColor themeGray1]];
    [self addSubview:_titleLabel];
    
    self.descLabel = [self LabelWithFont:[UIFont themeFontRegular:12] textColor:[UIColor themeGray3]];
    [self addSubview:_descLabel];
    
    self.spLine = [[UIView alloc] init];
    _spLine.backgroundColor = [UIColor colorWithHexString:@"cccccc"];
    [self addSubview:_spLine];
    
    self.button = [[UIButton alloc] init];
    [_button setTitleColor:[UIColor themeRed1] forState:UIControlStateNormal];
    _button.titleLabel.font = [UIFont themeFontRegular:12];
    [_button setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [_button addTarget:self action:@selector(buttonClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_button];
}

- (void)initConstraints {
    [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self).offset(10);
        make.centerY.mas_equalTo(self);
        make.width.height.mas_equalTo(40);
    }];
    
    [self.button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self).offset(-15);
        make.top.bottom.mas_equalTo(self);
        make.width.mas_lessThanOrEqualTo(50);
    }];
    
    [self.spLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.button.mas_left).offset(-9.5);
        make.centerY.mas_equalTo(self);
        make.width.mas_equalTo(1);
        make.height.mas_equalTo(17);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.iconView.mas_right).offset(8);
        make.right.mas_equalTo(self.spLine.mas_left).offset(-5);
        make.top.mas_equalTo(self).offset(9);
        make.height.mas_equalTo(22);
    }];
    
    [self.descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.titleLabel.mas_left);
        make.right.mas_equalTo(self.titleLabel.mas_right);
        make.top.mas_equalTo(self.titleLabel.mas_bottom);
        make.height.mas_equalTo(17);
    }];
}

- (void)refreshWithdata:(id)data {
    if([data isKindOfClass:[FHFeedUGCCellModel class]]){
        FHFeedUGCCellModel *cellModel = (FHFeedUGCCellModel *)data;
        self.cellModel = cellModel;
        
        [self.iconView bd_setImageWithURL:[NSURL URLWithString:cellModel.attachCardInfo.coverImage.url] placeholder:nil];
        self.titleLabel.text = cellModel.attachCardInfo.title;
        self.descLabel.text = cellModel.attachCardInfo.desc;
        
        NSString *buttonTitle = cellModel.attachCardInfo.button.name;
        if(buttonTitle.length > 0 && cellModel.attachCardInfo.button.schema.length > 0){
            self.button.hidden = NO;
            self.spLine.hidden = NO;
            if(buttonTitle.length > 4){
                buttonTitle = [buttonTitle substringToIndex:4];
            }
            [_button setTitle:buttonTitle forState:UIControlStateNormal];
            [self.button mas_updateConstraints:^(MASConstraintMaker *make) {
                make.width.mas_lessThanOrEqualTo(50);
            }];
            [self.spLine mas_updateConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(self.button.mas_left).offset(-9.5);
            }];
        }else{
            self.button.hidden = YES;
            self.spLine.hidden = YES;
            [self.button mas_updateConstraints:^(MASConstraintMaker *make) {
                make.width.mas_lessThanOrEqualTo(0);
            }];
            [self.spLine mas_updateConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(self.button.mas_left).offset(0);
            }];
        }
    }
}

- (void)goToDetail {
    NSString *routeUrl = self.cellModel.attachCardInfo.schema;
    if(routeUrl.length > 0){
        NSURL *openUrl = [NSURL URLWithString:routeUrl];
        [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:nil];
    }
}

- (void)buttonClick {
    NSString *routeUrl = self.cellModel.attachCardInfo.button.schema;
    if(routeUrl.length > 0){
        NSURL *openUrl = [NSURL URLWithString:routeUrl];
        [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:nil];
    }
}

- (UILabel *)LabelWithFont:(UIFont *)font textColor:(UIColor *)textColor {
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.textColor = textColor;
    return label;
}

@end
