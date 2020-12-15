//
//  FHDetailAgentItemView.m
//  Pods
//
//  Created by bytedance on 2020/8/23.
//

#import "FHDetailAgentItemView.h"
#import <Masonry/Masonry.h>
#import <FHCommonUI/UIFont+House.h>
#import <FHCommonUI/UIColor+Theme.h>
#import <FHCommonUI/UILabel+House.h>
#import <BDWebImage/BDWebImage.h>
#import <ByteDanceKit/ByteDanceKit.h>

@implementation FHDetailAgentItemTagsViewCell

+ (NSString *)reuseIdentifier {
    return NSStringFromClass([self class]);
}

-(UILabel *)tagLabel {
    if(!_tagLabel) {
        _tagLabel = [[UILabel alloc] init];
        _tagLabel.font = [UIFont themeFontMedium:10];
        _tagLabel.numberOfLines = 1;
        _tagLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _tagLabel;
}

-(instancetype)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        [self.contentView addSubview:self.tagLabel];
        [self.tagLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.contentView);
        }];
        self.contentView.layer.cornerRadius = 2;
//        self.contentView.layer.masksToBounds = YES;
    }
    return self;
}

- (void)refreshWithData:(id)data {
    FHRealtorTag *model = data;
    self.tagLabel.text = model.text;
    self.contentView.backgroundColor = [UIColor colorWithHexStr:model.backgroundColor];
    self.contentView.layer.borderColor = [UIColor colorWithHexStr:model.borderColor].CGColor;
    self.contentView.layer.borderWidth = .3;
    self.tagLabel.textColor = [UIColor colorWithHexStr:model.fontColor];
    if (model.prefixIconUrl.length > 0) {
        if (!_tagImageView) {
            _tagImageView = [[UIImageView alloc] init];
            [_tagImageView bd_setImageWithURL:[NSURL URLWithString:model.prefixIconUrl]];
            [self.contentView addSubview:self.tagImageView];
            [self.tagImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.top.mas_equalTo(2);
                make.width.height.mas_equalTo(14);
            }];
        }
        [self.tagLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.tagImageView.mas_right);
            make.centerY.mas_equalTo(self);
        }];
    } else {
        if (self.tagImageView) {
            [self.tagImageView removeFromSuperview];
            self.tagImageView = nil;
        }
        [self.tagLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentView);
        }];
    }
}


@end

@implementation FHDetailAgentItemTagsFlowLayout

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect
{
    //使用系统帮我们计算好的结果。
    NSArray *attributes = [super layoutAttributesForElementsInRect:rect];
    
    //第0个cell没有上一个cell，所以从1开始
    for(int i = 1; i < [attributes count]; ++i) {
        //这里 UICollectionViewLayoutAttributes 的排列总是按照 indexPath的顺序来的。
        UICollectionViewLayoutAttributes *curAttr = attributes[i];
        UICollectionViewLayoutAttributes *preAttr = attributes[i-1];
        
        NSInteger origin = CGRectGetMaxX(preAttr.frame);
        //根据  maximumInteritemSpacing 计算出的新的 x 位置
        CGFloat targetX = origin + self.maximumInteritemSpacing;
        // 只有系统计算的间距大于  maximumInteritemSpacing 时才进行调整
        if (CGRectGetMinX(curAttr.frame) > targetX) {
            // 换行时不用调整
            if (targetX + CGRectGetWidth(curAttr.frame) <= self.collectionViewContentSize.width) {
                CGRect frame = curAttr.frame;
                frame.origin.x = targetX;
                curAttr.frame = frame;
            } else {
                CGRect frame = curAttr.frame;
                frame.size.width = 0;
                curAttr.frame = frame;
            }
        }
    }
    return attributes;
}

-(instancetype)init {
    if(self = [super init]) {
        self.maximumInteritemSpacing = 6.0f;
        self.minimumInteritemSpacing = 6.0f;
        self.scrollDirection = UICollectionViewScrollDirectionVertical;
    }
    return self;
}
@end

