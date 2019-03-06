//
//  FHHouseBaseItemCell.m
//  FHHouseBase
//
//  Created by 春晖 on 2019/3/5.
//

#import "FHHouseBaseItemCell.h"
#import <HTSVideoPlay/UIView+Yoga.h>
#import <HTSVideoPlay/Yoga.h>
#import <YYText/YYLabel.h>
#import "FHCornerView.h"
#import <FHCommonUI/UIColor+Theme.h>
#import <FHCommonUI/UIFont+House.h>
#import <TTBaseLib/TTDeviceHelper.h>
#import <BDWebImage/UIImageView+BDWebImage.h>
#import "FHCommonDefines.h"
#import "FHSingleImageInfoCellModel.h"
#import "FHHomeHouseModel.h"
#import "FHHomeHouseModel.h"
#import "FHHouseRecommendReasonView.h"

#define MAIN_NORMAL_TOP 10
#define MAIN_FIRST_TOP 20
#define MAIN_IMG_WIDTH  114
#define MAIN_IMG_HEIGHT 85
#define MAIN_TAG_BG_WIDTH 48
#define MAIN_TAG_BG_HEIGHT 16
#define MAIN_TAG_WIDTH    40
#define MAIN_TAG_HEIGHT   10
#define INFO_TO_ICON_MARGIN 12

@interface FHHouseBaseItemCell ()

@property(nonatomic, strong) FHSingleImageInfoCellModel *cellModel;

@property(nonatomic, strong) UIView *leftInfoView;
@property(nonatomic, strong) UIImageView *mainImageView;
@property(nonatomic, strong) UILabel *imageTagLabel;
@property(nonatomic, strong) FHCornerView *imageTagLabelBgView;

@property(nonatomic, strong) UIView *rightInfoView;
@property(nonatomic, strong) UILabel *mainTitleLabel; //主title lable
@property(nonatomic, strong) UILabel *subTitleLabel; // sub title lable
@property(nonatomic, strong) UILabel *statInfoLabel; //新房状态信息
@property(nonatomic, strong) YYLabel *tagLabel; // 标签 label
@property(nonatomic, strong) UILabel *priceLabel; //总价
@property(nonatomic, strong) UILabel *originPriceLabel;
@property(nonatomic, strong) UILabel *pricePerSqmLabel; // 价格/平米

@property(nonatomic, strong) UIView *priceBgView; //底部 包含 价格 分享

@property(nonatomic, strong) FHHouseRecommendReasonView *recReasonView;

@property(nonatomic, assign) CGFloat topMargin;
@property(nonatomic, assign) CGFloat bottomMargin;
@property(nonatomic, assign) BOOL lastShowTag;

@end

@implementation FHHouseBaseItemCell

+(UIImage *)placeholderImage
{
    static UIImage *placeholderImage = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        placeholderImage = [UIImage imageNamed: @"default_image"];
    });
    return placeholderImage;
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(UIImageView *)mainImageView
{
    if (!_mainImageView) {
        _mainImageView = [[UIImageView alloc]init];
        _mainImageView.contentMode = UIViewContentModeScaleAspectFill;
        _mainImageView.layer.cornerRadius = 4;
        _mainImageView.clipsToBounds = YES;
        _mainImageView.layer.borderWidth = 0.5;
        _mainImageView.layer.borderColor = [UIColor themeGray6].CGColor;
    }
    return _mainImageView;
}

-(UILabel *)imageTagLabel
{
    if (!_imageTagLabel) {
        _imageTagLabel = [[UILabel alloc]init];
        _imageTagLabel.text = @"新上";
        _imageTagLabel.textAlignment = NSTextAlignmentCenter;
        _imageTagLabel.font = [UIFont themeFontRegular:10];
        _imageTagLabel.textColor = [UIColor whiteColor];
    }
    return _imageTagLabel;
}

-(FHCornerView *)imageTagLabelBgView
{
    if (!_imageTagLabelBgView) {
        _imageTagLabelBgView = [[FHCornerView alloc]init];
        _imageTagLabelBgView.backgroundColor = [UIColor themeRed3];
        _imageTagLabelBgView.hidden = YES;
    }
    return _imageTagLabelBgView;
}

