//
//  FHUGCPureTitleCell.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/3.
//

#import "FHUGCMultiImageCell.h"
#import <UIImageView+BDWebImage.h>
#import "FHUGCCellHeaderView.h"
#import "FHUGCCellUserInfoView.h"
#import "FHUGCCellBottomView.h"


@interface FHUGCMultiImageCell ()

@property(nonatomic ,strong) UILabel *contentLabel;
@property(nonatomic ,strong) UIImageView *singleImageView;

@property(nonatomic ,strong) FHUGCCellUserInfoView *userInfoView;
@property(nonatomic ,strong) FHUGCCellBottomView *bottomView;
@property(nonatomic ,strong) UIView *bottomSepView;

@end

@implementation FHUGCMultiImageCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self initUIs];
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initUIs];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)initUIs {
    [self initViews];
    [self initConstraints];
}

- (void)initViews {
    self.userInfoView = [[FHUGCCellUserInfoView alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:_userInfoView];
    
    self.contentLabel = [self LabelWithFont:[UIFont themeFontRegular:16] textColor:[UIColor themeGray1]];
    _contentLabel.numberOfLines = 2;
    [self.contentView addSubview:_contentLabel];
    
    self.singleImageView = [[UIImageView alloc] init];
    _singleImageView.clipsToBounds = YES;
    _singleImageView.contentMode = UIViewContentModeScaleAspectFill;
    _singleImageView.backgroundColor = [UIColor themeGray7];
    _singleImageView.layer.masksToBounds = YES;
    _singleImageView.layer.cornerRadius = 4;
    [self.contentView addSubview:_singleImageView];
    
    self.bottomView = [[FHUGCCellBottomView alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:_bottomView];
    
    self.bottomSepView = [[UIView alloc] init];
    _bottomSepView.backgroundColor = [UIColor themeGray7];
    [self.contentView addSubview:_bottomSepView];
}

- (void)initConstraints {
    [self.userInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView).offset(20);
        make.left.right.mas_equalTo(self.contentView);
        make.height.mas_equalTo(40);
    }];
    
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.userInfoView.mas_bottom).offset(10);
        make.left.mas_equalTo(self.contentView).offset(20);
        make.right.mas_equalTo(self.contentView).offset(-20);
    }];
    
    [self.singleImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentLabel.mas_bottom).offset(10);
        make.left.mas_equalTo(self.contentView).offset(20);
        make.right.mas_equalTo(self.contentView).offset(-20);
        make.height.mas_equalTo(self.singleImageView.mas_width).multipliedBy(251.0f/355.0f);
    }];
    
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.singleImageView.mas_bottom).offset(10);
        make.left.right.mas_equalTo(self.contentView);
        make.height.mas_equalTo(30);
    }];
    
    [self.bottomSepView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.bottomView.mas_bottom).offset(20);
        make.bottom.left.right.mas_equalTo(self.contentView);
        make.height.mas_equalTo(5);
    }];
}

- (UILabel *)LabelWithFont:(UIFont *)font textColor:(UIColor *)textColor {
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.textColor = textColor;
    return label;
}

- (void)refreshWithData:(id)data {
    FHFeedContentModel *model = (FHFeedContentModel *)data;
    self.contentLabel.text = model.title;
    NSString *imageUrl = model.middleImage.url;
    
    CGFloat width = [model.middleImage.width floatValue];
    CGFloat height = [model.middleImage.height floatValue];
    [self.singleImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(self.singleImageView.mas_width).multipliedBy(height/width);
    }];
    
    [self.singleImageView bd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholder:nil];
    
    //设置userInfo
    self.userInfoView.userName.text = @"汤唯";
    self.userInfoView.descLabel.text = @"今天 14:20";
    //    [self.icon bd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholder:[UIImage imageNamed:@"fh_mine_avatar"]];
    
    //设置底部
    self.bottomView.position.text = @"左家庄";
    [self.bottomView.likeBtn setTitle:@"178" forState:UIControlStateNormal];
    [self.bottomView.commentBtn setTitle:@"24" forState:UIControlStateNormal];
}

@end
