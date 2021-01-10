//
//  FHNewHouseDetailReleatorCollectionCell.m
//  Pods
//
//  Created by bytedance on 2020/9/9.
//

#import "FHNewHouseDetailReleatorCollectionCell.h"
#import <FHHouseBase/FHHouseRealtorAvatarView.h>
#import <ByteDanceKit/ByteDanceKit.h>

@interface FHNewHouseDetailReleatorCollectionCell ()

@property (nonatomic, strong) FHHouseRealtorAvatarView *avatorView;

@property (nonatomic, strong) UIButton *callBtn;
@property (nonatomic, strong) UIButton *imBtn;

@property (nonatomic, strong) UILabel *nameLabel;

@property (nonatomic, strong) UILabel *agencyLabel; //经济公司
@property (nonatomic, strong) UIImageView *agencyBac;

@property (nonatomic, strong) UILabel *scoreLabel; //服务分

@property (nonatomic, strong) UILabel *agencyDescriptionLabel;//公司介绍
@property (nonatomic, strong) UIImageView *agencyDescriptionBac;

@end

@implementation FHNewHouseDetailReleatorCollectionCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.avatorView = [[FHHouseRealtorAvatarView alloc] init];
        self.avatorView.avatarImageView.layer.borderColor = [UIColor themeGray6].CGColor;
        self.avatorView.avatarImageView.layer.borderWidth = [UIDevice btd_onePixel];
        [self.contentView addSubview:self.avatorView];
        [self.avatorView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.width.mas_equalTo(50);
            make.left.mas_equalTo(14);
            make.centerY.mas_equalTo(self.contentView);
        }];
        
        self.nameLabel = [[UILabel alloc] init];
        self.nameLabel.textColor = [UIColor themeGray1];
        self.nameLabel.font = [UIFont themeFontMedium:16];
        self.nameLabel.textAlignment = NSTextAlignmentLeft;
        [self.nameLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [self.contentView addSubview:self.nameLabel];
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.avatorView.mas_right).mas_offset(10);
            make.top.mas_equalTo(12);
        }];
        
        self.scoreLabel = [[UILabel alloc] init];
        [self.contentView addSubview:self.scoreLabel];
        [self.scoreLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.nameLabel.mas_left);
            make.top.mas_equalTo(self.nameLabel.mas_bottom).mas_offset(8);
        }];
        
        __weak typeof(self) weakSelf = self;
        CGFloat phoneButtonWidth = 36;
        self.callBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.callBtn.imageView.contentMode = UIViewContentModeCenter;
        [self.callBtn setImage:[UIImage imageNamed:@"detail_agent_phone_icon"] forState:UIControlStateNormal];
        self.callBtn.backgroundColor = [UIColor colorWithHexString:@"fff6ee"];
        self.callBtn.layer.masksToBounds = YES;
        self.callBtn.layer.cornerRadius = phoneButtonWidth/2;
        [self.callBtn btd_addActionBlockForTouchUpInside:^(__kindof UIButton * _Nonnull sender) {
            if (weakSelf.phoneClickBlock) {
                weakSelf.phoneClickBlock(weakSelf.currentData);
            }
        }];
        [self.contentView addSubview:self.callBtn];
        [self.callBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(phoneButtonWidth);
            make.right.mas_equalTo(-12);
            make.centerY.mas_equalTo(self.avatorView.mas_centerY);
        }];
        
        self.imBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.imBtn.imageView.contentMode = UIViewContentModeCenter;
        [self.imBtn setImage:[UIImage imageNamed:@"detail_agent_im_icon"] forState:UIControlStateNormal];
        self.imBtn.backgroundColor = [UIColor colorWithHexString:@"fff6ee"];
        self.imBtn.layer.masksToBounds = YES;
        self.imBtn.layer.cornerRadius = phoneButtonWidth/2;
        [self.imBtn btd_addActionBlockForTouchUpInside:^(__kindof UIButton * _Nonnull sender) {
            if (weakSelf.imClickBlock) {
                weakSelf.imClickBlock(weakSelf.currentData);
            }
        }];
        [self.contentView addSubview:self.imBtn];
        [self.imBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(phoneButtonWidth);
            make.right.mas_equalTo(self.callBtn.mas_left).offset(-16);
            make.centerY.mas_equalTo(self.avatorView.mas_centerY);
        }];
        
        self.agencyBac = [[UIImageView alloc] init];
        self.agencyBac.image = [UIImage imageNamed:@"realtor_name_bac"];
        self.agencyBac.layer.borderWidth = 0.5;
        self.agencyBac.layer.borderColor = [[UIColor colorWithHexString:@"#d6d6d6"] CGColor];
        self.agencyBac.layer.cornerRadius = 2.0;
        self.agencyBac.layer.masksToBounds = YES;
        [self.contentView addSubview:self.agencyBac];
        [self.agencyBac mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.nameLabel);
            make.height.mas_equalTo(16);
            make.left.mas_equalTo(self.nameLabel.mas_right).offset(4);
            make.right.mas_lessThanOrEqualTo(self.imBtn.mas_left).offset(-10);
        }];
        
        self.agencyLabel = [[UILabel alloc] init];
        self.agencyLabel.textColor = [UIColor colorWithHexString:@"#929292"];
        self.agencyLabel.font = [UIFont themeFontMedium:10];
        self.agencyLabel.textAlignment = NSTextAlignmentCenter;
        [self.agencyBac addSubview:self.agencyLabel];
        [self.agencyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(3, 5, 3, 5));
        }];
               
        self.agencyDescriptionBac = [[UIImageView alloc] init];