-(UILabel *)mainTitleLabel
{
    if (!_mainTitleLabel) {
        _mainTitleLabel = [[UILabel alloc]init];
        _mainTitleLabel.font = [UIFont themeFontRegular:16];
        _mainTitleLabel.textColor = [UIColor themeGray1];
    }
    return _mainTitleLabel;
}

-(UILabel *)subTitleLabel
{
    if (!_subTitleLabel) {
        _subTitleLabel = [[UILabel alloc]init];
        _subTitleLabel.font = [UIFont themeFontRegular:12];
        _subTitleLabel.textColor = [UIColor themeGray3];
    }
    return _subTitleLabel;
}

-(YYLabel *)tagLabel
{
    if (!_tagLabel) {
        _tagLabel = [[YYLabel alloc]init];
        _tagLabel.numberOfLines = 0;
        _tagLabel.font = [UIFont themeFontRegular:12];
        _tagLabel.textColor = [UIColor themeGray3];
        _tagLabel.lineBreakMode = NSLineBreakByWordWrapping;
    }
    return _tagLabel;
}

-(UILabel *)priceLabel
{
    if (!_priceLabel) {
        _priceLabel = [[UILabel alloc]init];
        _priceLabel.font = [UIFont themeFontMedium:14];
        _priceLabel.textColor = [UIColor themeRed1];
    }
    return _priceLabel;
}

-(UILabel *)originPriceLabel
{
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

-(UILabel *)pricePerSqmLabel
{
    if (!_pricePerSqmLabel) {
        _pricePerSqmLabel = [[UILabel alloc]init];
        if ([TTDeviceHelper isScreenWidthLarge320]) {
            _pricePerSqmLabel.font = [UIFont themeFontRegular:12];
        }else {
            _pricePerSqmLabel.font = [UIFont themeFontRegular:10];
        }
        _pricePerSqmLabel.textColor = [UIColor themeGray3];
    }
    return _pricePerSqmLabel;
}

-(FHHouseRecommendReasonView *)recReasonView {

    if (!_recReasonView) {
        _recReasonView = [[FHHouseRecommendReasonView alloc] init];
    }
    return _recReasonView;
}

-(CGFloat)contentMaxWidth
{
    return  SCREEN_WIDTH - 170;
}

-(void)initUI
{
    [self.contentView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.flexDirection = YGFlexDirectionRow;
        layout.paddingLeft = YGPointValue(HOR_MARGIN);
        layout.paddingRight = YGPointValue(HOR_MARGIN);
        layout.paddingTop = YGPointValue(20);
        layout.width = YGPointValue(SCREEN_WIDTH);
        layout.flexGrow = 1;
    }];
    
    self.leftInfoView = [[UIView alloc] init];
    [_leftInfoView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.width = YGPointValue(MAIN_IMG_WIDTH);
        layout.height = YGPointValue(MAIN_IMG_HEIGHT);
    }];
    
    [self.contentView addSubview:_leftInfoView];
    [_leftInfoView addSubview:self.mainImageView];
    [_leftInfoView addSubview:self.imageTagLabelBgView];
    [_imageTagLabelBgView addSubview:self.imageTagLabel];
    
    [_mainImageView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.position = YGPositionTypeAbsolute;
        layout.width = YGPercentValue(100);
        layout.height = YGPercentValue(100);
    }];
    
    [_imageTagLabelBgView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.position = YGPositionTypeAbsolute;
        layout.left = YGPointValue(0);
        layout.top = YGPointValue(0);
        layout.width = YGPointValue(48);
        layout.height = YGPointValue(16);
    }];
    
    [_imageTagLabel configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.position = YGPositionTypeAbsolute;
        layout.left = YGPointValue((MAIN_TAG_BG_WIDTH-MAIN_TAG_WIDTH)/2);
        layout.top = YGPointValue((MAIN_TAG_BG_HEIGHT - MAIN_TAG_HEIGHT)/2);
        layout.width = YGPointValue(MAIN_TAG_WIDTH);
        layout.height = YGPointValue(MAIN_TAG_HEIGHT);
    }];
    
    _rightInfoView = [[UIView alloc] init];
    [self.contentView addSubview:_rightInfoView];
    
    [_rightInfoView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.marginLeft = YGPointValue(INFO_TO_ICON_MARGIN);
        layout.flexDirection = YGFlexDirectionColumn;
        layout.flexGrow = 1;
        layout.height = YGPercentValue(100);
    }];
    
    [_rightInfoView addSubview:self.mainTitleLabel];
    [_rightInfoView addSubview:self.subTitleLabel];
    [_rightInfoView addSubview:self.statInfoLabel];
    [_rightInfoView addSubview:self.tagLabel];
    
    [_mainTitleLabel configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.marginTop = YGPointValue(-3);
        layout.height = YGPointValue(22);
        layout.maxWidth = YGPointValue([self contentMaxWidth]);
    }];
    
    [_subTitleLabel configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.marginTop = YGPointValue(4);
        layout.height = YGPointValue(17);
        layout.maxWidth = YGPointValue([self contentMaxWidth]);
        layout.flexGrow = 0;
    }];
    
    [_statInfoLabel configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.marginTop = YGPointValue(4);
        layout.height = YGPointValue(17);
        layout.maxWidth = YGPointValue([self contentMaxWidth]);
        layout.flexGrow = 0;
    }];
    
    [_tagLabel configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.marginTop = YGPointValue(5);
        layout.marginLeft = YGPointValue(-3);
        layout.height = YGPointValue(15);
        layout.maxWidth = YGPointValue([self contentMaxWidth]);
    }];
    
    
    _priceBgView = [[UIView alloc] init];
    [_rightInfoView addSubview:_priceBgView];
    
    [_priceBgView addSubview:self.priceLabel];
    [_priceBgView addSubview:self.originPriceLabel];
    [_priceBgView addSubview:self.pricePerSqmLabel];
    [_priceBgView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.flexDirection = YGFlexDirectionRow;
        layout.width = YGPercentValue(100);
        layout.height = YGPointValue(20);
        layout.marginTop = YGPointValue(5);
        layout.alignItems = YGAlignCenter;
    }];
    
    [_priceLabel configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.height = YGPointValue(20);
        layout.maxWidth = YGPointValue(130);
        layout.alignSelf = YGAlignFlexEnd;
    }];
    
    [_originPriceLabel configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.marginLeft = YGPointValue(6);
        layout.isIncludedInLayout = NO;
    }];
    
    [_pricePerSqmLabel configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.marginLeft = YGPointValue(10);
    }];
    
    
    [_rightInfoView addSubview:self.recReasonView];
    [_recReasonView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isIncludedInLayout = NO;
        layout.marginTop = YGPointValue(2);
        layout.height = YGPointValue(16);
    }];
    _recReasonView.hidden = YES;
    
}


