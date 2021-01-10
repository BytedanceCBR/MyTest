//
//  FHDeatilHeaderTitleView.m
//  AKCommentPlugin
//
//  Created by liuyu on 2019/11/26.
//

#import "FHOldDetailHeaderTitleView.h"
#import "FHHouseTagsModel.h"
#import <TTThemed/SSThemed.h>
#import "Masonry.h"
#import "UIFont+House.h"
#import "UILabel+House.h"
#import "UIColor+Theme.h"
#import "FHDetailTopBannerView.h"
#import "FHDetailFeedbackButton.h"
#import <FHHouseBase/UIImage+FIconFont.h>
#import "FHHouseDetailBaseViewModel.h"

@interface FHOldDetailHeaderTitleView ()
@property (nonatomic, weak) UIImageView *shadowImage;
@property (nonatomic, weak) UIButton *mapBtn;//仅小区展示
@property (nonatomic, weak) UIView *tagBacView;
@property (nonatomic, weak) UILabel *nameLabel;
@property (nonatomic, weak) UILabel *addressLab;
@property (nonatomic, weak) UILabel *totalPirce;//仅户型详情页x展示
@property (nonatomic, weak) UIControl *priceAskView;
@property (nonatomic, weak) FHDetailFeedbackButton *feedbackButton;

@property (nonatomic, strong) FHDetailTopBannerView *topBanner;

@end
@implementation FHOldDetailHeaderTitleView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
    }
    return self;
}
- (void)initUI {
    [self.shadowImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    
    // 企业担保顶部banner位
    [self addSubview:self.topBanner];
    [self.topBanner mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.equalTo(self).mas_equalTo(9);
        make.height.mas_equalTo(0);
    }];
    self.topBanner.hidden = YES;
}

- (UIImageView *)shadowImage {
    if (!_shadowImage) {
        UIImageView *shadowImage = [[UIImageView alloc]init];
        shadowImage.image = [[UIImage imageNamed:@"left_top_right_1"] resizableImageWithCapInsets:UIEdgeInsetsMake(30,25,0,25) resizingMode:UIImageResizingModeStretch];
        [self addSubview:shadowImage];
        _shadowImage = shadowImage;
    }
    return  _shadowImage;
}

- (FHDetailTopBannerView *)topBanner {
    if (!_topBanner) {
        _topBanner = [[FHDetailTopBannerView alloc]init];
    }
    return _topBanner;
}

- (UIView *)tagBacView {
    if (!_tagBacView) {
        UIView *tagBacView = [[UIView alloc]init];
        tagBacView.clipsToBounds = YES;
        [self addSubview:tagBacView];
        _tagBacView = tagBacView;
    }
    return _tagBacView;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        UILabel *nameLabel = [UILabel createLabel:@"" textColor:@"" fontSize:24];
        nameLabel.textColor = [UIColor themeGray1];
        nameLabel.font = [UIFont themeFontMedium:24];
        nameLabel.numberOfLines = 2;
        [self addSubview:nameLabel];
        _nameLabel = nameLabel;
    }
    return _nameLabel;
}

- (UILabel *)addressLab {
    if (!_addressLab) {
        UILabel *addressLab = [UILabel createLabel:@"" textColor:@"" fontSize:14];
        addressLab.textColor = [UIColor themeGray3];
        addressLab.font = [UIFont themeFontRegular:14];
        addressLab.numberOfLines = 2;
        [self addSubview:addressLab];
        _addressLab = addressLab;
    }
    return _addressLab;
}

- (FHDetailFeedbackButton *)feedbackButton {
    if (!_feedbackButton) {
        FHDetailFeedbackButton *button = [[FHDetailFeedbackButton alloc] init];
        [self addSubview:button];
        _feedbackButton = button;
    }
    return _feedbackButton;
}