//        self.agencyDescriptionBac.backgroundColor = [UIColor colorWithHexString:@"#fefaf4"];
        self.agencyDescriptionBac.image = [UIImage fh_gradientImageWithColors:@[(id)[UIColor colorWithHexString:@"#eef4fe"].CGColor, (id)[UIColor colorWithHexString:@"#f5f7fc"].CGColor, (id)[UIColor colorWithHexString:@"#f5f7fc"].CGColor] startPoint:CGPointMake(0, 0.5) endPoint:CGPointMake(1, 0.5) size:CGSizeMake(100, 18) usedInClass:NSStringFromClass([self class])];
        self.agencyDescriptionBac.layer.cornerRadius = 2.0;
        self.agencyDescriptionBac.layer.masksToBounds = YES;
        [self.contentView addSubview:self.agencyDescriptionBac];
        [self.agencyDescriptionBac mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.nameLabel.mas_left);
            make.right.mas_lessThanOrEqualTo(self.imBtn.mas_left);
            make.height.mas_equalTo(18);
            make.top.mas_equalTo(self.scoreLabel.mas_bottom).mas_offset(28);
        }];
        
        self.agencyDescriptionLabel = [[UILabel alloc] init];
        self.agencyDescriptionLabel.font = [UIFont themeFontRegular:10];
        self.agencyDescriptionLabel.backgroundColor = [UIColor clearColor];
        self.agencyDescriptionLabel.textColor = [UIColor colorWithHexString:@"#7286b5"];
        self.agencyDescriptionLabel.textAlignment = NSTextAlignmentCenter;
        [self.agencyDescriptionLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [self.agencyDescriptionBac addSubview:self.agencyDescriptionLabel];
        [self.agencyDescriptionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(3, 10, 3, 10));
        }];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (CGRectGetWidth(self.bounds) > 0) {
        FHDetailContactModel *model = (FHDetailContactModel *)self.currentData;
        CGFloat agencyWidth = [model.agencyName btd_widthWithFont:self.agencyLabel.font height:self.agencyLabel.frame.size.height];
        if (!self.agencyBac.hidden && self.agencyBac.frame.size.width > 0 && agencyWidth > (CGRectGetWidth(self.agencyBac.bounds) - 10)) {
            self.agencyBac.hidden = YES;
        }
    }
}

