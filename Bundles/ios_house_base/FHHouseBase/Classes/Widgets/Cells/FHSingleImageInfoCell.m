//
//  FHSingleImageInfoCell.m
//  FHHouseBase
//
//  Created by 谷春晖 on 2018/11/18.
//

#import "FHSingleImageInfoCell.h"
#import "UIColor+Theme.h"
#import "UIFont+House.h"
#import <YYText/YYText.h>
#import "TTDeviceHelper.h"
#import "Masonry.h"
#import "FHHouseSingleImageInfoCellBridgeDelegate.h"
#import "FHSearchHouseModel.h"
#import "FHNewHouseItemModel.h"
#import "FHHouseRentModel.h"
#import "FHHouseNeighborModel.h"
#import "UIImageView+BDWebImage.h"
#import "FHCornerView.h"

@interface FHSingleImageInfoCell () <FHHouseSingleImageInfoCellBridgeDelegate>

@property(nonatomic, strong) UIImageView *majorImageView;
@property(nonatomic, strong) UILabel *majorTitle;
@property(nonatomic, strong) UILabel *extendTitle;
@property(nonatomic, strong) YYLabel *areaLabel;
@property(nonatomic, strong) UILabel *priceLabel;
@property(nonatomic, strong) UILabel *originPriceLabel;
@property(nonatomic, strong) UILabel *roomSpaceLabel;

@property(nonatomic, weak) UIView *infoPanel;

@property(nonatomic, strong) UIView *headView;
@property(nonatomic, strong) UIView *bottomView;

@property(nonatomic, strong) UILabel *imageTopLeftLabel;
@property(nonatomic, strong) FHCornerView *imageTopLeftLabelBgView;

@property(nonatomic, assign) CGFloat topMargin;
@property(nonatomic, assign) CGFloat bottomMargin;

@end

@implementation FHSingleImageInfoCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.isFirstCell = NO;
        self.isTail = NO;

        self.topMargin = 20;
        self.bottomMargin = 0;

        [self setupUI];
    }
    return self;
    
}

-(void)setupUI {
    
    [self.contentView addSubview:self.headView];
    [self.headView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.right.top.mas_equalTo(self.contentView);
        make.height.mas_equalTo(@14);
    }];
    
    [self.contentView addSubview:self.bottomView];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.mas_equalTo(self.contentView).mas_offset(105);
        make.left.right.bottom.mas_equalTo(self.contentView);
        make.height.mas_equalTo(@10);
    }];
    
    [self.contentView addSubview:self.majorImageView];
    [self.majorImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.mas_equalTo(@20);
        make.top.mas_equalTo(self.headView.mas_bottom).mas_offset(3);
        make.width.mas_equalTo(@114);
        make.height.mas_equalTo(85);

    }];
    
    UIView *infoPanel = [[UIView alloc]init];
    [self.contentView addSubview:infoPanel];
    self.infoPanel = infoPanel;
    [infoPanel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.majorImageView.mas_right).offset(12);
        make.top.mas_equalTo(self.majorImageView);
        make.bottom.mas_equalTo(self.bottomView.mas_top);
        make.height.mas_equalTo(@91);
        make.right.mas_equalTo(self.contentView).mas_offset(-15);
    }];
    
    [infoPanel addSubview:self.majorTitle];
    [self.majorTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(infoPanel);
        make.height.mas_equalTo(@22);
    }];
    
    [infoPanel addSubview:self.extendTitle];
    [self.extendTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(infoPanel);
        make.top.mas_equalTo(self.majorTitle.mas_bottom).mas_offset(4);
        make.height.mas_equalTo(@17);
    }];
    
    [infoPanel addSubview:self.areaLabel];
    [self.areaLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(infoPanel);
        make.top.mas_equalTo(self.extendTitle.mas_bottom).mas_offset(5);
        make.height.mas_equalTo(@15);
    }];
    
    [infoPanel addSubview:self.priceLabel];
    [infoPanel addSubview:self.roomSpaceLabel];
    [infoPanel addSubview:self.originPriceLabel];
    
    [self.priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(infoPanel);
        make.top.mas_equalTo(self.areaLabel.mas_bottom).mas_offset(5);
        make.height.mas_equalTo(@24);
        make.width.mas_lessThanOrEqualTo(@130);
    }];
    
    [self.originPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.priceLabel.mas_right).mas_offset(6);
        make.height.mas_equalTo(@17);
        make.centerY.mas_equalTo(self.priceLabel);
    }];
    
    [self.roomSpaceLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.roomSpaceLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    
    [self.roomSpaceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.priceLabel.mas_right).mas_offset(7);
        make.centerY.mas_equalTo(self.priceLabel);
        make.height.mas_equalTo(@17);
    }];
    
    [infoPanel addSubview:self.imageTopLeftLabelBgView];
    [self.imageTopLeftLabelBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.majorImageView);
        make.top.mas_equalTo(self.majorImageView).mas_offset(0.5);
        make.height.mas_equalTo(@17);
        make.width.mas_lessThanOrEqualTo(@48);
    }];
    
    [self.imageTopLeftLabelBgView addSubview:self.imageTopLeftLabel];
    [self.imageTopLeftLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(@1);
        make.right.mas_equalTo(@(-1));
        make.center.mas_equalTo(self.imageTopLeftLabelBgView);
    }];
    
    
}

