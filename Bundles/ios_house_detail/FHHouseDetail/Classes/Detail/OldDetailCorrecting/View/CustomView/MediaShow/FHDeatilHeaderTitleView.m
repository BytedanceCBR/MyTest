//
//  FHDeatilHeaderTitleView.m
//  AKCommentPlugin
//
//  Created by liuyu on 2019/11/26.
//

#import "FHDeatilHeaderTitleView.h"
#import "FHHouseTagsModel.h"
#import <TTThemed/SSThemed.h>
#import <Masonry.h>
#import "UIFont+House.h"
#import "UILabel+House.h"
#import "UIColor+Theme.h"
@interface FHDeatilHeaderTitleView ()
@property (nonatomic, weak) UIImageView *shadowImage;
@property (nonatomic, weak) UIView *tagBacView;
@property (nonatomic, weak) UILabel *nameLabel;
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
    [self.tagBacView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self).offset(15);
        make.right.mas_equalTo(self).offset(-15);
        make.top.mas_equalTo(self).offset(50);
        make.height.mas_offset(20);
    }];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self).offset(31);
        make.right.mas_equalTo(self).offset(-35);
        make.top.mas_equalTo(self.tagBacView.mas_bottom).offset(17);
    }];
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

- (void)setModel:(FHDetailHouseTitleModel *)model {
    NSArray *tags = model.tags;
     self.nameLabel.text = model.titleStr;
    __block UIView *lastView = self.tagBacView;
    if (tags.count  == 0) {
        [self.tagBacView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_offset(0.01);
        }];
        [self.nameLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.tagBacView.mas_bottom).offset(-5);
        }];
    }
    [tags enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        FHHouseTagsModel *tagModel = obj;
        CGSize itemSize = [tagModel.content sizeWithAttributes:@{
                                                                 NSFontAttributeName: [UIFont themeFontRegular:12]
                                                                 }];
        UIColor *tagBacColor = idx == 0 ?[UIColor colorWithHexString:@"#ffead3"]: [[UIColor colorWithHexStr:@"a59f9c"]colorWithAlphaComponent:0.39 ];
        UIColor *tagTextColor = idx == 0 ?[UIColor colorWithHexString:@"#ff9300"]:[UIColor colorWithHexString:@"#a49a92"];
        UILabel *label = [self createLabelWithText:tagModel.content bacColor:tagBacColor  textColor:tagTextColor];
        [self.tagBacView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            if (idx == 0) {
                make.left.equalTo(lastView).offset(16);
            }else {
                make.left.equalTo(lastView.mas_right).offset(10);
            }
            make.top.equalTo(self.tagBacView);
            make.width.mas_offset(itemSize.width+18);
            make.height.equalTo(self.tagBacView);
        }];
        lastView = label;
    }];
}
@end