- (UIButton *)mapBtn {
    if (!_mapBtn) {
        UIButton *mapBtn = [[UIButton alloc]init];
        [mapBtn setImage:[UIImage imageNamed:@"plot_mapbtn"] forState:UIControlStateNormal];
        [mapBtn addTarget:self action:@selector(clickMapAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:mapBtn];
        _mapBtn = mapBtn;
    }
    return _mapBtn;
}

- (UILabel *)totalPirce{
    if (!_totalPirce) {
        UILabel *totalPirce = [UILabel createLabel:@"" textColor:@"" fontSize:14];
        totalPirce.textColor = [UIColor themeOrange1];
        totalPirce.font = [UIFont themeFontMedium:14];
        totalPirce.numberOfLines = 1;
        [self addSubview:totalPirce];
        _totalPirce = totalPirce;
    }
    return _totalPirce;
}

- (UILabel *)createLabelWithText:(NSString *)text bacColor:(UIColor *)bacColor textColor:(UIColor *)textColor {
    UILabel *label = [[UILabel alloc]init];
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = bacColor;
    label.textColor = textColor;
    label.layer.cornerRadius = 10;
    label.layer.masksToBounds = YES;
    label.text = text;
    label.font = [UIFont themeFontMedium:12];
    return label;
}

- (UILabel *)createLabelWithTextForSecondHouse:(NSString *)text bacColor:(UIColor *)bacColor textColor:(UIColor *)textColor {
    UILabel *label = [[UILabel alloc]init];
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = bacColor;
    label.textColor = textColor;
    label.layer.cornerRadius = 2;
    label.layer.masksToBounds = YES;
    label.text = text;
    label.font = [UIFont themeFontRegular:10];
    return label;
}

- (UIControl *)priceAskView {
    if (!_priceAskView) {
        UIControl *priceAskView = [[UIControl alloc] init];
        [priceAskView addTarget:self action:@selector(priceAskViewAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:priceAskView];
        _priceAskView = priceAskView;
        
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.textColor = [UIColor themeOrange1];
        titleLabel.font = [UIFont themeFontMedium:14];
        titleLabel.text = self.model.priceConsult.text;
        [_priceAskView addSubview:titleLabel];
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.centerY.mas_equalTo(_priceAskView);
        }];
        
        UIImageView *indicatorImageView = [[UIImageView alloc] init];
        indicatorImageView.image = ICON_FONT_IMG(16, @"\U0000e670", [UIColor themeOrange1]);
        indicatorImageView.contentMode = UIViewContentModeCenter;
        [_priceAskView addSubview:indicatorImageView];
        [indicatorImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(0);
            make.size.mas_equalTo(CGSizeMake(20, 20));
            make.top.bottom.mas_equalTo(0);
            make.left.mas_equalTo(titleLabel.mas_right).mas_offset(5);
        }];
    }
    return _priceAskView;
}

- (void)setTags:(NSArray *)tags {
    _tags = tags;
}
- (void)setTitleStr:(NSString *)titleStr {
   
}

