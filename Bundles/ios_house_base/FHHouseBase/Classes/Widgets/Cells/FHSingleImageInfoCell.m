//
//  FHSingleImageInfoCell.m
//  FHHouseBase
//
//  Created by 谷春晖 on 2018/11/18.
//
#if 0
#import "FHSingleImageInfoCell.h"
#import "UIColor+Theme.h"
#import "UIFont+House.h"
#import <YYText/YYText.h>
#import "TTDeviceHelper.h"
#import "Masonry.h"
#import "FHHouseSingleImageInfoCellBridgeDelegate.h"
#import "UIImageView+BDWebImage.h"
#import "FHCornerView.h"
#import "FHSingleImageInfoCellModel.h"
#import "FHHomeHouseModel.h"
#import "FHHouseRecommendReasonView.h"

@interface FHSingleImageInfoCell () <FHHouseSingleImageInfoCellBridgeDelegate>

@property(nonatomic, strong) FHSingleImageInfoCellModel *cellModel;

@property(nonatomic, strong) UIImageView *majorImageView;
@property(nonatomic, strong) UILabel *majorTitle;
@property(nonatomic, strong) UILabel *extendTitle;
@property(nonatomic, strong) YYLabel *areaLabel;
@property(nonatomic, strong) UILabel *priceLabel;
@property(nonatomic, strong) UILabel *originPriceLabel;
@property(nonatomic, strong) UILabel *roomSpaceLabel;
@property(nonatomic, strong) FHHouseRecommendReasonView *recommendReasonView;

@property(nonatomic, weak) UIView *infoPanel;

@property(nonatomic, strong) UIView *headView;
@property(nonatomic, strong) UIView *bottomView;

@property(nonatomic, strong) UILabel *imageTopLeftLabel;
@property(nonatomic, strong) FHCornerView *imageTopLeftLabelBgView;

@property(nonatomic, assign) CGFloat topMargin;
@property(nonatomic, assign) CGFloat bottomMargin;
@property(nonatomic, assign) BOOL lastShowTag;

@end

@implementation FHSingleImageInfoCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.topMargin = 20;
        self.bottomMargin = 10;
        self.selectionStyle = UITableViewCellSelectionStyleNone;

        [self setupUI];
    }
    return self;
    
}

-(void)setupUI {
    
    [self.contentView addSubview:self.headView];
    [self.headView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.right.top.mas_equalTo(self.contentView);
        make.height.mas_equalTo(@(self.topMargin));
    }];
    
    [self.contentView addSubview:self.bottomView];
    
    [self.contentView addSubview:self.majorImageView];
    [self.majorImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.mas_equalTo(@20);
        make.top.mas_equalTo(self.headView.mas_bottom);
        make.width.mas_equalTo(@114);
        make.height.mas_equalTo(85);

    }];
    
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.mas_equalTo(self.majorImageView.mas_bottom);
        make.left.right.bottom.mas_equalTo(self.contentView);
        make.height.mas_equalTo(@(self.bottomMargin));
    }];
    
    UIView *infoPanel = [[UIView alloc]init];
    [self.contentView addSubview:infoPanel];
    self.infoPanel = infoPanel;
    [infoPanel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.majorImageView.mas_right).offset(12);
        make.top.mas_equalTo(self.majorImageView);
        make.bottom.mas_equalTo(self.contentView);
        make.right.mas_equalTo(self.contentView).mas_offset(-15);
    }];
    
    [infoPanel addSubview:self.majorTitle];
    [self.majorTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(infoPanel);
        make.top.mas_equalTo(infoPanel).mas_offset(-3);
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
        make.left.mas_equalTo(infoPanel).mas_offset(-3);
        make.right.mas_equalTo(infoPanel);
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
        make.top.mas_equalTo(self.majorImageView).mas_offset(0);
        make.height.mas_equalTo(@17);
        make.width.mas_equalTo(@48);
    }];
    
    [self.imageTopLeftLabelBgView addSubview:self.imageTopLeftLabel];
    [self.imageTopLeftLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(@0);
        make.right.mas_equalTo(@0);
        make.center.mas_equalTo(self.imageTopLeftLabelBgView);
    }];
    
    [self.infoPanel addSubview:self.recommendReasonView];
    [self.recommendReasonView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(infoPanel);
        make.right.mas_equalTo(infoPanel);
        make.top.mas_equalTo(self.priceLabel.mas_bottom).offset(2);
        make.height.mas_equalTo(16);
    }];
    self.recommendReasonView.hidden = YES;
    
    _lastShowTag = YES;

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
    