-(void)updateHomeHouseCellModel:(FHHomeHouseDataItemsModel *)commonModel andType:(FHHouseType)houseType
{
    self.mainTitleLabel.text = commonModel.displayTitle;
    self.subTitleLabel.text = commonModel.displayDescription;
    NSAttributedString * attributeString =  [FHSingleImageInfoCellModel tagsStringWithTagList:commonModel.tags];
    self.tagLabel.attributedText =  attributeString;
    
    self.priceLabel.text = commonModel.displayPricePerSqm;
    FHSearchHouseDataItemsHouseImageModel *imageModel = commonModel.images.firstObject;
    [self.mainImageView bd_setImageWithURL:[NSURL URLWithString:imageModel.url] placeholder:[UIImage imageNamed: @"default_image"]];
    
    if (houseType == FHHouseTypeSecondHandHouse) {
        FHHomeHouseDataItemsImagesModel *imageModel = commonModel.houseImage.firstObject;
        [self.mainImageView bd_setImageWithURL:[NSURL URLWithString:imageModel.url] placeholder:[UIImage imageNamed: @"default_image"]];
        self.subTitleLabel.text = commonModel.displaySubtitle;
        self.priceLabel.text = commonModel.displayPrice;
        self.pricePerSqmLabel.text = commonModel.displayPricePerSqm;
        if (commonModel.houseImageTag.text && commonModel.houseImageTag.backgroundColor && commonModel.houseImageTag.textColor) {
            
            self.imageTagLabel.textColor = [UIColor colorWithHexString:commonModel.houseImageTag.textColor];
            self.imageTagLabel.text = commonModel.houseImageTag.text;
            self.imageTagLabelBgView.backgroundColor = [UIColor colorWithHexString:commonModel.houseImageTag.backgroundColor];
            self.imageTagLabelBgView.hidden = NO;
        }else {
            
            self.imageTagLabelBgView.hidden = YES;
        }
        
//        [self updateOriginPriceLabelConstraints:self.cellModel.originPriceAttrStr];
    } else if (houseType == FHHouseTypeRentHouse) {
        
        self.mainTitleLabel.text = commonModel.title;
        self.subTitleLabel.text = commonModel.subtitle;
        self.priceLabel.text = commonModel.pricing;
        self.pricePerSqmLabel.text = nil;
        FHSearchHouseDataItemsHouseImageModel *imageModel = [commonModel.houseImage firstObject];
        [self.mainImageView bd_setImageWithURL:[NSURL URLWithString:imageModel.url] placeholder:[UIImage imageNamed: @"default_image"]];
        
        if (commonModel.houseImageTag.text && commonModel.houseImageTag.backgroundColor && commonModel.houseImageTag.textColor) {
            
            self.imageTagLabel.textColor = [UIColor colorWithHexString:commonModel.houseImageTag.textColor];
            self.imageTagLabel.text = commonModel.houseImageTag.text;
            self.imageTagLabelBgView.backgroundColor = [UIColor colorWithHexString:commonModel.houseImageTag.backgroundColor];
            self.imageTagLabelBgView.hidden = NO;
        }else {
            
            self.imageTagLabelBgView.hidden = YES;
        }
        
//        [self updateOriginPriceLabelConstraints:nil];
    } else {
        self.pricePerSqmLabel.text = @"";
    }
    
}

