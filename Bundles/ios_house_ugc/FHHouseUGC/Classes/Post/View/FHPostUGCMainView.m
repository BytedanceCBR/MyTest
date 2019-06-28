//
//  FHPostUGCMainView.m
//  FHHouseUGC
//
//  Created by 张元科 on 2019/5/27.
//

#import "FHPostUGCMainView.h"
#import <Masonry.h>
#import "UIColor+Theme.h"
#import "UIFont+House.h"

@interface FHPostUGCMainView ()

@property (nonatomic, strong)   UILabel       *nameLabel;
@property (nonatomic, strong)   UILabel       *valueLabel;
@property (nonatomic, strong)   UIView       *sepLine;

@end

@implementation FHPostUGCMainView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    _rightImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"fh_ugc_arrow_feed"]];
    [self addSubview:_rightImageView];
    _nameLabel = [[UILabel alloc] init];
    _nameLabel.text = @"小区：";
    _nameLabel.textColor = [UIColor themeGray1];
    _nameLabel.font = [UIFont themeFontRegular:16];
    _nameLabel.textAlignment = NSTextAlignmentLeft;
    [self addSubview:_nameLabel];
    _valueLabel = [[UILabel alloc] init];
    _valueLabel.text = @"选择想要发布帖子的小区圈";
    _valueLabel.textColor = [UIColor themeGray3];
    _valueLabel.font = [UIFont themeFontRegular:16];
    _valueLabel.textAlignment = NSTextAlignmentLeft;
    [self addSubview:_valueLabel];
    _sepLine = [[UIView alloc] init];
    _sepLine.backgroundColor = [UIColor themeGray6];
    [self addSubview:_sepLine];

    // 布局
    [self.rightImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self).offset(-20);
        make.centerY.mas_equalTo(self);
        make.height.width.mas_equalTo(16);
    }];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self);
        make.left.mas_equalTo(self).offset(20);
        make.height.mas_equalTo(22);
        make.width.mas_equalTo(48);
    }];
    [self.valueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self);
        make.left.mas_equalTo(self.nameLabel.mas_right).offset(0);
        make.height.mas_equalTo(22);
        make.right.mas_equalTo(self.rightImageView.mas_left).offset(-5);
    }];
    [self.sepLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-20);
        make.bottom.mas_equalTo(self);
        make.height.mas_equalTo(0.5);
    }];
}

- (void)setCommunityName:(NSString *)communityName {
    _communityName = communityName;
    if (communityName.length > 0) {
        self.valueLabel.text = communityName;
    } else {
        self.valueLabel.text = @"选择想要发布帖子的小区圈";
    }
}

- (BOOL)hasValidData {
    if (self.communityName.length > 0 && self.groupId.length > 0) {
        return YES;
    }
    return NO;
}

@end
