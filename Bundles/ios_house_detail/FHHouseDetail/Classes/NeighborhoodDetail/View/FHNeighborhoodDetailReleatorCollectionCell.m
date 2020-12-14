//
//  FHNeighborhoodDetailReleatorCollectionCell.m
//  FHHouseDetail
//
//  Created by luowentao on 2020/10/13.
//

#import "FHNeighborhoodDetailReleatorCollectionCell.h"
#import <FHHouseBase/FHRealtorAvatarView.h>
#import <ByteDanceKit/ByteDanceKit.h>
#import "FHDetailAgentItemView.h"
#import <BDWebImage/BDWebImage.h>

@interface FHNeighborhoodDetailReleatorCollectionCell ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) FHRealtorAvatarView *avatorView;

@property (nonatomic, strong) UIButton *callBtn;
@property (nonatomic, strong) UIButton *imBtn;

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIButton *licenseButton; //认证按钮

@property (nonatomic, strong) UILabel *agencyLabel; //经济公司
@property (nonatomic, strong) UIImageView *agencyBac;

@property (nonatomic, strong) UILabel *scoreLabel; //服务分

@property (nonatomic, strong) UICollectionView *tagsView;
@end

@implementation FHNeighborhoodDetailReleatorCollectionCell

+ (CGSize)cellSizeWithData:(id)data width:(CGFloat)width {
    if (![data isKindOfClass:[FHDetailContactModel class] ]) {
        return CGSizeZero;
    }
    FHDetailContactModel *obj = (FHDetailContactModel *)data;
    CGFloat vHeight = 74;
    if (obj.realtorScoreDisplay.length > 0 && obj.realtorTags.count > 0) {
        vHeight = 86;
    }
    return CGSizeMake(width, vHeight);
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.avatorView = [[FHRealtorAvatarView alloc] init];
        [self.contentView addSubview:self.avatorView];
        [self.avatorView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.width.mas_equalTo(50);
            make.left.mas_equalTo(16);
            make.top.mas_equalTo(12);
        }];
        
        self.nameLabel = [[UILabel alloc] init];
        self.nameLabel.textColor = [UIColor themeGray1];
        self.nameLabel.font = [UIFont themeFontMedium:16];
        self.nameLabel.textAlignment = NSTextAlignmentLeft;
        [self.nameLabel setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];  //这个好神奇！！！
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
            make.right.mas_equalTo(-16);
            make.centerY.mas_equalTo(self.nameLabel.mas_centerY);
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
            make.centerY.mas_equalTo(self.callBtn.mas_centerY);
        }];

        self.licenseButton = [[UIButton alloc] init];
        [self.licenseButton setImage:[UIImage imageNamed:@"detail_contact"] forState:UIControlStateNormal];
        [self.licenseButton btd_addActionBlockForTouchUpInside:^(__kindof UIButton * _Nonnull sender) {
            if (weakSelf.licenseClickBlock) {
                weakSelf.licenseClickBlock(weakSelf.currentData);
            }
        }];
        [self.contentView addSubview:self.licenseButton];
        [self.licenseButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.nameLabel.mas_right).offset(4);
            make.size.mas_equalTo(CGSizeMake(18, 16));
            make.centerY.mas_equalTo(self.nameLabel);
            make.right.mas_lessThanOrEqualTo(self.imBtn.mas_left).offset(-10);
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
       
        self.tagsView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:[[FHDetailAgentItemTagsFlowLayout alloc] init]];
        self.tagsView.scrollEnabled = NO;
        self.tagsView.backgroundColor = [UIColor whiteColor];
        self.tagsView.delegate = self;
        self.tagsView.dataSource = self;
        [self.contentView addSubview:self.tagsView];
        [self.tagsView registerClass:[FHDetailAgentItemTagsViewCell class] forCellWithReuseIdentifier:[FHDetailAgentItemTagsViewCell reuseIdentifier]];
        [self.tagsView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.nameLabel.mas_left);
            make.top.mas_equalTo(self.nameLabel.mas_bottom).mas_offset(28);
            make.right.mas_lessThanOrEqualTo(-10);
            make.height.mas_equalTo(18);
        }];
       
    }
    return self;
}
- (void)bindViewModel:(id)viewModel {
    [self refreshWithData:viewModel];
}