-(void)updateWithHouseCellModel:(FHSingleImageInfoCellModel *)cellModel
{
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

- (void)updateWithNeighborModel:(FHHouseNeighborDataItemsModel *)model
{
    FHSearchHouseDataItemsHouseImageModel *imageModel = model.images.firstObject;
    [self.mainImageView bd_setImageWithURL:[NSURL URLWithString:imageModel.url] placeholder:[UIImage imageNamed: @"default_image"]];
    
    self.imageTagLabelBgView.hidden = YES;
    [self updateImageTopLeft];
    
    self.mainTitleLabel.text = model.displayTitle;
    self.subTitleLabel.text = model.displaySubtitle;
    self.tagLabel.text = model.displayStatsInfo;
    self.priceLabel.text = model.displayPrice;
    
    if (self.tagLabel.yoga.marginLeft.value != 0) {
        [self.tagLabel configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
            layout.marginLeft = YGPointValue(0);
        }];
    }
    
    [self hideRecommendReason];
    [self updateTitlesLayout:YES];
    
    [self.contentView.yoga applyLayoutPreservingOrigin:NO];
    
}

#pragma mark 新房
-(void)updateWithNewHouseModel:(FHNewHouseItemModel *)model {
    
    FHSearchHouseDataItemsHouseImageModel *imageModel = model.images.firstObject;
    [self.mainImageView bd_setImageWithURL:[NSURL URLWithString:imageModel.url] placeholder:[UIImage imageNamed: @"default_image"]];
    
    self.imageTagLabelBgView.hidden = YES;
    [self updateImageTopLeft];
    
    self.mainTitleLabel.text = model.displayTitle;
    self.subTitleLabel.text = model.displayDescription;
    self.tagLabel.attributedText = self.cellModel.tagsAttrStr;
    
    self.priceLabel.text = model.displayPricePerSqm;
    
    self.originPriceLabel.hidden = YES;
    self.pricePerSqmLabel.hidden = YES;
    if (self.pricePerSqmLabel.yoga.isIncludedInLayout == self.pricePerSqmLabel.hidden) {
        [self.pricePerSqmLabel configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
            layout.isIncludedInLayout = self.pricePerSqmLabel.hidden;
        }];
        [self.pricePerSqmLabel.yoga markDirty];
    }
    if (self.originPriceLabel.yoga.isIncludedInLayout == self.originPriceLabel.hidden) {
        [self.originPriceLabel configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
            layout.isIncludedInLayout = self.originPriceLabel.hidden;
        }];
        [self.originPriceLabel.yoga markDirty];
    }
    
    [self hideRecommendReason];
    
    [self updateTitlesLayout:self.cellModel.tagsAttrStr.length > 0];
    
    [self.contentView.yoga applyLayoutPreservingOrigin:NO];
    
}