@interface FHDetailAgentItemView()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, assign) CGFloat topMargin;
@property (nonatomic, strong) FHDetailContactModel *model;
@property (nonatomic, strong) UICollectionView *tagsView;

@end

@implementation FHDetailAgentItemView

-(instancetype)initWithModel:(FHDetailContactModel *)model topMargin:(CGFloat )topMargin frame:(CGRect )frame{
    if (self = [super initWithFrame:frame]) {
        self.topMargin = topMargin;
        self.model = model;
        
        [self setupUI];
        [self refreshData];
    }
    return self;
}

- (void)setupUI {
    self.avatorView = [[FHRealtorAvatarView alloc] init];
    self.avatorView.avatarImageView.layer.borderColor = [UIColor themeGray6].CGColor;
    self.avatorView.avatarImageView.layer.borderWidth = [UIDevice btd_onePixel];
    [self addSubview:self.avatorView];
    [self.avatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.width.mas_equalTo(50);
        make.left.mas_equalTo(16);
        make.top.mas_equalTo(self.topMargin);
    }];
    
    self.nameLabel = [[UILabel alloc] init];
    self.nameLabel.textColor = [UIColor themeGray1];
    self.nameLabel.font = [UIFont themeFontMedium:16];
    self.nameLabel.textAlignment = NSTextAlignmentLeft;
    [self.nameLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self addSubview:self.nameLabel];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.avatorView.mas_right).offset(10);
        make.top.mas_equalTo(self.avatorView.mas_top);
        make.height.mas_equalTo(18);
    }];
    
    CGFloat phoneButtonWidth = 36;
    self.callBtn = [[UIButton alloc] init];
    [self.callBtn setImage:[UIImage imageNamed:@"detail_agent_phone_icon"] forState:UIControlStateNormal];
    self.callBtn.backgroundColor = [UIColor colorWithHexString:@"fff6ee"];
    self.callBtn.layer.masksToBounds = YES;
    self.callBtn.layer.cornerRadius = phoneButtonWidth/2;
    [self addSubview:self.callBtn];
    [self.callBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(phoneButtonWidth);
        make.right.mas_equalTo(-16);
        make.centerY.mas_equalTo(self.nameLabel.mas_centerY);
    }];
    
    self.imBtn = [[UIButton alloc] init];
    [self.imBtn setImage:[UIImage imageNamed:@"detail_agent_im_icon"] forState:UIControlStateNormal];
    self.imBtn.backgroundColor = [UIColor colorWithHexString:@"fff6ee"];
    self.imBtn.layer.masksToBounds = YES;
    self.imBtn.layer.cornerRadius = phoneButtonWidth/2;
    [self addSubview:self.imBtn];
    [self.imBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(phoneButtonWidth);
        make.right.mas_equalTo(self.callBtn.mas_left).offset(-16);
        make.centerY.mas_equalTo(self.callBtn.mas_centerY);
    }];

    self.licenseButton = [[UIButton alloc] init];
    [self.licenseButton setImage:[UIImage imageNamed:@"detail_contact"] forState:UIControlStateNormal];
    [self addSubview:self.licenseButton];
    [self.licenseButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.nameLabel.mas_right).offset(4);
        make.size.mas_equalTo(CGSizeMake(18, 16));
        make.centerY.mas_equalTo(self.nameLabel.mas_centerY);
    }];
    
    self.agencyBac = [[UIImageView alloc] init];
    self.agencyBac.image = [UIImage imageNamed:@"realtor_name_bac"];
    self.agencyBac.layer.borderWidth = 0.5;
    self.agencyBac.layer.borderColor = [[UIColor colorWithHexString:@"#d6d6d6"] CGColor];
    self.agencyBac.layer.cornerRadius = 2.0;
    self.agencyBac.layer.masksToBounds = YES;
    [self addSubview:self.agencyBac];
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
        make.left.mas_equalTo(5);
        make.right.mas_equalTo(-5);
        make.centerY.mas_equalTo(self.agencyBac);
