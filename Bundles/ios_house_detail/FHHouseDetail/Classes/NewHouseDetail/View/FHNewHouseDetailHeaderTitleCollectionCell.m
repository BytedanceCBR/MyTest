//
//  FHNewHouseDetailHeaderTitleCollectionCell.m
//  AKCommentPlugin
//
//  Created by bytedance on 2020/9/6.
//

#import "FHNewHouseDetailHeaderTitleCollectionCell.h"
#import "FHDetailTopBannerView.h"
#import "FHHouseTagsModel.h"
#import <FHHouseBase/UIImage+FIconFont.h>
#import <ByteDanceKit/ByteDanceKit.h>

@interface FHNewHouseDetailHeaderTitleCollectionCell ()

@property (nonatomic, strong) FHDetailTopBannerView *topBanner;
@property (nonatomic, weak) UIView *tagBacView;
@property (nonatomic, weak) UILabel *nameLabel;
@property (nonatomic, weak) UILabel *addressLab;

@end

@implementation FHNewHouseDetailHeaderTitleCollectionCell

+ (CGSize)cellSizeWithData:(id)data width:(CGFloat)width {
    if (data && [data isKindOfClass:[FHNewHouseDetailHeaderTitleCellModel class]]) {
        FHNewHouseDetailHeaderTitleCellModel *model = (FHNewHouseDetailHeaderTitleCellModel *)data;
        
        CGFloat height = 0;
        if (model.businessTag.length > 0 && model.advantage.length > 0) {
            height += 40; //banner height
        }
        
        height += 20; //title margin
        
        height += [model.titleStr btd_sizeWithFont:[UIFont themeFontRegular:24] width:width - 15 * 2 maxLine:2].height;
        
        height += 15; //tag margin
        NSArray *tags = model.tags;
        CGFloat tagHeight = tags.count > 0 ? 20 : 0.01;
        
        height += tagHeight;
        return CGSizeMake(width, height);
    }
    return CGSizeZero;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.topBanner = [[FHDetailTopBannerView alloc] init];
        [self addSubview:self.topBanner];
        [self.topBanner mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self);
            make.top.mas_equalTo(0);
            make.height.mas_equalTo(0);
        }];
        self.topBanner.hidden = YES;
        
        [self.topBanner.containerView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.mas_equalTo(0);
            make.left.mas_equalTo(0);
            make.right.mas_equalTo(0);
        }];
        
        UILabel *nameLabel = [UILabel createLabel:@"" textColor:@"" fontSize:24];
        nameLabel.textColor = [UIColor themeGray1];
        nameLabel.font = [UIFont themeFontMedium:24];
        nameLabel.numberOfLines = 2;
        [self addSubview:nameLabel];
        self.nameLabel = nameLabel;
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self).offset(15);
            make.right.mas_equalTo(self).offset(-15);
            make.top.mas_equalTo(self.topBanner.mas_bottom).offset(20);
        }];
        
        UIView *tagBacView = [[UIView alloc]init];
        tagBacView.clipsToBounds = YES;
        [self addSubview:tagBacView];
        self.tagBacView = tagBacView;
        [self.tagBacView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self).offset(15);
            make.right.mas_equalTo(self).offset(-15);
            make.top.mas_equalTo(self.nameLabel.mas_bottom).offset(15);
            make.height.mas_offset(0);
            make.bottom.mas_equalTo(self);
        }];
        
    }
    return self;
}

- (void)refreshWithData:(id)data {
    if (data && [data isKindOfClass:[FHNewHouseDetailHeaderTitleCellModel class]]) {
        self.currentData = data;
        [self updateModel:(FHNewHouseDetailHeaderTitleCellModel *)data];
    }
}

- (void)updateModel:(FHNewHouseDetailHeaderTitleCellModel *)model {
    NSArray *tags = model.tags;
    CGFloat tagHeight = tags.count > 0 ? 20 : 0.01;
    CGFloat topHeight = 0;
//    CGFloat tagTop = tags.count > 0 ? 16 : 0;//在没有tagtop的时候更向下
    
    if (model.businessTag.length > 0 && model.advantage.length > 0) {
        topHeight = 40;
        [self.topBanner updateWithTitle:model.businessTag content:model.advantage isCanClick:NO clickUrl:nil];
    }
    self.topBanner.hidden = (topHeight <= 0);
    [self.topBanner mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(topHeight);
    }];
    self.nameLabel.text = model.titleStr;
    
    [self.tagBacView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(tagHeight);
    }];

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
        
        CGFloat inset = 4;
        
        CGFloat itemWidth = itemSize.width + 10;
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

- (UILabel *)createLabelWithTextForSecondHouse:(NSString *)text bacColor:(UIColor *)bacColor textColor:(UIColor *)textColor{
    UILabel *label = [[UILabel alloc]init];
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = bacColor;
    label.textColor = textColor;
    label.layer.cornerRadius = 2;
    label.layer.masksToBounds = YES;
    label.text = text;
    label.font = [UIFont themeFontRegular:12];
    return label;
}

@end

@implementation FHNewHouseDetailHeaderTitleCellModel

@end