//新房周边新房
// 子类需要重写的方法，根据数据源刷新当前Cell，以及布局
- (void)refreshWithData:(id)data
{
    if([data isKindOfClass:[FHNewHouseItemModel class]])
    {
        FHNewHouseItemModel *model = (FHNewHouseItemModel *)data;
        self.mainTitleLabel.text = model.displayTitle;
        self.subTitleLabel.text = model.displayDescription;
        self.tagLabel.attributedText = self.cellModel.tagsAttrStr;
        NSAttributedString * attributeString =  [FHSingleImageInfoCellModel tagsStringWithTagList:model.tags];
        self.tagLabel.attributedText =  attributeString;
        
        self.priceLabel.text = model.displayPricePerSqm;
        FHSearchHouseDataItemsHouseImageModel *imageModel = model.images.firstObject;
        [self.mainImageView bd_setImageWithURL:[NSURL URLWithString:imageModel.url] placeholder:[UIImage imageNamed: @"default_image"]];
        
//        [self updateOriginPriceLabelConstraints:nil];
//        [self updateLayoutComponents:self.tagLabel.attributedText.string.length > 0];
    }
}

#pragma mark 二手房
-(void)updateWithSecondHouseModel:(FHSearchHouseDataItemsModel *)model
{
    FHSearchHouseDataItemsHouseImageModel *imageModel = model.houseImage.firstObject;
    [self.mainImageView bd_setImageWithURL:[NSURL URLWithString:imageModel.url] placeholder:[FHHouseBaseItemCell placeholderImage]];
    
    if (model.houseImageTag.text && model.houseImageTag.backgroundColor && model.houseImageTag.textColor) {
        self.imageTagLabel.textColor = [UIColor colorWithHexString:model.houseImageTag.textColor];
        self.imageTagLabel.text = model.houseImageTag.text;
        self.imageTagLabelBgView.backgroundColor = [UIColor colorWithHexString:model.houseImageTag.backgroundColor];
        self.imageTagLabelBgView.hidden = NO;
    }else {
        self.imageTagLabelBgView.hidden = YES;
    }
    
    [self updateImageTopLeft];
    
    self.mainTitleLabel.text = model.displayTitle;
    self.subTitleLabel.text = model.displaySubtitle;
    self.tagLabel.attributedText = self.cellModel.tagsAttrStr;
    
    self.priceLabel.text = model.displayPrice;
    self.pricePerSqmLabel.text = model.displayPricePerSqm;
    
    BOOL originPriceEnable = self.cellModel.originPriceAttrStr.string.length > 0;
    if (originPriceEnable || ( self.originPriceLabel.yoga.isIncludedInLayout != originPriceEnable)) {
        self.originPriceLabel.attributedText = self.cellModel.originPriceAttrStr;
        [self.originPriceLabel configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
            layout.isIncludedInLayout = originPriceEnable;
        }];
        [self.originPriceLabel.yoga markDirty];
    }
    self.originPriceLabel.hidden = !originPriceEnable;
    
    [self.pricePerSqmLabel.yoga markDirty];
    
    if (model.recommendReasons.count > 0) {
        self.recReasonView.hidden = NO;
        [self.recReasonView setReasons:model.recommendReasons];
    }else{
        self.recReasonView.hidden = YES;
    }

    if (self.recReasonView.yoga.isIncludedInLayout == self.recReasonView.isHidden) {
        [self.recReasonView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
            layout.isIncludedInLayout = !self.recReasonView.isHidden;
        }];
        [self.recReasonView.yoga markDirty];
    }
    
    [self updateTitlesLayout:self.cellModel.tagsAttrStr.length > 0];
    
    [self.contentView.yoga applyLayoutPreservingOrigin:NO];
    
}