-(void)refreshTopMargin:(CGFloat)top {
    
    if (top == self.topMargin) {
        return;
    }
    self.topMargin = top;
    [self.headView mas_updateConstraints:^(MASConstraintMaker *make) {
        
        make.height.mas_equalTo(@(self.topMargin));
    }];
}

-(void)refreshBottomMargin:(CGFloat)bottom {
    
    if (bottom == self.bottomMargin) {
        return;
    }
    self.bottomMargin = bottom;
    [self.bottomView mas_updateConstraints:^(MASConstraintMaker *make) {
        
        make.height.mas_equalTo(@(self.bottomMargin));
    }];

}


-(void)updateOriginPriceLabelConstraints:(NSString *)originPriceText {

    if (originPriceText.length > 0) {
        
        NSMutableAttributedString *attri = [[NSMutableAttributedString alloc] initWithString:originPriceText];
        [attri addAttribute:NSStrikethroughStyleAttributeName value:@(NSUnderlineStyleSingle) range:NSMakeRange(0, originPriceText.length)];
        [attri addAttribute:NSStrikethroughColorAttributeName value:[UIColor themeGray] range:NSMakeRange(0, originPriceText.length)];
        self.originPriceLabel.attributedText = attri;

        CGFloat offset = [TTDeviceHelper isScreenWidthLarge320] ? 20 : 15;
        self.originPriceLabel.hidden = NO;
//        self.originPriceLabel.text = originPriceText;
        [self.originPriceLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.priceLabel.mas_right).mas_offset(6);
            make.height.mas_equalTo(@17);
            make.centerY.mas_equalTo(self.priceLabel);
        }];
        [self.roomSpaceLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.originPriceLabel.mas_right).mas_offset(offset);
            make.centerY.mas_equalTo(self.priceLabel);
            make.height.mas_equalTo(@17);
        }];
        
    }else {
        
        self.originPriceLabel.hidden = YES;
        [self.roomSpaceLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.priceLabel.mas_right).mas_offset(7);
            make.centerY.mas_equalTo(self.priceLabel).mas_offset(1);
            make.height.mas_equalTo(@17);
        }];
    }
    
}

-(void)updateLayoutCompoents:(BOOL)isShowTags {

    if (isShowTags) {
        
        self.majorTitle.numberOfLines = 1;
        [self.majorTitle mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(self.infoPanel);
            make.top.mas_equalTo(self.infoPanel).mas_offset(-3);
            make.height.mas_equalTo(@20);
        }];
        [self.extendTitle mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(self.infoPanel);
            make.top.mas_equalTo(self.majorTitle.mas_bottom).mas_offset(4);
            make.height.mas_equalTo(@17);
        }];
        
    }else {
        
        self.majorTitle.numberOfLines = 2;
        CGSize fitSize = [self.majorTitle sizeThatFits:CGSizeMake([UIScreen mainScreen].bounds.size.width * ([UIScreen mainScreen].bounds.size.width > 376 ? 0.61 : [UIScreen mainScreen].bounds.size.width > 321 ? 0.56 : 0.48), 0)];
        [self.majorTitle mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.mas_equalTo(self.infoPanel);
            make.top.mas_equalTo(self.infoPanel).mas_offset(fitSize.height < 30 ? 0 : -5);
            make.height.mas_equalTo(fitSize.height < 30 ? @20 : @50);
        }];
        [self.extendTitle mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(self.infoPanel);
            make.top.mas_equalTo(self.majorTitle.mas_bottom).mas_offset(fitSize.height < 30 ? 4 : 1);
            make.height.mas_equalTo(@17);
        }];
        [self.areaLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(self.infoPanel);
            make.top.mas_equalTo(self.extendTitle.mas_bottom).mas_offset(0);
            make.height.mas_equalTo(@0);
        }];
        [self.priceLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.infoPanel);
            make.top.mas_equalTo(self.areaLabel.mas_bottom).mas_offset(0);
            make.height.mas_equalTo(@24);
            make.width.mas_lessThanOrEqualTo(@130);
        }];
        
        
    }

}

