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
@property (nonatomic, strong)   UIView        *tagView;
@property (nonatomic, strong)   UILabel       *tagLabel;
@property (nonatomic, strong)   UIButton      *tagCloseBtn;
@property (nonatomic, strong)   UIView        *sepLine;
@property (nonatomic, assign)   FHPostUGCMainViewType type;

@end

@implementation FHPostUGCMainView

- (UIView *)tagView {
    if(!_tagView) {
        _tagView = [UIView new];
        _tagView.backgroundColor = [UIColor themeOrange2];
        _tagView.layer.cornerRadius = 16;
        _tagView.layer.masksToBounds = YES;
        
        [_tagView addSubview:self.tagLabel];
        [_tagView addSubview:self.tagCloseBtn];
        
        [self.tagLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_tagView).offset(8);
            make.centerY.equalTo(_tagView);
            make.height.mas_equalTo(22);
        }];
        
        [self.tagCloseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_tagLabel);
            make.left.equalTo(self.tagLabel.mas_right).offset(3);
            make.right.equalTo(_tagView).offset(-8);
            make.width.height.mas_offset(16);
        }];
        
        _tagView.hidden = YES;
    }
    return _tagView;
}

- (UILabel *)tagLabel {
    if(!_tagLabel) {
        _tagLabel = [UILabel new];
        _tagLabel.textColor = [UIColor themeOrange1];
        _tagLabel.font = [UIFont themeFontRegular:16];
        _tagLabel.backgroundColor = [UIColor themeOrange2];
        _tagLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _tagLabel;
}

- (UIButton *)tagCloseBtn {
    if(!_tagCloseBtn) {
        _tagCloseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_tagCloseBtn setImage:ICON_FONT_IMG(16, @"\U0000e673", [UIColor themeOrange1]) forState:UIControlStateNormal];
        [_tagCloseBtn setImage:ICON_FONT_IMG(16, @"\U0000e673", [UIColor themeOrange1]) forState:UIControlStateHighlighted];
        [_tagCloseBtn addTarget:self action:@selector(closeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        _tagCloseBtn.layer.cornerRadius = 8;
        _tagCloseBtn.layer.masksToBounds = YES;
        _tagCloseBtn.backgroundColor = [UIColor themeWhite];
    }
    return _tagCloseBtn;
}

- (void)closeButtonAction:(UIButton *)sender {
    if([self.delegate respondsToSelector:@selector(tagCloseButtonClicked)]) {
        [self.delegate tagCloseButtonClicked];
    }
}

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
    
    // 标签视图
    [self addSubview:self.tagView];
    
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
    
    [self.tagView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.nameLabel.mas_right).offset(20);
        make.centerY.equalTo(self.nameLabel);
        make.right.lessThanOrEqualTo(self.rightImageView.mas_left).offset(-5);
        make.height.mas_equalTo(32);
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
    
    self.tagLabel.text = communityName;
    self.valueLabel.hidden = communityName.length > 0 ;
    self.tagView.hidden = !self.valueLabel.hidden;
    
}

- (BOOL)hasValidData {
    if (self.communityName.length > 0 && self.groupId.length > 0) {
        return YES;
    }
    return NO;
}

@end