#pragma mark 租房
-(void)updateWithRentHouseModel:(FHHouseRentDataItemsModel *)model
{
    self.mainTitleLabel.text = model.title;
    self.subTitleLabel.text = model.subtitle;
    self.tagLabel.attributedText = self.cellModel.tagsAttrStr;
    self.priceLabel.text = model.pricing;
    self.pricePerSqmLabel.text = nil;
    
    FHSearchHouseDataItemsHouseImageModel *imageModel = [model.houseImage firstObject];
    [self.mainImageView bd_setImageWithURL:[NSURL URLWithString:imageModel.url] placeholder:[FHHouseBaseItemCell placeholderImage]];
    
    if (model.houseImageTag.text && model.houseImageTag.backgroundColor && model.houseImageTag.textColor) {
        self.imageTagLabel.textColor = [UIColor colorWithHexString:model.houseImageTag.textColor];
        self.imageTagLabel.text = model.houseImageTag.text;
        self.imageTagLabelBgView.backgroundColor = [UIColor colorWithHexString:model.houseImageTag.backgroundColor];
        self.imageTagLabelBgView.hidden = NO;
    }else {
        self.imageTagLabelBgView.hidden = YES;
    }
    
    [self updateImageTopLeft];
   
    if (self.pricePerSqmLabel.yoga.isIncludedInLayout) {
        [self.pricePerSqmLabel configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
            layout.isIncludedInLayout = NO;
        }];
        [self.pricePerSqmLabel.yoga markDirty];
    }
    
    if (self.originPriceLabel.yoga.isIncludedInLayout) {
        [self.originPriceLabel configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
            layout.isIncludedInLayout = NO;
        }];
        [self.originPriceLabel.yoga markDirty];
    }
    
    [self hideRecommendReason];
    [self updateTitlesLayout:self.cellModel.tagsAttrStr.length > 0];
    [self.contentView.yoga applyLayoutPreservingOrigin:NO];
}

-(void)updateImageTopLeft
{
    if (self.imageTagLabelBgView.yoga.isIncludedInLayout != self.imageTagLabelBgView.isHidden) {
        [self.imageTagLabelBgView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
            layout.isIncludedInLayout = !self.imageTagLabelBgView.isHidden;
        }];
        [self.imageTagLabelBgView.yoga markDirty];
    }
}

-(void)updateTitlesLayout:(BOOL)showTags
{
//    BOOL showTags = self.cellModel.tagsAttrStr.length > 0;
    
    self.mainTitleLabel.numberOfLines = showTags?1:2;
    
    BOOL oneRow = self.cellModel.titleSize.height < 30;
    
    [self.mainTitleLabel configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.marginTop = YGPointValue(oneRow?-3:-6);
        layout.height = YGPointValue(oneRow?22:50);
    }];
    [self.mainTitleLabel.yoga markDirty];
    
    if (self.subTitleLabel.yoga.marginTop.value != (oneRow?4:1)) {
        [self.subTitleLabel configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
            layout.marginTop = YGPointValue(oneRow?4:1);
        }];
    }
    [self.subTitleLabel.yoga markDirty];
    
    if (self.tagLabel.yoga.isIncludedInLayout != showTags) {
        [self.tagLabel configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
            layout.isIncludedInLayout = showTags;
        }];
    }
    [self.tagLabel.yoga markDirty];
    
    [self.priceLabel.yoga markDirty];
    
    if (self.priceBgView.yoga.marginTop.value != (showTags?5:0)) {
        [self.priceBgView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
            layout.marginTop = YGPointValue(showTags?5:0);
        }];
        [self.priceBgView.yoga markDirty];
    }
}

-(void)hideRecommendReason
{
    if (self.recReasonView.yoga.isIncludedInLayout) {
        [self.recReasonView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
            layout.isIncludedInLayout = NO;
        }];
        self.recReasonView.hidden = YES;
    }
}


-(void)refreshTopMargin:(CGFloat)top
{
    if (self.contentView.yoga.paddingTop.value != top) {
        [self.contentView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
            layout.paddingTop = YGPointValue(top);
        }];
        [self.contentView.yoga markDirty];
    }
}

-(void)refreshBottomMargin:(CGFloat)bottom
{
    if (self.contentView.yoga.paddingBottom.value != bottom) {
        [self.contentView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
            layout.paddingBottom = YGPointValue(bottom);
        }];
        [self.contentView.yoga markDirty];
    }
}

-(void)refreshTopMargin:(CGFloat)top bottomMargin:(CGFloat)bottom
{
    BOOL dirty = NO;
    if (self.contentView.yoga.paddingTop.value != top) {
        [self.contentView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
            layout.paddingTop = YGPointValue(top);
        }];
        [self.contentView.yoga markDirty];
        dirty = YES;
    }
    
    if (self.contentView.yoga.paddingBottom.value != bottom) {
        [self.contentView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
            layout.paddingBottom = YGPointValue(bottom);
        }];
        [self.contentView.yoga markDirty];
        dirty = YES;
    }
    if (dirty) {
        [self.contentView.yoga applyLayoutPreservingOrigin:NO];
    }
}

@end