-(void)prepareForReuse {

    [super prepareForReuse];

    self.imageTopLeftLabel.text = nil;
    self.imageTopLeftLabelBgView.hidden = YES;

//    [self.majorTitle mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.left.right.top.mas_equalTo(self.infoPanel);
//        make.height.mas_equalTo(@20);
//    }];
//    [self.extendTitle mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.left.right.mas_equalTo(self.infoPanel);
//        make.top.mas_equalTo(self.majorTitle.mas_bottom).mas_offset(4);
//        make.height.mas_equalTo(@17);
//    }];
//    [self.areaLabel mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.left.right.mas_equalTo(self.infoPanel);
//        make.top.mas_equalTo(self.extendTitle.mas_bottom).mas_offset(5);
//        make.height.mas_equalTo(@15);
//    }];
//    [self.priceLabel mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(self.infoPanel);
//        make.top.mas_equalTo(self.areaLabel.mas_bottom).mas_offset(5);
//        make.height.mas_equalTo(@24);
//        make.width.mas_lessThanOrEqualTo(@130);
//    }];

}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
    return YES;
}

#pragma mark 二手房
- (void)updateWithModel:(FHSearchHouseDataItemsModel *)model isLastCell:(BOOL)isLastCell {
    
    self.majorTitle.text = model.displayTitle;
    self.extendTitle.text = model.displaySubtitle;
    self.isTail = isLastCell;
    
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc]init];
    if (model.tags.count > 0) {
        
        NSMutableArray *attrTexts = [NSMutableArray array];
        
        [model.tags enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            FHSearchHouseDataItemsTagsModel *element = obj;
            if (element.content && element.textColor && element.backgroundColor) {
                
                UIColor *textColor = [UIColor colorWithHexString:element.textColor] ? : [UIColor colorWithHexString:@"#f85959"];
                UIColor *backgroundColor = [UIColor colorWithHexString:element.backgroundColor] ? : [UIColor colorWithRed:248/255.0 green:89/255.0 blue:89/255.0 alpha:0.08];
                NSAttributedString *attr = [self createTagAttrString:element.content isFirst:idx == 0 textColor:textColor backgroundColor:backgroundColor];
                [attrTexts addObject:attr];
            }
        }];
        
        __block CGFloat height = 0;
        [attrTexts enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            NSAttributedString *attr = obj;
            [text appendAttributedString:attr];
            
            YYTextLayout *tagLayout = [YYTextLayout layoutWithContainerSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - 170, CGFLOAT_MAX) text:text];
            CGFloat lineHeight = tagLayout.textBoundingSize.height;
            if (lineHeight > height) {
                
                if (idx != 0) {
                    [text deleteCharactersInRange:NSMakeRange(text.length - attr.length, attr.length)];
                }
                if (idx == 0) {
                    height = lineHeight;
                }
            }
        }];
        
    }
    self.areaLabel.attributedText = text;
    [self.areaLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.infoPanel).mas_offset(-3);
    }];
    self.priceLabel.text = model.displayPrice;
    self.roomSpaceLabel.text = model.displayPricePerSqm;
    FHSearchHouseDataItemsHouseImageModel *imageModel = model.houseImage.firstObject;
    [self.majorImageView bd_setImageWithURL:[NSURL URLWithString:imageModel.url] placeholder:[UIImage imageNamed: @"default_image"]];
    
    if (model.houseImageTag.text && model.houseImageTag.backgroundColor && model.houseImageTag.textColor) {
        
        self.imageTopLeftLabel.textColor = [UIColor colorWithHexString:model.houseImageTag.textColor];
        self.imageTopLeftLabel.text = model.houseImageTag.text;
        self.imageTopLeftLabelBgView.backgroundColor = [UIColor colorWithHexString:model.houseImageTag.backgroundColor];
        self.imageTopLeftLabelBgView.hidden = NO;
    }else {
        
        self.imageTopLeftLabelBgView.hidden = YES;
    }

    [self updateOriginPriceLabelConstraints:model.originPrice];
    [self updateLayoutCompoents:text.string.length > 0];
    
}

