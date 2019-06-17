//
//  FHUGCMyInterestedSimpleCell.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/14.
//

#import "FHUGCMyInterestedCell.h"
#import "UIColor+Theme.h"
#import "UIFont+House.h"
#import <Masonry.h>
#import <UIImageView+BDWebImage.h>
#import "TTDeviceHelper.h"

#define iconWidth 48

@interface FHUGCMyInterestedCell ()

@property(nonatomic, strong) UIView *containerView;
@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UILabel *descLabel;
@property(nonatomic, strong) UILabel *sourceLabel;
@property(nonatomic, strong) UIImageView *icon;
@property(nonatomic, strong) UIButton *joinBtn;
@property(nonatomic, strong) UIView *bottomSepLine1;
@property(nonatomic, strong) UIView *bottomSepLine2;

@property(nonatomic, strong) UILabel *postDescLabel;
@property(nonatomic, strong) UIImageView *postIcon;
@property(nonatomic, strong) UIImageView *locationIcon;

@end

@implementation FHUGCMyInterestedCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self initUIs];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
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

- (void)refreshWithData:(id)data {
    if([data isKindOfClass:[NSString class]]){
        _titleLabel.text = data;
        _descLabel.text = @"88热帖·9221人";
        _sourceLabel.text = @"附近推荐";
        _postDescLabel.text = @"留在深圳，工作生活都很稳定，城市环境好，朋友圈子融洽，收入也还比较稳定";
        [self.icon bd_setImageWithURL:[NSURL URLWithString:@"http://p1.pstatp.com/thumb/fea7000014edee1159ac"] placeholder:nil];
//        [self.postIcon bd_setImageWithURL:[NSURL URLWithString:@"http://p1.pstatp.com/thumb/fea7000014edee1159ac"] placeholder:nil];
        
        
//        //当没有图片时
//        self.postIcon.hidden = YES;
//        [self.postDescLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
//            make.top.mas_equalTo(self.bottomSepLine1.mas_bottom).offset(15);
//            make.left.mas_equalTo(self.containerView).offset(10);
//            make.right.mas_equalTo(self.containerView).offset(-25);
//        }];
//
//        [self.bottomSepLine2 mas_remakeConstraints:^(MASConstraintMaker *make) {
//            make.top.mas_equalTo(self.postDescLabel.mas_bottom).offset(15);
//            make.left.mas_equalTo(self.containerView).offset(10);
//            make.right.mas_equalTo(self.containerView).offset(-10);
//            make.height.mas_equalTo(TTDeviceHelper.ssOnePixel);
//        }];
        
    }
}

- (void)initViews {
    self.contentView.backgroundColor = [UIColor themeGray7];
    
    self.containerView = [[UIView alloc] init];
    _containerView.backgroundColor = [UIColor whiteColor];
    _containerView.layer.masksToBounds = YES;
    _containerView.layer.cornerRadius = 4;
    [self.contentView addSubview:_containerView];
    
    self.icon = [[UIImageView alloc] init];
    _icon.contentMode = UIViewContentModeScaleAspectFill;
    _icon.layer.masksToBounds = YES;
    _icon.layer.cornerRadius = iconWidth/2;
    _icon.backgroundColor = [UIColor themeGray7];
    [self.containerView addSubview:_icon];
    
    self.titleLabel = [self LabelWithFont:[UIFont themeFontRegular:15] textColor:[UIColor themeGray1]];
    [self.containerView addSubview:_titleLabel];
    
    self.descLabel = [self LabelWithFont:[UIFont themeFontRegular:10] textColor:[UIColor themeGray3]];
    [self.containerView addSubview:_descLabel];
    
    self.sourceLabel = [self LabelWithFont:[UIFont themeFontRegular:10] textColor:[UIColor themeGray3]];
    [self.containerView addSubview:_sourceLabel];
    
    self.joinBtn = [[UIButton alloc] init];
    _joinBtn.layer.masksToBounds = YES;
    _joinBtn.layer.cornerRadius = 4;
    _joinBtn.layer.borderColor = [[UIColor themeRed1] CGColor];
    _joinBtn.layer.borderWidth = 0.5;
    [_joinBtn setTitle:@"关注" forState:UIControlStateNormal];
    [_joinBtn setTitleColor:[UIColor themeRed1] forState:UIControlStateNormal];
    _joinBtn.titleLabel.font = [UIFont themeFontRegular:12];
    [_joinBtn addTarget:self action:@selector(joinIn) forControlEvents:UIControlEventTouchUpInside];
    [self.containerView addSubview:_joinBtn];
    
    self.bottomSepLine1 = [[UIView alloc] init];
    _bottomSepLine1.backgroundColor = [UIColor themeGray6];
    [self.containerView addSubview:_bottomSepLine1];
    
    self.bottomSepLine2 = [[UIView alloc] init];
    _bottomSepLine2.backgroundColor = [UIColor themeGray6];
    [self.containerView addSubview:_bottomSepLine2];
    
    self.postDescLabel = [self LabelWithFont:[UIFont themeFontRegular:14] textColor:[UIColor themeGray1]];
    _postDescLabel.numberOfLines = 2;
    [self.containerView addSubview:_postDescLabel];
    
    self.postIcon = [[UIImageView alloc] init];
    _postIcon.contentMode = UIViewContentModeScaleAspectFill;
    _postIcon.layer.masksToBounds = YES;
    _postIcon.layer.cornerRadius = 4;
    _postIcon.backgroundColor = [UIColor themeGray7];
    [self.containerView addSubview:_postIcon];
    
    self.locationIcon = [[UIImageView alloc] init];
    _locationIcon.image = [UIImage imageNamed:@"fh_ugc_location"];
    [self.containerView addSubview:_locationIcon];
}