//    if (bottom == 0) {
//        [self.majorImageView mas_updateConstraints:^(MASConstraintMaker *make) {
//            make.left.mas_equalTo(@20);
//            make.top.mas_equalTo(self.headView.mas_bottom);
//            make.bottom.mas_equalTo(self.contentView);
//            make.width.mas_equalTo(@114);
//        }];
//    }
}


-(void)updateOriginPriceLabelConstraints:(NSAttributedString *)originPriceAttrStr {

    if (originPriceAttrStr.string.length > 0) {

        self.originPriceLabel.attributedText = originPriceAttrStr;
        CGFloat offset = [TTDeviceHelper isScreenWidthLarge320] ? 20 : 15;
        self.originPriceLabel.hidden = NO;
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

-(void)updateLayoutComponents:(BOOL)isShowTags {

    if (_lastShowTag && isShowTags) {
        //没有变更不需要改变
        return;
    }
    _lastShowTag = isShowTags;
    
    CGSize fitSize = self.cellModel.titleSize;
    self.majorTitle.numberOfLines = isShowTags ? 1 : 2;

    if (isShowTags) {
        
        [self.majorTitle mas_updateConstraints:^(MASConstraintMaker *make) {
            
            make.top.mas_equalTo(self.infoPanel).mas_offset(-3);
            make.height.mas_equalTo(@22);
        }];
        
    }else {
        
        [self.majorTitle mas_updateConstraints:^(MASConstraintMaker *make) {
            
            make.top.mas_equalTo(self.infoPanel).mas_offset(fitSize.height < 30 ? -3 : -6);
            make.height.mas_equalTo(fitSize.height < 30 ? @22 : @50);
        }];
    }
    
    [self.extendTitle mas_updateConstraints:^(MASConstraintMaker *make) {
        
        make.top.mas_equalTo(self.majorTitle.mas_bottom).mas_offset(fitSize.height < 30 ? 4 : 1);
    }];
    
    [self.areaLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        
        make.top.mas_equalTo(self.extendTitle.mas_bottom).mas_offset(isShowTags ? 5 : 0);
        make.height.mas_equalTo(isShowTags ? @15 : @0);
    }];
    
    [self.priceLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        
        make.top.mas_equalTo(self.areaLabel.mas_bottom).mas_offset(isShowTags ? 5 : 0);
    }];

}

-(void)prepareForReuse {

    [super prepareForReuse];

    self.imageTopLeftLabel.text = nil;
    self.imageTopLeftLabelBgView.hidden = YES;

}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
    return YES;
}

#pragma mark 首页