#pragma mark 新房
-(void)updateWithNewHouseModel:(FHNewHouseItemModel *)model isFirstCell:(BOOL)isFirstCell isLastCell:(BOOL)isLastCell {
    
    self.majorTitle.text = model.displayTitle;
    self.extendTitle.text = model.displayDescription;

    NSMutableAttributedString *text = [[NSMutableAttributedString alloc]init];
    if (model.tags.count > 0) {
        
        NSMutableArray *attrTexts = [NSMutableArray array];
        
        [model.tags enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            FHSearchHouseDataItemsTagsModel *element = obj;
            if (element.content && element.textColor && element.backgroundColor) {
                
                UIColor *textColor = [UIColor colorWithHexString:element.textColor] ? : [UIColor colorWithHexString:@"#f85959"];
                UIColor *backgroundColor = [UIColor colorWithHexString:element.backgroundColor] ? : [UIColor colorWithRed:248/255.0 green:89/255.0 blue:89/255.0 alpha:0.08];
                NSAttributedString *attr = [self createTagAttrString:element.content isFirst:idx == 0 textColor:textColor backgroundColor:backgroundColor];
                [attrTexts addObject:attr];
            }
        }];
        
        __block CGFloat height = 0;
        [attrTexts enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            NSAttributedString *attr = obj;
            [text appendAttributedString:attr];
            
            YYTextLayout *tagLayout = [YYTextLayout layoutWithContainerSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - 170, CGFLOAT_MAX) text:text];
            CGFloat lineHeight = tagLayout.textBoundingSize.height;
            if (lineHeight > height) {
                
                if (idx != 0) {
                    [text deleteCharactersInRange:NSMakeRange(text.length - attr.length, attr.length)];
                }
                if (idx == 0) {
                    height = lineHeight;
                }
            }
        }];
        
    }
    self.areaLabel.attributedText = text;
    [self.areaLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.infoPanel).mas_offset(-3);
    }];
    self.priceLabel.text = model.displayPricePerSqm;
    self.roomSpaceLabel.text = model.displayPricePerSqm;
    FHSearchHouseDataItemsHouseImageModel *imageModel = model.images.firstObject;
    [self.majorImageView bd_setImageWithURL:[NSURL URLWithString:imageModel.url] placeholder:[UIImage imageNamed: @"default_image"]];
    
    [self updateOriginPriceLabelConstraints:nil];
    [self updateLayoutCompoents:text.string.length > 0];
    
}