- (void)setFloorPanModel {
    NSArray *tags = _model.tags;
    CGFloat tagHeight = tags.count > 1 ? 20 : 0.01;
    CGFloat tagTop = tags.count > 1 ? 20 : 2;
    if (tags.count) {
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self).offset(31);
            make.height.mas_equalTo(28);
            make.top.mas_equalTo(self.mas_top).offset(40);
        }];
        
        [self.tagBacView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self).offset(15);
            make.right.mas_equalTo(self).offset(-15);
            make.top.mas_equalTo(self.nameLabel.mas_bottom).offset(12);
            make.height.mas_offset(tagHeight);
        }];
        
        if (tags.count == 1) {
            FHHouseTagsModel *tagModel = [tags firstObject];
            [self.nameLabel sizeToFit];
            CGSize itemSize = [self.nameLabel sizeThatFits:CGSizeMake([UIScreen mainScreen].bounds.size.width, 28)];
            UIColor *tagBacColor = [UIColor colorWithHexString:tagModel.backgroundColor];
            UIColor *tagTextColor = [UIColor colorWithHexString:tagModel.textColor];
            UILabel *label = [self createLabelWithText:tagModel.content bacColor:tagBacColor  textColor:tagTextColor];
            CGFloat tagWidth = [UIScreen mainScreen].bounds.size.width - 31;
            CGFloat itemWidth = itemSize.width;
            if (itemWidth > tagWidth - 31 - 40 -4) {
                itemWidth = tagWidth - 31 - 40 -4;
            }
            [self addSubview:label];
            
            [label mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(self.nameLabel.mas_right).offset(6);
                make.width.mas_equalTo(40);
                make.centerY.mas_equalTo(self.nameLabel);
                make.height.mas_equalTo(20);
            }];
        } else {
            
            __block UIView *lastView = self.tagBacView;
            __block CGFloat maxWidth = 30;
            [tags enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                FHHouseTagsModel *tagModel = obj;
                CGSize itemSize = [tagModel.content sizeWithAttributes:@{
                                                                         NSFontAttributeName: [UIFont themeFontRegular:12]
                                                                         }];
                
                UIColor *tagBacColor = [UIColor colorWithHexString:tagModel.backgroundColor];
                UIColor *tagTextColor = [UIColor colorWithHexString:tagModel.textColor];
                UILabel *label = [self createLabelWithText:tagModel.content bacColor:tagBacColor  textColor:tagTextColor];
                        
                CGFloat inset = 10;
                if (self.model.housetype == FHHouseTypeNewHouse) {
                    inset = 4;
                }
                CGFloat itemWidth = itemSize.width + 18;
                maxWidth += itemWidth + inset;
                CGFloat tagWidth = [UIScreen mainScreen].bounds.size.width - 30;
                if (maxWidth >= tagWidth) {
                    *stop = YES;
                }else {
                    [self.tagBacView addSubview:label];
                    [label mas_makeConstraints:^(MASConstraintMaker *make) {
                        if (idx == 0) {
                            make.left.equalTo(lastView).offset(16);
                        }else {
                            make.left.equalTo(lastView.mas_right).offset(inset);
                        }
                        make.top.equalTo(self.tagBacView);
                        make.width.mas_offset(itemWidth);
                        make.height.equalTo(self.tagBacView);
                    }];
                    lastView = label;
                }
            }];
        }
    }
    else{
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self).offset(31);
            make.right.mas_equalTo(self).offset(-35);
            make.height.mas_equalTo(28);
            make.top.mas_equalTo(self.mas_top).offset(50);
        }];
        
        [self.tagBacView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self).offset(15);
            make.right.mas_equalTo(self).offset(-15);
            make.top.mas_equalTo(self.nameLabel.mas_bottom).offset(9);
            make.height.mas_offset(tagHeight);
        }];
        
    }
    NSString *picing = _model.Picing;
    self.totalPirce.text = picing;
    if (_model.displayPrice.length > 0) {
        NSString *displayPrice = _model.displayPrice;
        self.totalPirce.text = displayPrice;
        NSMutableAttributedString *noteStr = [[NSMutableAttributedString alloc] initWithString:self.totalPirce.text];
        NSRange range = [displayPrice rangeOfString:picing];
        
        if (range.location != NSNotFound) {
            [noteStr addAttribute:NSFontAttributeName value:[UIFont themeFontMedium:20] range:range];
        }
        self.totalPirce.attributedText = noteStr;
    }
    
    [self.totalPirce mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self).offset(31);
        make.top.mas_equalTo(self.tagBacView.mas_bottom).offset(tagTop);
        make.height.mas_equalTo(24);
        make.bottom.mas_equalTo(self);
    }];
    
    if (self.model.priceConsult.text.length && self.model.priceConsult.openurl.length) {
        [self.priceAskView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-31);
            make.centerY.mas_equalTo(self.totalPirce.mas_centerY);
        }];
    }
}

+ (NSDictionary *)nameLabelAttributes {
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.minimumLineHeight = 28;
    paragraphStyle.maximumLineHeight = 28;
    paragraphStyle.lineSpacing = 0;
    
    return @{
        NSFontAttributeName: [UIFont themeFontMedium:24],
        NSForegroundColorAttributeName: [UIColor themeGray1],
        NSParagraphStyleAttributeName: paragraphStyle
    };
}

- (NSAttributedString *)nameLabelAttributeText:(NSString *)text {
    return [[NSAttributedString alloc] initWithString:text attributes:[self.class nameLabelAttributes]];
}