-(void)updateHomeHouseCellModel:(FHHomeHouseDataItemsModel *)commonModel andType:(FHHouseType)houseType
{
    self.majorTitle.text = commonModel.displayTitle;
    self.extendTitle.text = commonModel.displayDescription;
    NSMutableAttributedString * attributeString =  [FHSingleImageInfoCellModel  tagsStringWithTagList:commonModel.tags];
    self.areaLabel.attributedText =  attributeString;
    
    self.priceLabel.text = commonModel.displayPricePerSqm;
    FHSearchHouseDataItemsHouseImageModel *imageModel = commonModel.images.firstObject;
    [self.majorImageView bd_setImageWithURL:[NSURL URLWithString:imageModel.url] placeholder:[UIImage imageNamed: @"default_image"]];
    
    if (houseType == FHHouseTypeSecondHandHouse) {
        FHHomeHouseDataItemsImagesModel *imageModel = commonModel.houseImage.firstObject;
        [self.majorImageView bd_setImageWithURL:[NSURL URLWithString:imageModel.url] placeholder:[UIImage imageNamed: @"default_image"]];
        self.extendTitle.text = commonModel.displaySubtitle;
        self.priceLabel.text = commonModel.displayPrice;
        self.roomSpaceLabel.text = commonModel.displayPricePerSqm;
        if (commonModel.houseImageTag.text && commonModel.houseImageTag.backgroundColor && commonModel.houseImageTag.textColor) {
            
            self.imageTopLeftLabel.textColor = [UIColor colorWithHexString:commonModel.houseImageTag.textColor];
            self.imageTopLeftLabel.text = commonModel.houseImageTag.text;
            self.imageTopLeftLabelBgView.backgroundColor = [UIColor colorWithHexString:commonModel.houseImageTag.backgroundColor];
            self.imageTopLeftLabelBgView.hidden = NO;
        }else {
            
            self.imageTopLeftLabelBgView.hidden = YES;
        }
        
        [self updateOriginPriceLabelConstraints:self.cellModel.originPriceAttrStr];
    }else if(houseType == FHHouseTypeRentHouse)
    {
        self.majorTitle.text = commonModel.title;
        self.extendTitle.text = commonModel.subtitle;
        self.priceLabel.text = commonModel.pricing;
        self.roomSpaceLabel.text = nil;
        FHSearchHouseDataItemsHouseImageModel *imageModel = [commonModel.houseImage firstObject];
        [self.majorImageView bd_setImageWithURL:[NSURL URLWithString:imageModel.url] placeholder:[UIImage imageNamed: @"default_image"]];
        
        if (commonModel.houseImageTag.text && commonModel.houseImageTag.backgroundColor && commonModel.houseImageTag.textColor) {
            
            self.imageTopLeftLabel.textColor = [UIColor colorWithHexString:commonModel.houseImageTag.textColor];
            self.imageTopLeftLabel.text = commonModel.houseImageTag.text;
            self.imageTopLeftLabelBgView.backgroundColor = [UIColor colorWithHexString:commonModel.houseImageTag.backgroundColor];
            self.imageTopLeftLabelBgView.hidden = NO;
        }else {
            
            self.imageTopLeftLabelBgView.hidden = YES;
        }
        
        [self updateOriginPriceLabelConstraints:nil];
    }
    else
    {
         self.roomSpaceLabel.text = @"";
        [self updateOriginPriceLabelConstraints:nil];
    }
    
    [self updateLayoutComponents:attributeString.string.length > 0];
}

#pragma mark 二手房
- (void)updateWithModel:(FHSearchHouseDataItemsModel *)model isLastCell:(BOOL)isLastCell {
    
    self.majorTitle.text = model.displayTitle;
    self.extendTitle.text = model.displaySubtitle;
    
    self.areaLabel.attributedText = self.cellModel.tagsAttrStr;

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

    [self updateOriginPriceLabelConstraints:self.cellModel.originPriceAttrStr];
    [self updateLayoutComponents:self.cellModel.tagsAttrStr.string.length > 0];
    
}

#pragma mark 新房
-(void)updateWithNewHouseModel:(FHNewHouseItemModel *)model {
    
    self.majorTitle.text = model.displayTitle;
    self.extendTitle.text = model.displayDescription;
    self.areaLabel.attributedText = self.cellModel.tagsAttrStr;

    self.priceLabel.text = model.displayPricePerSqm;
    FHSearchHouseDataItemsHouseImageModel *imageModel = model.images.firstObject;
    [self.majorImageView bd_setImageWithURL:[NSURL URLWithString:imageModel.url] placeholder:[UIImage imageNamed: @"default_image"]];
    
    [self updateOriginPriceLabelConstraints:nil];
    [self updateLayoutComponents:self.cellModel.tagsAttrStr.string.length > 0];
    
}

//新房周边新房
// 子类需要重写的方法，根据数据源刷新当前Cell，以及布局
- (void)refreshWithData:(id)data
{
    if([data isKindOfClass:[FHNewHouseItemModel class]])
    {
        FHNewHouseItemModel *model = (FHNewHouseItemModel *)data;
        self.majorTitle.text = model.displayTitle;
        self.extendTitle.text = model.displayDescription;
        self.areaLabel.attributedText = self.cellModel.tagsAttrStr;
        NSMutableAttributedString * attributeString =  [FHSingleImageInfoCellModel tagsStringWithTagList:model.tags];
        self.areaLabel.attributedText =  attributeString;
        
        self.priceLabel.text = model.displayPricePerSqm;
        FHSearchHouseDataItemsHouseImageModel *imageModel = model.images.firstObject;
        [self.majorImageView bd_setImageWithURL:[NSURL URLWithString:imageModel.url] placeholder:[UIImage imageNamed: @"default_image"]];
        
        [self updateOriginPriceLabelConstraints:nil];
        [self updateLayoutComponents:self.areaLabel.attributedText.string.length > 0];
    }
}