#pragma mark 二手房
-(void)updateWithSecondHouseModel:(FHSearchHouseDataItemsModel *)model isFirstCell:(BOOL)isFirstCell isLastCell:(BOOL)isLastCell {
    
    self.majorTitle.text = model.displayTitle;
    self.extendTitle.text = model.displaySubtitle;

    NSMutableAttributedString *text = [[NSMutableAttributedString alloc]init];
    if (model.tags.count > 0) {

        NSMutableArray *attrTexts = [NSMutableArray array];

        [model.tags enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {

            FHSearchHouseDataItemsTagsModel *element = obj;
            if (element.content && element.textColor && element.backgroundColor) {

                UIColor *textColor = [UIColor colorWithHexString:element.textColor] ? : [UIColor colorWithHexString:@"#f85959"];
                UIColor *backgroundColor = [UIColor colorWithHexString:element.backgroundColor] ? : [UIColor colorWithRed:248/255.0 green:89/255.0 blue:89/255.0 alpha:0.08];
                NSAttributedString *attr = [self createTagAttrString:element.content isFirst:idx == 0 textColor:textColor backgroundColor:backgroundColor];
                [attrTexts addObject:attr];
            }
        }];

        __block CGFloat height = 0;
        [attrTexts enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {

            NSAttributedString *attr = obj;
            [text appendAttributedString:attr];

            YYTextLayout *tagLayout = [YYTextLayout layoutWithContainerSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - 170, CGFLOAT_MAX) text:text];
            CGFloat lineHeight = tagLayout.textBoundingSize.height;
            if (lineHeight > height) {

                if (idx != 0) {
                    [text deleteCharactersInRange:NSMakeRange(text.length - attr.length, attr.length)];
                }
                if (idx == 0) {
                    height = lineHeight;
                }
            }
        }];

    }
    self.areaLabel.attributedText = text;
    [self.areaLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.infoPanel).mas_offset(-3);
    }];
    self.priceLabel.text = model.displayPrice;
    self.roomSpaceLabel.text = model.displayPricePerSqm;
    FHSearchHouseDataItemsHouseImageModel *imageModel = model.houseImage.firstObject;
    [self.majorImageView bd_setImageWithURL:[NSURL URLWithString:imageModel.url] placeholder:[UIImage imageNamed: @"default_image"]];
    
    if (model.houseImageTag.text && model.houseImageTag.backgroundColor && model.houseImageTag.textColor) {
        
        self.imageTopLeftLabel.textColor = [UIColor colorWithHexString:model.houseImageTag.textColor];
        self.imageTopLeftLabel.text = model.houseImageTag.text;
        self.imageTopLeftLabel.backgroundColor = [UIColor colorWithHexString:model.houseImageTag.backgroundColor];
        self.imageTopLeftLabelBgView.hidden = NO;
    }else {
        
        self.imageTopLeftLabelBgView.hidden = YES;
    }
    
    [self updateOriginPriceLabelConstraints:model.originPrice];
    [self updateLayoutCompoents:text.string.length > 0];
    
}

#pragma mark 租房
-(void)updateWithRentHouseModel:(FHHouseRentDataItemsModel *)model  isFirstCell:(BOOL)isFirstCell isLastCell:(BOOL)isLastCell {
    
    self.majorTitle.text = model.title;
    self.extendTitle.text = model.subtitle;
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc]init];
    if (model.tags.count > 0) {
        
        NSMutableArray *attrTexts = [NSMutableArray array];

        [model.tags enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            FHSearchHouseDataItemsTagsModel *element = obj;
            if (element.content && element.textColor && element.backgroundColor) {
                
                UIColor *textColor = [UIColor colorWithHexString:element.textColor] ? : [UIColor colorWithHexString:@"#f85959"];
                UIColor *backgroundColor = [UIColor colorWithHexString:element.backgroundColor] ? : [UIColor colorWithRed:248/255.0 green:89/255.0 blue:89/255.0 alpha:0.08];
                NSAttributedString *attr = [self createTagAttrString:element.content isFirst:idx == 0 textColor:textColor backgroundColor:backgroundColor];
                [attrTexts addObject:attr];
            }
        }];
        
        __block CGFloat height = 0;
        [attrTexts enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            NSAttributedString *attr = obj;
            [text appendAttributedString:attr];
            
            YYTextLayout *tagLayout = [YYTextLayout layoutWithContainerSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - 170, CGFLOAT_MAX) text:text];
            CGFloat lineHeight = tagLayout.textBoundingSize.height;
            if (lineHeight > height) {
                
                if (idx != 0) {
                    [text deleteCharactersInRange:NSMakeRange(text.length - attr.length, attr.length)];
                }
                if (idx == 0) {
                    height = lineHeight;
                }
            }
        }];
        
    }
    self.areaLabel.attributedText = text;
    [self.areaLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.infoPanel).mas_offset(-3);
    }];
    self.priceLabel.text = model.pricing;
    self.roomSpaceLabel.text = nil;
    FHHouseRentDataItemsHouseImageModel *imageModel = [model.houseImage firstObject];
    [self.majorImageView bd_setImageWithURL:[NSURL URLWithString:imageModel.url] placeholder:[UIImage imageNamed: @"default_image"]];
    
    if (model.houseImageTag.text && model.houseImageTag.backgroundColor && model.houseImageTag.textColor) {
        
        self.imageTopLeftLabel.textColor = [UIColor colorWithHexString:model.houseImageTag.textColor];
        self.imageTopLeftLabel.text = model.houseImageTag.text;
        self.imageTopLeftLabel.backgroundColor = [UIColor colorWithHexString:model.houseImageTag.backgroundColor];
        self.imageTopLeftLabelBgView.hidden = NO;
    }else {
        
        self.imageTopLeftLabelBgView.hidden = YES;
    }
    
    [self updateOriginPriceLabelConstraints:nil];
    [self updateLayoutCompoents:text.string.length > 0];
    
}

