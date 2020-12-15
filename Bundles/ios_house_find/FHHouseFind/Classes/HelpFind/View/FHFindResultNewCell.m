//
//  FHFindResultNewCell.m
//  FHHouseFind
//
//  Created by xubinbin on 2020/10/25.
//

#import "FHFindResultNewCell.h"
#import "FHSearchHouseModel.h"
#import "FHSingleImageInfoCellModel.h"
#import <BDWebImage/UIImageView+BDWebImage.h>
#import "UILabel+BTDAdditions.h"

@implementation FHFindResultNewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initUI];
    }
    return self;
}

+ (CGFloat)heightForData:(id)data {
    if ([data isKindOfClass:[FHSearchHouseItemModel class]]) {
        FHSearchHouseItemModel *itemModel = (FHSearchHouseItemModel *)data;
        if (itemModel.advantageDescription.text) {
            return 130;
        }
    }
    return 118;
}

- (void)refreshLeftAndRightMargin:(CGFloat)leftAndRight {
    if (self.contentView.yoga.paddingLeft.value != leftAndRight) {
        [self.contentView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
            layout.paddingLeft = YGPointValue(leftAndRight);
            layout.paddingRight = YGPointValue(leftAndRight);
        }];
        [self.contentView.yoga markDirty];
    }
}

- (void)refreshWithData:(id)data {
    if (![data isKindOfClass:[FHSearchHouseItemModel class]]) {
        return ;
    }
    [self refreshLeftAndRightMargin:15];
    FHSearchHouseItemModel *commonModel = (FHSearchHouseItemModel *)data;
    self.houseVideoImageView.hidden = !commonModel.houseVideo.hasVideo;
    self.mainTitleLabel.text = commonModel.displayTitle;
    self.subTitleLabel.text = commonModel.displayDescription;
    NSAttributedString * attributeString =  [FHSingleImageInfoCellModel tagsStringWithTagList:commonModel.tags];
    self.tagLabel.attributedText =  attributeString;
    self.priceLabel.text = commonModel.displayPricePerSqm;
    FHImageModel *imageModel = commonModel.images.firstObject;
    [self updateMainImageWithUrl:imageModel.url];
    if ([commonModel.displayPricePerSqm isKindOfClass:[NSString class]] && [commonModel.displayPricePerSqm isEqualToString:@"暂无报价"]) {
        self.priceLabel.textColor = [UIColor themeGray3];
    } else {
        self.priceLabel.textColor = [UIColor themeOrange1];
    }
    self.priceLabel.font = [UIFont themeFontSemibold:16];
    if(commonModel.advantageDescription) {
        self.bottomRecommendView.hidden = NO;
        self.bottomRecommendViewBack.hidden = NO;
    } else {
        self.bottomRecommendView.hidden = YES;
        self.bottomRecommendViewBack.hidden = YES;
    }
    if (commonModel.advantageDescription.icon.url) {
        self.bottomIconImageView.hidden = NO;
        [self.bottomIconImageView bd_setImageWithURL:[NSURL URLWithString:commonModel.advantageDescription.icon.url]];
    } else {
        self.bottomIconImageView.hidden = YES;
    }
    if (commonModel.advantageDescription.text) {
        self.bottomRecommendLabel.hidden = NO;
        if (commonModel.advantageDescription.text.length <= 17) {
            self.bottomRecommendLabel.text = commonModel.advantageDescription.text;
        } else {
            self.bottomRecommendLabel.text = [commonModel.advantageDescription.text substringToIndex:17];
        }
        CGFloat width = MIN([self.bottomRecommendLabel btd_widthWithHeight:13] + 2, [UIScreen mainScreen].bounds.size.width - 106 - 80);
        [self.bottomRecommendLabel configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
            layout.width = YGPointValue(width);
        }];
        if (commonModel.advantageDescription.textColor) {
            self.bottomRecommendLabel.textColor = [UIColor colorWithHexStr:commonModel.advantageDescription.textColor];
        }
        if (commonModel.advantageDescription.borderColor) {
            self.bottomRecommendViewBack.layer.borderColor = [UIColor colorWithHexStr:commonModel.advantageDescription.borderColor].CGColor;
        }
    } else {
        self.bottomRecommendLabel.hidden = YES;
    }
    if (commonModel.houseImageTag.text && commonModel.houseImageTag.backgroundColor && commonModel.houseImageTag.textColor) {
        self.imageTagLabel.textColor = [UIColor colorWithHexString:commonModel.houseImageTag.textColor];
        self.imageTagLabel.text = commonModel.houseImageTag.text;
        self.imageTagLabelBgView.backgroundColor = [UIColor colorWithHexString:commonModel.houseImageTag.backgroundColor];
        self.imageTagLabelBgView.hidden = NO;
    } else {
        self.imageTagLabelBgView.hidden = YES;
    }
    [self hideRecommendReason];
    [self updateTitlesLayout:attributeString.length > 0];
    [self.contentView.yoga applyLayoutPreservingOrigin:NO];
}

- (void)updateTitlesLayout:(BOOL)showTags {
    if (self.tagLabel.yoga.isIncludedInLayout != showTags) {
        [self.tagLabel configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
            layout.isIncludedInLayout = showTags;
        }];
    }
    [self.mainTitleLabel.yoga markDirty];
    [self.rightInfoView.yoga markDirty];
    [self.tagLabel.yoga markDirty];
    [self.priceLabel.yoga markDirty];
    [self.bottomRecommendLabel.yoga markDirty];
    [self.priceBgView.yoga markDirty];
}

@end