- (void)refreshWithData:(id)data {
    if (self.currentData == data || ![data isKindOfClass:[FHDetailContactModel class] ]) {
        return;
    }
    self.currentData = data;
    
    FHDetailContactModel *model = (FHDetailContactModel *)data;
    
    self.nameLabel.text = model.realtorName;
    self.agencyLabel.text = model.agencyName;
    [self.avatorView updateAvatarWithModel:model];
    
    if (model.realtorScoreDisplay.length && model.realtorTags.count) {
        //3行全有
        [self.nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.avatorView.mas_right).mas_offset(10);
            make.top.mas_equalTo(12);
            make.height.mas_equalTo(16);
        }];
        
        [self.tagsView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.nameLabel.mas_left);
            make.top.mas_equalTo(self.nameLabel.mas_bottom).mas_offset(28);
            make.right.mas_lessThanOrEqualTo(-10);
            make.height.mas_equalTo(18);
        }];

    } else if (model.realtorScoreDisplay.length || model.realtorTags.count) {
        //2行
        [self.nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.avatorView.mas_right).mas_offset(10);
            make.top.mas_equalTo(12);
            make.height.mas_equalTo(16);
        }];
        
        if (model.realtorTags.count) {
            [self.tagsView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(self.nameLabel.mas_left);
                make.top.mas_equalTo(self.nameLabel.mas_bottom).mas_offset(8);
                make.right.mas_lessThanOrEqualTo(-10);
                make.height.mas_equalTo(18);
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
        self.scoreLabel.hidden = YES;
    }
    BOOL result  = NO;
    if (model.businessLicense.length > 0) {
        result = YES;
    }
    if (model.certificate.length > 0) {
        result = YES;
    }
    
    self.licenseButton.hidden = YES;
    self.agencyBac.hidden = NO;
    /// 北京商业化开城需求新增逻辑
    if (model.certification.openUrl.length) {
        self.licenseButton.hidden = NO;
        self.agencyBac.hidden = YES;
        NSURL *iconURL = [NSURL URLWithString:model.certification.iconUrl];
        if (iconURL) {
            [self.licenseButton bd_setImageWithURL:iconURL forState:UIControlStateNormal];
        }
    } else {
        if (model.businessLicense.length > 0 || model.certificate.length > 0) {
            self.licenseButton.hidden = NO;
        }
    }
    
    if (self.licenseButton.hidden) {
        [self.agencyBac mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.nameLabel);
            make.height.mas_equalTo(16);
            make.left.mas_equalTo(self.nameLabel.mas_right).offset(4);
            make.right.mas_lessThanOrEqualTo(self.imBtn.mas_left).offset(-10);
        }];
    } else {
        [self.agencyBac mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.nameLabel);
            make.height.mas_equalTo(16);
            make.left.mas_equalTo(self.licenseButton.mas_right).offset(4);
            make.right.mas_lessThanOrEqualTo(self.imBtn.mas_left).offset(-10);
        }];
    }
    
    if (model.realtorTags.count) {
        self.tagsView.hidden = NO;
        [self.tagsView reloadData];
    } else {
        self.tagsView.hidden = YES;
    }
    
}

- (NSString *)elementType {
    return @"neighborhood_detail_related";
}

- (void)cellClick:(UIControl *)control {
    if (self.releatorClickBlock) {
        self.releatorClickBlock(self.currentData);
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    FHDetailContactModel *model = (FHDetailContactModel *)self.currentData;
    FHRealtorTag *tagInfo = [model.realtorTags objectAtIndex:indexPath.row];
    UIColor *fontColor = [UIColor colorWithHexStr:tagInfo.fontColor];
    UIColor *backgroundColor = [UIColor colorWithHexStr:tagInfo.backgroundColor];
    if(fontColor && backgroundColor) {
        CGSize itemSize = [tagInfo.text sizeWithAttributes:@{
                                                  NSForegroundColorAttributeName: fontColor,
                                                  NSBackgroundColorAttributeName: backgroundColor,
                                                  NSFontAttributeName: [UIFont themeFontRegular:10]
                                                  }];
        
        itemSize.width += 10;
        itemSize.height += 4;
        if (tagInfo.prefixIconUrl.length > 0) {
            itemSize.width += 11;
        }
        return itemSize;
    }
    return CGSizeZero;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    FHDetailContactModel *model = (FHDetailContactModel *)self.currentData;
    return model.realtorTags.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FHDetailAgentItemTagsViewCell *tagCell = [collectionView dequeueReusableCellWithReuseIdentifier:[FHDetailAgentItemTagsViewCell reuseIdentifier] forIndexPath:indexPath];
    FHDetailContactModel *model = (FHDetailContactModel *)self.currentData;
    FHRealtorTag *tagInfo = [model.realtorTags objectAtIndex:indexPath.row];
    [tagCell refreshWithData:tagInfo];
    return tagCell;
}
@end