#pragma mark 二手房
-(void)updateWithSecondHouseModel:(FHSearchHouseDataItemsModel *)model {
    
    self.majorTitle.text = model.displayTitle;
    self.extendTitle.text = model.displaySubtitle;
    self.areaLabel.attributedText = self.cellModel.tagsAttrStr;

    self.priceLabel.text = model.displayPrice;
    self.roomSpaceLabel.text = model.displayPricePerSqm;
    FHSearchHouseDataItemsHouseImageModel *imageModel = model.houseImage.firstObject;
    [self.majorImageView bd_setImageWithURL:[NSURL URLWithString:imageModel.url] placeholder:[UIImage imageNamed: @"default_image"]];
    
    if (model.recommendReasons.count > 0) {
        self.recommendReasonView.hidden = NO;
        [self.recommendReasonView setReasons:model.recommendReasons];
    }else{
        self.recommendReasonView.hidden = YES;
    }
    
    if (model.houseImageTag.text && model.houseImageTag.backgroundColor && model.houseImageTag.textColor) {
        
        self.imageTopLeftLabel.textColor = [UIColor colorWithHexString:model.houseImageTag.textColor];
        self.imageTopLeftLabel.text = model.houseImageTag.text;
        self.imageTopLeftLabelBgView.backgroundColor = [UIColor colorWithHexString:model.houseImageTag.backgroundColor];
        self.imageTopLeftLabelBgView.hidden = NO;
    }else {
        
        self.imageTopLeftLabelBgView.hidden = YES;
    }

    [self updateOriginPriceLabelConstraints:self.cellModel.originPriceAttrStr];
    [self updateLayoutComponents:self.cellModel.tagsAttrStr.string.length > 0];
    
}

#pragma mark 租房
-(void)updateWithRentHouseModel:(FHHouseRentDataItemsModel *)model {
    
    self.majorTitle.text = model.title;
    self.extendTitle.text = model.subtitle;
    self.areaLabel.attributedText = self.cellModel.tagsAttrStr;
    self.priceLabel.text = model.pricing;
    self.roomSpaceLabel.text = nil;
    FHSearchHouseDataItemsHouseImageModel *imageModel = [model.houseImage firstObject];
    [self.majorImageView bd_setImageWithURL:[NSURL URLWithString:imageModel.url] placeholder:[UIImage imageNamed: @"default_image"]];
    
    if (model.houseImageTag.text && model.houseImageTag.backgroundColor && model.houseImageTag.textColor) {
        
        self.imageTopLeftLabel.textColor = [UIColor colorWithHexString:model.houseImageTag.textColor];
        self.imageTopLeftLabel.text = model.houseImageTag.text;
        self.imageTopLeftLabelBgView.backgroundColor = [UIColor colorWithHexString:model.houseImageTag.backgroundColor];
        self.imageTopLeftLabelBgView.hidden = NO;
    }else {
        
        self.imageTopLeftLabelBgView.hidden = YES;
    }
    
    [self updateOriginPriceLabelConstraints:nil];
    [self updateLayoutComponents:self.cellModel.tagsAttrStr.string.length > 0];
    
}

#pragma mark 小区
- (void)updateWithNeighborModel:(FHHouseNeighborDataItemsModel *)model {
    
    self.majorTitle.text = model.displayTitle;
    self.extendTitle.text = model.displaySubtitle;
    self.areaLabel.text = model.displayStatsInfo;
    self.priceLabel.text = model.displayPrice;
    
    [self.areaLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.infoPanel);
    }];
    FHSearchHouseDataItemsHouseImageModel *imageModel = model.images.firstObject;
    [self.majorImageView bd_setImageWithURL:[NSURL URLWithString:imageModel.url] placeholder:[UIImage imageNamed: @"default_image"]];

    self.imageTopLeftLabelBgView.hidden = YES;
    [self updateOriginPriceLabelConstraints:nil];
}