#pragma mark 小区
- (void)updateWithNeighborModel:(FHHouseNeighborDataItemsModel *)model {
    
    self.majorTitle.text = model.displayTitle;
    self.extendTitle.text = model.displaySubtitle;
    self.areaLabel.text = model.displayStatsInfo;
    self.priceLabel.text = model.displayPrice;
    FHHouseNeighborDataItemsImagesModel *imageModel = model.images.firstObject;
    [self.majorImageView bd_setImageWithURL:[NSURL URLWithString:imageModel.url] placeholder:[UIImage imageNamed: @"default_image"]];

    self.imageTopLeftLabelBgView.hidden = YES;
    [self updateOriginPriceLabelConstraints:nil];
}

-(void)updateWithHouseModel:(JSONModel *)model isFirstCell:(BOOL)isFirstCell isLastCell:(BOOL)isLastCell {
    
    if ([model isKindOfClass:[FHNewHouseItemModel class]]) {
        
        FHNewHouseItemModel *theModel = (FHNewHouseItemModel *)model;
        [self updateWithNewHouseModel:theModel isFirstCell:isFirstCell isLastCell:isLastCell];
        
    }else if ([model isKindOfClass:[FHSearchHouseDataItemsModel class]]) {
        
        FHSearchHouseDataItemsModel *theModel = (FHSearchHouseDataItemsModel *)model;
        [self updateWithSecondHouseModel:theModel isFirstCell:isFirstCell isLastCell:isLastCell];
        
    }else if ([model isKindOfClass:[FHHouseRentDataItemsModel class]]) {
        
        FHHouseRentDataItemsModel *theModel = (FHHouseRentDataItemsModel *)model;
        [self updateWithRentHouseModel:model isFirstCell:isFirstCell isLastCell:isLastCell];
        
    }
    else if ([model isKindOfClass:[FHHouseNeighborDataItemsModel class]]) {

        FHHouseNeighborDataItemsModel *theModel = (FHHouseNeighborDataItemsModel *)model;
        [self updateWithNeighborModel:theModel];

    }
}

-(NSAttributedString *)createTagAttrString:(NSString *)text isFirst:(BOOL)isFirst textColor:(UIColor *)textColor backgroundColor:(UIColor *)backgroundColor {

    NSMutableAttributedString *attributeText = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"  %@  ",text]];
    attributeText.yy_font = [UIFont themeFontRegular:10];
    attributeText.yy_color = textColor;
    NSRange substringRange = [attributeText.string rangeOfString:text];
    [attributeText yy_setTextBinding:[YYTextBinding bindingWithDeleteConfirm:NO] range:substringRange];
    YYTextBorder *border = [YYTextBorder borderWithFillColor:backgroundColor cornerRadius:2];
    [border setInsets:UIEdgeInsetsMake(0, -4, 0, -4)];

    [attributeText yy_setTextBackgroundBorder:border range:substringRange];
    return attributeText;
    
}

-(void)setIsFirstCell:(BOOL)isFirstCell {
    
    _isFirstCell = isFirstCell;
    
    if (self.headView.superview == nil) {
        return;
    }
    CGFloat height = isFirstCell ? 0 : 14;
    [self.headView mas_updateConstraints:^(MASConstraintMaker *make) {
        
        make.height.mas_equalTo(@(height));
    }];
    [self updateConstraintsIfNeeded];
}

-(void)setIsTail:(BOOL)isTail {
    
    _isTail = isTail;
    
    if (self.bottomView.superview == nil) {
        return;
    }
    CGFloat height = isTail ? 20 : 0;
    [self.bottomView mas_updateConstraints:^(MASConstraintMaker *make) {
        
        make.height.mas_equalTo(@(height));
    }];
    [self updateConstraintsIfNeeded];
}