- (void)setModel:(FHDetailHouseTitleModel *)model {
    _model = model;
    NSArray *tags = model.tags;
    self.mapBtn.hidden = !model.showMapBtn;
    self.nameLabel.attributedText = [self nameLabelAttributeText:model.titleStr];
    CGFloat tagHeight = tags.count > 0 ? 16 : 0.01;
    
    CGFloat topHeight = 0;
    CGFloat tagTop = tags.count > 0 ? 12 : 0;
    
    if (model.isFloorPan) {
        [self setFloorPanModel];
        return;
    }
    
    switch (model.housetype) {
        case FHHouseTypeNewHouse:{
            if (model.businessTag.length > 0 && model.advantage.length > 0) {
                topHeight = 40;
                [self.topBanner updateWithTitle:model.businessTag content:model.advantage isCanClick:model.isCanClick clickUrl:model.clickUrl];
            }
            self.topBanner.hidden = (topHeight <= 0);
            [self.topBanner mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(topHeight);
            }];
            
            CGFloat topheight = _topBanner.hidden ? 20 : 16;
            [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(self).offset(31);
                make.right.mas_equalTo(self).offset(-35);
                make.top.mas_equalTo(self.topBanner.mas_bottom).offset(topheight);
                //            make.height.mas_offset(25);
                //            make.bottom.mas_equalTo(-tagBottom - tagHeight);
            }];
            [self.tagBacView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(self).offset(15);
                make.right.mas_equalTo(self).offset(-15);
                make.top.mas_equalTo(self.nameLabel.mas_bottom).offset(15);
                make.height.mas_offset(tagHeight);
                make.bottom.mas_equalTo(self);
            }];
            break;
            }
        case FHHouseTypeNeighborhood:{
            self.nameLabel.numberOfLines = 1;
            self.addressLab.numberOfLines = 1;
            if (model.address.length>0) {
                [self.tagBacView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.mas_equalTo(self).offset(15);
                    make.right.mas_equalTo(self).offset(-15);
                    make.top.mas_equalTo(self.topBanner.mas_bottom).mas_offset(20);
                    make.height.mas_offset(tagHeight);
                }];
                [self.nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.left.mas_equalTo(self).offset(31);
                    make.right.mas_equalTo(self).offset(-100);
                    make.top.mas_equalTo(self.tagBacView.mas_bottom).offset(tagTop);
                }];
                [self.addressLab mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.left.mas_equalTo(self).offset(31);
                    make.right.mas_equalTo(self).offset(-100);
                    make.top.mas_equalTo(self.nameLabel.mas_bottom).offset(4);
                    make.bottom.mas_equalTo(self);
                }];
                [self.mapBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(self.nameLabel).offset(5);
                    make.right.equalTo(self).offset(-32);
                    make.size.mas_equalTo(CGSizeMake(44, 44));
                    make.bottom.mas_equalTo(self).offset(-5);
                }];
                self.addressLab.text = model.address;
            }else {
                [self.tagBacView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.mas_equalTo(self).offset(15);
                    make.right.mas_equalTo(self).offset(-15);
                    make.top.mas_equalTo(self.topBanner.mas_bottom).mas_offset(30);
                    make.height.mas_offset(tagHeight);
                }];
                [self.nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.left.mas_equalTo(self).offset(31);
                    make.right.mas_equalTo(self).offset(-35);
                    make.top.mas_equalTo(self.tagBacView.mas_bottom).offset(tagTop);
                    make.bottom.mas_equalTo(self);
                }];
            }
            break;
        }
        case FHHouseTypeSecondHandHouse:{
            // 企业担保数据展示
            if (model.businessTag.length > 0 && model.advantage.length > 0) {
                topHeight = 40;
                [self.topBanner updateWithTitle:model.businessTag content:model.advantage isCanClick:model.isCanClick clickUrl:model.clickUrl];
            }
            self.topBanner.hidden = (topHeight <= 0);
            [self.topBanner mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(topHeight);
            }];
            
            // 标签背景视图
            [self.tagBacView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(self).offset(9);
                make.right.mas_equalTo(self).offset(-9);
                make.top.mas_equalTo(self.topBanner.mas_bottom).mas_offset(12);
                make.height.mas_offset(tagHeight);
            }];
            
            // 反馈按钮展示
            [self.feedbackButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.mas_equalTo(self.tagBacView);
                make.height.mas_equalTo(16);
                make.right.mas_equalTo(-21);
                make.width.mas_equalTo(46);
            }];
            // 反馈带入信息数据获取
            FHDetailOldDataModel *ershouData = [(FHDetailOldModel *)self.baseViewModel.detailData data];
            [self.feedbackButton updateWithDetailTracerDic:self.baseViewModel.detailTracerDic.copy listLogPB:self.baseViewModel.listLogPB houseData:ershouData houseType:model.housetype reportUrl:model.reportUrl];
            
            // 房源名称标签展示
            [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(self).offset(21);
                make.right.mas_equalTo(self).offset(-21);
                make.top.mas_equalTo(self.tagBacView.mas_bottom).offset(tagTop);
                make.bottom.mas_equalTo(self);
            }];
            break;
        }
        //貌似租房不会走这里哦
        default:{
            [self.tagBacView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(self).offset(15);
                make.right.mas_equalTo(self).offset(-15);
                make.top.mas_equalTo(self.topBanner.mas_bottom).mas_offset(30);
                make.height.mas_offset(tagHeight);
            }];
            [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(self).offset(31);
                make.right.mas_equalTo(self).offset(-35);
                make.top.mas_equalTo(self.tagBacView.mas_bottom).offset(tagTop);
                make.bottom.mas_equalTo(self);
            }];
        }
            break;
    }


    __block UIView *lastView = self.tagBacView;

    __block CGFloat maxWidth = 30;
    [tags enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        FHHouseTagsModel *tagModel = obj;
        CGSize itemSize = [tagModel.content sizeWithAttributes:@{
                                                                 NSFontAttributeName: [UIFont themeFontRegular:12]
                                                                 }];
        UILabel *label = nil;
        UIColor *tagBacColor = idx == 0 ?[UIColor colorWithHexString:@"#ffeee5"]:[UIColor colorWithHexString:@"#f5f5f5"];
        UIColor *tagTextColor = idx == 0 ?[UIColor colorWithHexString:@"#fe5500"]:[UIColor colorWithHexString:@"#333333"];
        label = [self createLabelWithTextForSecondHouse:tagModel.content bacColor:tagBacColor  textColor:tagTextColor];

        // 标签间距
        CGFloat inset = 6;
        if (self.model.housetype == FHHouseTypeNewHouse) {
            inset = 4;
        }
        CGFloat itemWidth = itemSize.width + 10;
        maxWidth += itemWidth + inset;
        CGFloat tagWidth = [UIScreen mainScreen].bounds.size.width - 18;
        if (model.housetype == FHHouseTypeSecondHandHouse) {
            tagWidth -= 46;
        }
        if (maxWidth >= tagWidth) {
            *stop = YES;
        }else {
            [self.tagBacView addSubview:label];
            [label mas_makeConstraints:^(MASConstraintMaker *make) {
                if (idx == 0) {
                    make.left.equalTo(lastView).offset(12);
                }else {
                    make.left.equalTo(lastView.mas_right).offset(inset);
                }
                make.top.equalTo(self.tagBacView);
                make.width.mas_offset(itemWidth);
                make.height.equalTo(self.tagBacView);
            }];
            lastView = label;
        }
    }];
}

- (void)clickMapAction:(UIButton *)btn {
    if (self.model.mapImageClick) {
        self.model.mapImageClick();
    }
}

- (void)priceAskViewAction:(id)sender {
    if (self.model.priceConsult.openurl.length && self.baseViewModel.contactViewModel) {
        NSMutableDictionary *extraDic = [self.baseViewModel.detailTracerDic mutableCopy];
        extraDic[@"click_position"] = self.model.priceConsult.text?:@"be_null";
        extraDic[@"im_open_url"] = self.model.priceConsult.openurl;
        if (self.model.priceConsult.associateInfo) {
            extraDic[kFHAssociateInfo] = self.model.priceConsult.associateInfo;
        }
        [self.baseViewModel.contactViewModel onlineActionWithExtraDict:extraDic];
    }
}
@end
