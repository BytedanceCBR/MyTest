//
//  FHDeatilHeaderTitleView.m
//  AKCommentPlugin
//
//  Created by liuyu on 2019/11/26.
//

#import "FHDeatilHeaderTitleView.h"
#import "FHHouseTagsModel.h"
#import <TTThemed/SSThemed.h>
#import "Masonry.h"
#import "UIFont+House.h"
#import "UILabel+House.h"
#import "UIColor+Theme.h"
#import "FHDetailTopBannerView.h"


@interface FHDeatilHeaderTitleView ()
@property (nonatomic, weak) UIImageView *shadowImage;
@property (nonatomic, weak) UIButton *mapBtn;//仅小区展示
@property (nonatomic, weak) UIView *tagBacView;
@property (nonatomic, weak) UILabel *nameLabel;
@property (nonatomic, weak) UILabel *addressLab;
@property (nonatomic, weak) UILabel *totalPirce;//仅户型详情页x展示


@property (nonatomic, strong) FHDetailTopBannerView *topBanner;

@end
@implementation FHDeatilHeaderTitleView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
    }
    return self;
}
- (void)initUI {
    [self.shadowImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self);
        make.height.equalTo(self);
    }];
    [self addSubview:self.topBanner];
    [self.topBanner mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.mas_equalTo(20);
        make.height.mas_equalTo(0);
    }];
    self.topBanner.hidden = YES;
}

- (UIImageView *)shadowImage {
    if (!_shadowImage) {
        UIImageView *shadowImage = [[UIImageView alloc]init];
        shadowImage.image = [[UIImage imageNamed:@"left_top_right"] resizableImageWithCapInsets:UIEdgeInsetsMake(30,25,0,25) resizingMode:UIImageResizingModeStretch];
        [self addSubview:shadowImage];
        _shadowImage = shadowImage;
    }
    return  _shadowImage;
}

- (FHDetailTopBannerView *)topBanner
{
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

- (UILabel *)createLabelWithText:(NSString *)text bacColor:(UIColor *)bacColor textColor:(UIColor *)textColor{
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

- (void)setTags:(NSArray *)tags {
  
    _tags = tags;
}
- (void)setTitleStr:(NSString *)titleStr {
   
}

- (void)setFloorPanModel{
    NSArray *tags = _model.tags;
    if (tags) {
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
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self).offset(31);
            make.width.mas_equalTo(itemWidth);
            make.height.mas_equalTo(28);
            make.top.mas_equalTo(self.mas_top).offset(50);
        }];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.nameLabel.mas_right).offset(6);
            make.width.mas_equalTo(40);
            make.centerY.mas_equalTo(self.nameLabel);
            make.height.mas_equalTo(20);
        }];
    }
    else{
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self).offset(31);
            make.right.mas_equalTo(self).offset(-35);
            make.height.mas_equalTo(28);
            make.top.mas_equalTo(self.mas_top).offset(50);
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
        make.top.mas_equalTo(self.nameLabel.mas_bottom).offset(10);
        make.right.mas_equalTo(self).offset(- 35);
        make.height.mas_equalTo(24);
        make.bottom.mas_equalTo(self);
    }];
    
}

- (void)setModel:(FHDetailHouseTitleModel *)model {
    _model = model;
    NSArray *tags = model.tags;
    self.mapBtn.hidden = !model.showMapBtn;
    self.nameLabel.text = model.titleStr;
    CGFloat tagHeight = tags.count > 0 ? 20 : 0.01;
    
    CGFloat topHeight = 0;
    CGFloat tagTop = tags.count > 0 ? 17 : -5;
    CGFloat tagBottom = tags.count > 0 ? 17 : 0;
    
    if (model.isFloorPan) {
        [self setFloorPanModel];
        return;
    }
        
    if (model.housetype == FHHouseTypeNewHouse) {
        if (model.businessTag.length > 0 && model.advantage.length > 0) {
            topHeight = 40;
            [self.topBanner updateWithTitle:model.businessTag content:model.advantage];
        }
        self.topBanner.hidden = (topHeight <= 0);
        [self.topBanner mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(topHeight);
        }];
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self).offset(31);
            make.right.mas_equalTo(self).offset(-35);
            make.top.mas_equalTo(self.topBanner.mas_bottom).offset(28);
//            make.height.mas_offset(25);
//            make.bottom.mas_equalTo(-tagBottom - tagHeight);
        }];
        [self.tagBacView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self).offset(15);
            make.right.mas_equalTo(self).offset(-15);
            make.top.mas_equalTo(self.nameLabel.mas_bottom).offset(15);
            make.height.mas_offset(tagHeight);
            make.bottom.mas_equalTo(self).offset(tags.count > 0 ?-5:0);
        }];
    }else if (model.housetype == FHHouseTypeNeighborhood) {
        self.nameLabel.numberOfLines = 1;
        self.addressLab.numberOfLines = 1;
        if (model.address.length>0) {
            [self.tagBacView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(self).offset(15);
                make.right.mas_equalTo(self).offset(-15);
                make.top.mas_equalTo(self.topBanner.mas_bottom).mas_offset(30);
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
    }else {
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

    __block UIView *lastView = self.tagBacView;

    __block CGFloat maxWidth = 30;
    [tags enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        FHHouseTagsModel *tagModel = obj;
        CGSize itemSize = [tagModel.content sizeWithAttributes:@{
                                                                 NSFontAttributeName: [UIFont themeFontRegular:12]
                                                                 }];
        UIColor *tagBacColor = idx == 0 ?[UIColor colorWithHexString:@"#FFEAD3"]:[UIColor colorWithHexString:@"#F2F1EF"];
        UIColor *tagTextColor = idx == 0 ?[UIColor colorWithHexString:@"#ff9300"]:[UIColor colorWithHexString:@"#a49a92"];
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

- (void)clickMapAction:(UIButton *)btn {
    if (self.model.mapImageClick) {
        self.model.mapImageClick();
    }
}
@end