-(UIImageView *)majorImageView {
    
    if (!_majorImageView) {
        
        _majorImageView = [[UIImageView alloc]init];
        _majorImageView.contentMode = UIViewContentModeScaleAspectFill;
        _majorImageView.layer.cornerRadius = 4;
        _majorImageView.clipsToBounds = YES;
        _majorImageView.layer.borderWidth = 0.5;
        _majorImageView.layer.borderColor = [UIColor themeGray6].CGColor;
        
    }
    return _majorImageView;
}

-(UILabel *)majorTitle {
    
    if (!_majorTitle) {
        
        _majorTitle = [[UILabel alloc]init];
        _majorTitle.font = [UIFont themeFontRegular:16];
        _majorTitle.textColor = [UIColor themeBlack];
    }
    return _majorTitle;
}

-(UILabel *)extendTitle {
    
    if (!_extendTitle) {
        
        _extendTitle = [[UILabel alloc]init];
        _extendTitle.font = [UIFont themeFontRegular:12];
        _extendTitle.textColor = [UIColor themeGray2];
    }
    return _extendTitle;
}

-(YYLabel *)areaLabel {
    
    if (!_areaLabel) {
        
        _areaLabel = [[YYLabel alloc]init];
        _areaLabel.numberOfLines = 0;
        _areaLabel.font = [UIFont themeFontRegular:12];
        _areaLabel.textColor = [UIColor themeGray2];
        _areaLabel.lineBreakMode = NSLineBreakByWordWrapping;
    }
    return _areaLabel;
}

-(UILabel *)priceLabel {
    
    if (!_priceLabel) {
        
        _priceLabel = [[UILabel alloc]init];
        _priceLabel.font = [UIFont themeFontMedium:14];
        _priceLabel.textColor = [UIColor themeRed];
    }
    return _priceLabel;
}

-(UILabel *)originPriceLabel {
    
    if (!_originPriceLabel) {
        
        _originPriceLabel = [[UILabel alloc]init];
        if ([TTDeviceHelper isScreenWidthLarge320]) {
            
            _originPriceLabel.font = [UIFont themeFontRegular:12];
        }else {
            _originPriceLabel.font = [UIFont themeFontRegular:10];
        }
        _originPriceLabel.textColor = [UIColor themeGray];
        _originPriceLabel.hidden = YES;
    }
    return _originPriceLabel;
}

-(UILabel *)roomSpaceLabel {
    
    if (!_roomSpaceLabel) {
        
        _roomSpaceLabel = [[UILabel alloc]init];
        if ([TTDeviceHelper isScreenWidthLarge320]) {
            
            _roomSpaceLabel.font = [UIFont themeFontRegular:12];
        }else {
            _roomSpaceLabel.font = [UIFont themeFontRegular:10];
        }
        _roomSpaceLabel.textColor = [UIColor themeGray];
    }
    return _roomSpaceLabel;
}

-(UIView *)headView {
    
    if (!_headView) {
        
        _headView = [[UIView alloc]init];
    }
    return _headView;
}

-(UIView *)bottomView {
    
    if (!_bottomView) {
        
        _bottomView = [[UIView alloc]init];
    }
    return _bottomView;
}

-(UILabel *)imageTopLeftLabel {
    
    if (!_imageTopLeftLabel) {
        
        _imageTopLeftLabel = [[UILabel alloc]init];
        _imageTopLeftLabel.text = @"新上";
        _imageTopLeftLabel.textAlignment = NSTextAlignmentCenter;
        _imageTopLeftLabel.font = [UIFont themeFontRegular:10];
        _imageTopLeftLabel.textColor = [UIColor whiteColor];
    }
    return _imageTopLeftLabel;
}

-(FHCornerView *)imageTopLeftLabelBgView {
    
    if (!_imageTopLeftLabelBgView) {
        
        _imageTopLeftLabelBgView = [[FHCornerView alloc]init];
        _imageTopLeftLabelBgView.backgroundColor = [UIColor themeRed];
        _imageTopLeftLabelBgView.hidden = YES;
    }
    return _imageTopLeftLabelBgView;
}


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