- (void)bindViewModel:(id)viewModel {
    [self refreshWithData:viewModel];
}

- (void)refreshWithData:(id)data {
    if (self.currentData == data || ![data isKindOfClass:[FHDetailContactModel class]]) {
        return;
    }
    self.currentData = data;
    FHDetailContactModel *model = (FHDetailContactModel *)data;
    
    self.nameLabel.text = model.realtorName;
    self.agencyLabel.text = model.agencyName;
    self.agencyBac.hidden = !model.agencyName.length;
    [self.avatorView updateAvatarWithModel:model];
    
    if (model.agencyDescription.length && model.realtorScoreDisplay.length) {
        //3行全有
        [self.nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.avatorView.mas_right).mas_offset(10);
            make.height.mas_equalTo(16);
            make.bottom.mas_equalTo(self.scoreLabel.mas_top).offset(-8);
        }];
        [self.scoreLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.avatorView);
            make.left.mas_equalTo(self.nameLabel);
        }];
        [self.agencyDescriptionBac mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.nameLabel.mas_left);
            make.right.mas_lessThanOrEqualTo(self.imBtn.mas_left).mas_offset(-10);
            make.height.mas_equalTo(18);
            make.top.mas_equalTo(self.scoreLabel.mas_bottom).mas_offset(8);
        }];
    } else if (model.agencyDescription.length || model.realtorScoreDisplay.length) {
        //2行
        CGFloat topMargin = 0;
        if (model.agencyDescription.length) {
            topMargin = 16;
        } else {
            topMargin = 19;
        }
        [self.nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.avatorView.mas_right).mas_offset(10);
            make.top.mas_equalTo(topMargin);
            make.height.mas_equalTo(16);
        }];
        
        if (model.agencyDescription.length) {
            [self.agencyDescriptionBac mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(self.nameLabel.mas_left);
                make.right.mas_lessThanOrEqualTo(self.imBtn.mas_left).mas_offset(-10);
                make.height.mas_equalTo(18);
                make.top.mas_equalTo(self.nameLabel.mas_bottom).mas_offset(8);
            }];
        }
    } else {
        //1行 namelabel居中
        [self.nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.avatorView.mas_right).mas_offset(10);
            make.centerY.mas_equalTo(self.avatorView);
            make.height.mas_equalTo(16);
        }];
    }
    if (model.agencyDescription.length > 0) {
        self.agencyDescriptionBac.hidden = NO;
    } else {
        self.agencyDescriptionBac.hidden = YES;
    }
    self.agencyDescriptionLabel.text = model.agencyDescription;
    if (model.realtorScoreDisplay.length > 0) {
        self.scoreLabel.hidden = NO;
        
        NSString *scoreStringValue = model.realtorScoreDisplay.copy;
        if ([scoreStringValue rangeOfString:@"分"].length > 0) {
            scoreStringValue = [scoreStringValue stringByReplacingOccurrencesOfString:@"分" withString:@""];
        }
        NSMutableAttributedString *scoreString = [[NSMutableAttributedString alloc] initWithString:scoreStringValue ?: @"" attributes:@{NSForegroundColorAttributeName: [UIColor colorWithHexString:@"FE5500"], NSFontAttributeName: [UIFont themeFontSemibold:12]}];
        [scoreString appendAttributedString:[[NSAttributedString alloc] initWithString:@" 服务分" attributes:@{NSForegroundColorAttributeName: [UIColor themeGray1], NSFontAttributeName: [UIFont themeFontRegular:12]}]];
        self.scoreLabel.attributedText = scoreString.copy;
    } else {
        self.scoreLabel.hidden = NO;
    }
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (NSString *)elementType {
    return @"new_detail_related";
}

@end

//@implementation FHNewHouseDetailReleatorCellModel
//@end