//        make.edges.mas_equalTo(UIEdgeInsetsMake(3, 5, 3, 5));
    }];
    
    self.scoreLabel = [UILabel createLabel:@"" textColor:@"" fontSize:14];
    self.scoreLabel.textColor = [UIColor themeGray1];
    self.scoreLabel.font = [UIFont themeFontMedium:14];
    self.scoreLabel.textAlignment = NSTextAlignmentLeft;
//    [self.scoreLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
//    [self.scoreLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self addSubview:self.scoreLabel];
    [self.scoreLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.nameLabel);
        make.top.equalTo(self.nameLabel.mas_bottom).offset(8);
        make.right.mas_lessThanOrEqualTo(self.imBtn.mas_left).mas_offset(0);
    }];
    
//    self.scoreDescription = [UILabel createLabel:@"" textColor:@"" fontSize:14];
//    self.scoreDescription.textColor = [UIColor themeGray1];
//    self.scoreDescription.textAlignment = NSTextAlignmentLeft;
//    [self addSubview:self.scoreDescription];
//    [self.scoreDescription mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self.score.mas_right).offset(2);
//        make.right.mas_lessThanOrEqualTo(self).offset(-20);
//        make.centerY.equalTo(self.score);
//    }];
    
    self.tagsView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:[[FHDetailAgentItemTagsFlowLayout alloc] init]];
    self.tagsView.scrollEnabled = NO;
    self.tagsView.backgroundColor = [UIColor whiteColor];
    self.tagsView.delegate = self;
    self.tagsView.dataSource = self;
    [self addSubview:self.tagsView];
    [self.tagsView registerClass:[FHDetailAgentItemTagsViewCell class] forCellWithReuseIdentifier:[FHDetailAgentItemTagsViewCell reuseIdentifier]];
    [self.tagsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.nameLabel.mas_left);
        make.top.mas_equalTo(self.nameLabel.mas_bottom).mas_offset(28);
        make.right.mas_lessThanOrEqualTo(-10);
        make.height.mas_equalTo(18);
    }];
    
}

- (void)refreshData {
    
    FHDetailContactModel *model = self.model;
    
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
        
        if (model.neighborhoodScoreDisplay.length) {
            
            scoreStringValue = model.neighborhoodScoreDisplay.copy;
            if ([scoreStringValue rangeOfString:@"分"].length > 0) {
                scoreStringValue = [scoreStringValue stringByReplacingOccurrencesOfString:@"分" withString:@""];
            }
            
            [scoreString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" + %@ 小区熟悉度",scoreStringValue] attributes:@{NSForegroundColorAttributeName: [UIColor themeGray3], NSFontAttributeName: [UIFont themeFontRegular:12]}]];
        }
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
    
    [self updateConstraints];
    [self setNeedsLayout];
    [self layoutIfNeeded];

}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (CGRectGetWidth(self.bounds) > 0) {
        FHDetailContactModel *model = self.model;
        CGFloat agencyWidth = [model.agencyName btd_widthWithFont:self.agencyLabel.font height:self.agencyLabel.frame.size.height];
        if (!self.agencyBac.hidden && self.agencyBac.frame.size.width > 0 && agencyWidth > (CGRectGetWidth(self.agencyBac.bounds) - 10)) {
            self.agencyBac.hidden = YES;
        }
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    FHRealtorTag *tagInfo = [self.model.realtorTags objectAtIndex:indexPath.row];
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
    return self.model.realtorTags.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FHDetailAgentItemTagsViewCell *tagCell = [collectionView dequeueReusableCellWithReuseIdentifier:[FHDetailAgentItemTagsViewCell reuseIdentifier] forIndexPath:indexPath];
    
    FHRealtorTag *tagInfo = [self.model.realtorTags objectAtIndex:indexPath.row];
    [tagCell refreshWithData:tagInfo];
    return tagCell;
}
@end
