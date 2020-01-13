//
//  FHTopicTopBackView.m
//  FHHouseUGC
//
//  Created by 张元科 on 2019/8/23.
//

#import "FHTopicTopBackView.h"
#import "Masonry.h"
#import "UIColor+Theme.h"
#import "UIFont+House.h"
#import "TTDeviceHelper.h"
#import "FHCommonDefines.h"
#import <UIImageView+BDWebImage.h>

@interface FHTopicTopBackView()

@property(nonatomic, strong) UILabel *nameLabel;
@property(nonatomic, strong) UILabel *subtitleLabel;

@end

@implementation FHTopicTopBackView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.backgroundColor = [UIColor whiteColor];
    // _headerImageView
    _headerImageView = [[UIImageView alloc] init];
    _headerImageView.clipsToBounds = YES;
    _headerImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:_headerImageView];
    [_headerImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
    // 头图渐变
    UIImageView *imageTemp = [[UIImageView alloc] init];
    imageTemp.image = [UIImage imageNamed:@"fh_ugc_header_gradient"];
    imageTemp.backgroundColor = [UIColor clearColor];
    imageTemp.clipsToBounds = YES;
    [_headerImageView addSubview:imageTemp];
    [imageTemp mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.headerImageView);
    }];
    
    /* 左边头像 */
    self.avatar = [UIImageView new];
    self.avatar.backgroundColor = [UIColor themeGray3];
    self.avatar.clipsToBounds = YES;
    self.avatar.layer.cornerRadius = 4;
    [self addSubview:self.avatar];
    // 主标题标签
    self.nameLabel = [UILabel new];
    self.nameLabel.font = [UIFont themeFontMedium:16];
    self.nameLabel.textColor = [UIColor themeWhite];
    self.nameLabel.numberOfLines = 1;
    [self addSubview:self.nameLabel];
    // 副标题标签
    self.subtitleLabel = [UILabel new];
    self.subtitleLabel.font = [UIFont themeFontRegular:12];
    self.subtitleLabel.textColor = [UIColor themeWhite];
    self.subtitleLabel.numberOfLines = 1;
    [self addSubview:self.subtitleLabel];
    
    [self.avatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.width.height.mas_equalTo(50);
        make.bottom.mas_equalTo(self).offset(-15);
    }];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.avatar.mas_right).offset(8);
        make.top.mas_equalTo(self.avatar.mas_top).offset(3);
        make.height.mas_equalTo(22);
        make.right.mas_equalTo(self).offset(-20);
    }];
    [self.subtitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.nameLabel);
        make.top.mas_equalTo(self.nameLabel.mas_bottom).offset(5);
        make.height.mas_equalTo(17);
    }];
}

- (void)updateWithInfo:(FHTopicHeaderModel *)headerModel {
    if (headerModel && headerModel.forum) {
        [self.headerImageView bd_setImageWithURL:[NSURL URLWithString:headerModel.forum.bannerUrl]];
        [self.avatar bd_setImageWithURL:[NSURL URLWithString:headerModel.forum.avatarUrl] placeholder:[UIImage imageNamed:@"default_image"]];
        NSString *forumName = headerModel.forum.forumName;
        if (![headerModel.forum.forumName hasPrefix:@"#"]) {
            forumName = [NSString stringWithFormat:@"#%@#",headerModel.forum.forumName];
        }
        self.nameLabel.text = forumName;
        self.subtitleLabel.text = headerModel.forum.subDesc;
    }
}

@end