- (void)initConstraints {
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView).offset(15);
        make.left.mas_equalTo(self.contentView).offset(20);
        make.right.mas_equalTo(self.contentView).offset(-20);
        make.bottom.mas_equalTo(self.contentView);
    }];
    
    [self.icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.containerView).offset(10);
        make.left.mas_equalTo(self.containerView).offset(10);
        make.width.height.mas_equalTo(iconWidth);
    }];
    
    [self.joinBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.icon);
        make.right.mas_equalTo(self.containerView).offset(-10);
        make.width.mas_equalTo(58);
        make.height.mas_equalTo(24);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.containerView).offset(14);
        make.left.mas_equalTo(self.icon.mas_right).offset(10);
        make.right.mas_equalTo(self.joinBtn.mas_left).offset(-10);
        make.height.mas_equalTo(21);
    }];
    
    [self.descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(2);
        make.left.mas_equalTo(self.titleLabel);
        make.right.mas_equalTo(self.titleLabel);
        make.height.mas_equalTo(17);
    }];
    
    [self.bottomSepLine1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.icon.mas_bottom).offset(10);
        make.left.mas_equalTo(self.containerView).offset(10);
        make.right.mas_equalTo(self.containerView).offset(-10);
        make.height.mas_equalTo(TTDeviceHelper.ssOnePixel);
    }];
    
    [self.postIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.bottomSepLine1.mas_bottom).offset(10);
        make.right.mas_equalTo(self.containerView).offset(-10);
        make.width.height.mas_equalTo(50);
    }];
    
    [self.postDescLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.postIcon);
        make.left.mas_equalTo(self.containerView).offset(10);
        make.right.mas_equalTo(self.postIcon.mas_left).offset(-10);
        make.height.mas_equalTo(40);
    }];
    
    [self.bottomSepLine2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.postIcon.mas_bottom).offset(10);
        make.left.mas_equalTo(self.containerView).offset(10);
        make.right.mas_equalTo(self.containerView).offset(-10);
        make.height.mas_equalTo(TTDeviceHelper.ssOnePixel);
    }];
    
    [self.locationIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.sourceLabel);
        make.left.mas_equalTo(self.containerView).offset(10);
        make.width.height.mas_equalTo(8);
    }];

    [self.sourceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.bottomSepLine2.mas_bottom).offset(10);
        make.left.mas_equalTo(self.locationIcon.mas_right).offset(4);
        make.right.mas_equalTo(self.containerView).offset(-10);
        make.height.mas_equalTo(17);
    }];
}

- (UILabel *)LabelWithFont:(UIFont *)font textColor:(UIColor *)textColor {
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.textColor = textColor;
    return label;
}

- (void)joinIn {
    
}

@end