-(void)updateWithHouseCellModel:(FHSingleImageInfoCellModel *)cellModel {
    
    BOOL isFirstCell = NO;
    BOOL isLastCell = NO;
    
    _cellModel = cellModel;

    switch (cellModel.houseType) {
        case FHHouseTypeNewHouse:
            
            [self updateWithNewHouseModel:cellModel.houseModel];
            break;
        case FHHouseTypeSecondHandHouse:
            [self updateWithSecondHouseModel:cellModel.secondModel];
            break;
        case FHHouseTypeRentHouse:
            [self updateWithRentHouseModel:cellModel.rentModel];
            break;
        case FHHouseTypeNeighborhood:
            [self updateWithNeighborModel:cellModel.neighborModel];
            break;
        default:
            break;
    }
    
    
}
-(void)updateWithHouseCellModel:(FHSingleImageInfoCellModel *)cellModel andIsFirst:(BOOL)isFirst andIsLast:(BOOL)isLast
{
    _cellModel = cellModel;
    CGFloat recommendHeight = 0;
    
    switch (cellModel.houseType) {
        case FHHouseTypeNewHouse:
            [self updateWithNewHouseModel:cellModel.houseModel];
            self.roomSpaceLabel.text = @"";
            break;
        case FHHouseTypeSecondHandHouse:
            [self updateWithSecondHouseModel:cellModel.secondModel];
            recommendHeight = [cellModel.secondModel showRecommendReason]?[FHSingleImageInfoCell recommendReasonHeight]:0;
            break;
        case FHHouseTypeRentHouse:
            [self updateWithRentHouseModel:cellModel.rentModel];
            break;
        case FHHouseTypeNeighborhood:
            [self updateWithNeighborModel:cellModel.neighborModel];
            break;
        default:
            break;
    }
    
    if (isFirst) {
        [self refreshTopMargin:5];
    }else
    {
        [self refreshTopMargin:20];
    }
    
    if (isLast) {
        [self refreshBottomMargin:20+recommendHeight];
    }else
    {
        [self refreshBottomMargin:recommendHeight];
    }
    
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
        _majorTitle.textColor = [UIColor themeGray1];
    }
    return _majorTitle;
}

-(UILabel *)extendTitle {
    
    if (!_extendTitle) {
        
        _extendTitle = [[UILabel alloc]init];
        _extendTitle.font = [UIFont themeFontRegular:12];
        _extendTitle.textColor = [UIColor themeGray3];
    }
    return _extendTitle;
}

-(YYLabel *)areaLabel {
    
    if (!_areaLabel) {
        
        _areaLabel = [[YYLabel alloc]init];
        _areaLabel.numberOfLines = 0;
        _areaLabel.font = [UIFont themeFontRegular:12];
        _areaLabel.textColor = [UIColor themeGray3];
        _areaLabel.lineBreakMode = NSLineBreakByWordWrapping;
    }
    return _areaLabel;
}

-(UILabel *)priceLabel {
    
    if (!_priceLabel) {
        
        _priceLabel = [[UILabel alloc]init];
        _priceLabel.font = [UIFont themeFontMedium:14];
        _priceLabel.textColor = [UIColor themeRed1];
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
        _originPriceLabel.textColor = [UIColor themeGray3];
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
        _roomSpaceLabel.textColor = [UIColor themeGray3];
    }
    return _roomSpaceLabel;
}

-(FHHouseRecommendReasonView *)recommendReasonView {
    
    if (!_recommendReasonView) {
        _recommendReasonView = [[FHHouseRecommendReasonView alloc] init];
    }
    return _recommendReasonView;
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
        _imageTopLeftLabelBgView.backgroundColor = [UIColor themeRed3];
        _imageTopLeftLabelBgView.hidden = YES;
    }
    return _imageTopLeftLabelBgView;
}

- (NSString *)elementTypeString:(FHHouseType)houseType {
    return @""; // 周边小区
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+(CGFloat)recommendReasonHeight
{
    return 22;
}

@end
#endif
