//
//  FHUGCPureTitleCell.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/3.
//

#import "FHUGCSingleImageCell.h"
#import <UIImageView+BDWebImage.h>


@interface FHUGCSingleImageCell ()

@property(nonatomic ,strong) UIImageView *icon;
@property(nonatomic ,strong) UILabel *userName;
@property(nonatomic ,strong) UILabel *descLabel;
@property(nonatomic ,strong) UILabel *contentLabel;
@property(nonatomic ,strong) UIImageView *singleImageView;
@property(nonatomic ,strong) UIButton *moreBtn;
@property(nonatomic ,strong) UILabel *position;
@property(nonatomic ,strong) UIButton *likeBtn;
@property(nonatomic ,strong) UIButton *commentBtn;

@end

@implementation FHUGCSingleImageCell

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
    
    self.icon = [[UIImageView alloc] init];
    _icon.backgroundColor = [UIColor themeGray7];
    _icon.contentMode = UIViewContentModeScaleAspectFill;
    _icon.layer.masksToBounds = YES;
    _icon.layer.cornerRadius = 20;
    [self.contentView addSubview:_icon];
    
    self.userName = [self LabelWithFont:[UIFont themeFontMedium:16] textColor:[UIColor themeGray1]];
    [self.contentView addSubview:_userName];
    
    self.descLabel = [self LabelWithFont:[UIFont themeFontRegular:12] textColor:[UIColor themeGray3]];
    [self.contentView addSubview:_descLabel];
    
    self.moreBtn = [[UIButton alloc] init];
    [_moreBtn setImage:[UIImage imageNamed:@"fh_ugc_icon_more"] forState:UIControlStateNormal];
//    [_evaluateBtn addTarget:self action:@selector(evaluate) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_moreBtn];
    
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
}

- (void)initConstraints {
    [self.icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView).offset(20);
        make.left.mas_equalTo(self.contentView).offset(20);
        make.width.height.mas_equalTo(40);
    }];
    
    [self.userName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.icon);
        make.left.mas_equalTo(self.icon.mas_right).offset(10);
        make.right.mas_equalTo(self.contentView).offset(-20);
        make.height.mas_equalTo(22);
    }];
    
    [self.descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.icon);
        make.left.mas_equalTo(self.icon.mas_right).offset(10);
        make.right.mas_equalTo(self.contentView).offset(-20);
        make.height.mas_equalTo(17);
    }];
    
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.icon.mas_bottom).offset(10);
        make.left.mas_equalTo(self.contentView).offset(20);
        make.right.mas_equalTo(self.contentView).offset(-20);
    }];
    
    [self.singleImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentLabel.mas_bottom).offset(10);
        make.left.mas_equalTo(self.contentView).offset(20);
        make.right.mas_equalTo(self.contentView).offset(-20);
        make.height.mas_equalTo(self.singleImageView.mas_width).multipliedBy(251.0f/355.0f);
        make.bottom.mas_equalTo(self.contentView).offset(-10);
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
    
    self.userName.text = @"汤唯";
    self.descLabel.text = @"今天 14:20";
    
//    [self.icon bd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholder:[UIImage imageNamed:@"fh_mine_avatar"]];
}

@end
