//
//  FHPostUGCMainView.m
//  FHHouseUGC
//
//  Created by 张元科 on 2019/5/27.
//

#import "FHPostUGCMainView.h"
#import "Masonry.h"
#import "UIColor+Theme.h"
#import "UIFont+House.h"
#import <FHHouseBase/UIImage+FIconFont.h>

@interface FHPostUGCMainView ()

@property (nonatomic, strong)   UILabel       *nameLabel;
@property (nonatomic, strong)   UILabel       *valueLabel;
@property (nonatomic, strong)   UIView       *sepLine;
@property (nonatomic, assign)   FHPostUGCMainViewType type;

@end

@implementation FHPostUGCMainView

- (instancetype)initWithFrame:(CGRect)frame type:(FHPostUGCMainViewType)type
{
    self = [super initWithFrame:frame];
    if (self) {
        self.type = type;
        [self setupUI];
    }
    return self;
}

- (NSString *)hintString {
    switch (self.type) {
        case FHPostUGCMainViewType_Post:
            return @"选择想要发布帖子的圈子";
            break;
        case FHPostUGCMainViewType_Wenda:
            return @"请选择要发布提问的圈子";
            break;
        default:
            return @"";
            break;
    }
}

- (void)setupUI {
    _followed = YES;
    _rightImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"fh_ugc_arrow_feed"]];
    [self addSubview:_rightImageView];
    _nameLabel = [[UILabel alloc] init];
    _nameLabel.text = @"发布到：";
    _nameLabel.textColor = [UIColor themeGray1];
    _nameLabel.font = [UIFont themeFontRegular:16];
    _nameLabel.textAlignment = NSTextAlignmentLeft;
    [self addSubview:_nameLabel];
    _valueLabel = [[UILabel alloc] init];
    _valueLabel.text = [self hintString];
    _valueLabel.textColor = [UIColor themeGray3];
    _valueLabel.font = [UIFont themeFontRegular:16];
    _valueLabel.textAlignment = NSTextAlignmentLeft;
    [self addSubview:_valueLabel];
    _sepLine = [[UIView alloc] init];
    _sepLine.backgroundColor = [UIColor themeGray6];
    [self addSubview:_sepLine];

    // 布局
    [self.rightImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-20);
        make.centerY.equalTo(self);
        make.height.width.mas_equalTo(16);
    }];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.left.equalTo(self).offset(20);
        make.height.mas_equalTo(22);
        make.width.mas_equalTo(66);
    }];
    [self.valueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.left.equalTo(self.nameLabel.mas_right).offset(0);
        make.height.mas_equalTo(22);
        make.right.equalTo(self.rightImageView.mas_left).offset(-5);
    }];
    [self.sepLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-20);
        make.bottom.equalTo(self);
        make.height.mas_equalTo(0.5);
    }];
}

- (void)setCommunityName:(NSString *)communityName {
    _communityName = communityName;
    if (communityName.length > 0) {
        self.nameLabel.text = @"发布到：";
        self.valueLabel.text = communityName;
        self.valueLabel.textColor = [UIColor themeGray1];
        [self.nameLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(66);
        }];
    } else {
        self.nameLabel.text = @"发布到：";
        self.valueLabel.text = [self hintString];
        self.valueLabel.textColor = [UIColor themeGray3];
        [self.nameLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(66);
        }];
    }
}

- (BOOL)hasValidData {
    if (self.communityName.length > 0 && self.groupId.length > 0) {
        return YES;
    }
    return NO;
}

@end
