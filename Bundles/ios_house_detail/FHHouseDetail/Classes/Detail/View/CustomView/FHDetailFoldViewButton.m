//
//  FHDetailFoldViewButton.m
//  FHHouseDetail
//
//  Created by 张元科 on 2019/2/14.
//

#import "FHDetailFoldViewButton.h"
#import <Masonry.h>
#import "UIFont+House.h"
#import <UIImageView+BDWebImage.h>
#import "FHCommonDefines.h"
#import "FHDetailOldModel.h"
#import "FHURLSettings.h"
#import "TTRoute.h"
#import "FHDetailHeaderView.h"
#import "FHExtendHotAreaButton.h"
#import "UIColor+Theme.h"

@interface FHDetailFoldViewButton ()

@property (nonatomic, strong)   UIImageView       *iconView;
@property (nonatomic, strong)   UILabel       *keyLabel;
@property (nonatomic, copy)     NSString       *upText;
@property (nonatomic, copy)     NSString       *downText;

@end

@implementation FHDetailFoldViewButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (instancetype)initWithDownText:(NSString *)down upText:(NSString *)up isFold:(BOOL)isFold
{
    self = [self initWithFrame:CGRectZero];
    if (self) {
        self.upText = up;
        self.downText = down;
        self.isFold = isFold;
    }
    return self;
}

- (void)setupUI {
    _upText = @"收起";
    _downText = @"展开";
    _iconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrowicon-feed-2"]];
    [self addSubview:_iconView];
    _keyLabel = [[UILabel alloc] init];
    _keyLabel.text = @"";
    _keyLabel.textColor = [UIColor themeRed1];
    _keyLabel.font = [UIFont themeFontRegular:14];
    [self addSubview:_keyLabel];
    
    [self.keyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self).offset(-11);
        make.top.mas_equalTo(self).offset(20);
        make.height.mas_equalTo(18);
    }];
    [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.keyLabel.mas_right).offset(4);
        make.centerY.mas_equalTo(self.keyLabel);
        make.height.width.mas_equalTo(18);
    }];
}

- (void)setIsFold:(BOOL)isFold {
    _isFold = isFold;
    if (isFold) {
        _keyLabel.text = self.downText;
        _iconView.image = [UIImage imageNamed:@"arrowicon-feed-3"];
    } else {
        _keyLabel.text = self.upText;
        _iconView.image = [UIImage imageNamed:@"arrowicon-feed-2"];
    }
}

@end
