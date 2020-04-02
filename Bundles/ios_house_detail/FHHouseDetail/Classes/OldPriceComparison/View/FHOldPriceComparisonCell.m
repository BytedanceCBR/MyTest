//
//  FHOldPriceComparisonCell.m
//  FHHouseDetail
//
//  Created by 谢思铭 on 2019/4/10.
//

#import "FHOldPriceComparisonCell.h"
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

#define MAIN_IMG_WIDTH      87
#define MAIN_IMG_HEIGHT     65
#define MAIN_TAG_BG_WIDTH   48
#define MAIN_TAG_BG_HEIGHT  16
#define MAIN_TAG_WIDTH      40
#define MAIN_TAG_HEIGHT     10
#define INFO_TO_ICON_MARGIN 12
#define PRICE_BG_TOP_MARGIN 5

@interface FHOldPriceComparisonCell ()

@property(nonatomic, strong) FHSingleImageInfoCellModel *cellModel;

@property(nonatomic, strong) UIView *leftInfoView;
@property(nonatomic, strong) UIImageView *mainImageView;
@property(nonatomic, strong) UILabel *imageTagLabel;
@property(nonatomic, strong) FHCornerView *imageTagLabelBgView;
@property(nonatomic, strong) UIView *rightInfoView;
//@property(nonatomic, strong) UILabel *mainTitleLabel; //主title lable
@property(nonatomic, strong) UILabel *subTitleLabel; // sub title lable
@property(nonatomic, strong) UILabel *statInfoLabel; //新房状态信息
@property(nonatomic, strong) YYLabel *tagLabel; // 标签 label
@property(nonatomic, strong) UILabel *priceLabel; //总价
@property(nonatomic, strong) UILabel *originPriceLabel;
@property(nonatomic, strong) UILabel *pricePerSqmLabel; // 价格/平米
@property(nonatomic, strong) UIView *priceBgView; //底部 包含 价格 分享

@end

@implementation FHOldPriceComparisonCell

+ (UIImage *)placeholderImage {
    static UIImage *placeholderImage = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        placeholderImage = [UIImage imageNamed: @"default_image"];
    });
    return placeholderImage;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initUI];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
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

- (UIImageView *)mainImageView {
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

- (UILabel *)imageTagLabel {
    if (!_imageTagLabel) {
        _imageTagLabel = [[UILabel alloc]init];
        _imageTagLabel.text = @"新上";
        _imageTagLabel.textAlignment = NSTextAlignmentCenter;
        _imageTagLabel.font = [UIFont themeFontRegular:10];
        _imageTagLabel.textColor = [UIColor whiteColor];
    }
    return _imageTagLabel;
}

- (FHCornerView *)imageTagLabelBgView {
    if (!_imageTagLabelBgView) {
        _imageTagLabelBgView = [[FHCornerView alloc]init];
        _imageTagLabelBgView.backgroundColor = [UIColor themeRed3];
        _imageTagLabelBgView.hidden = YES;
    }
    return _imageTagLabelBgView;
}

//- (UILabel *)mainTitleLabel {
//    if (!_mainTitleLabel) {
//        _mainTitleLabel = [[UILabel alloc]init];
//        _mainTitleLabel.font = [UIFont themeFontRegular:16];
//        _mainTitleLabel.textColor = [UIColor themeGray1];
//        _mainTitleLabel.hidden = YES;
//    }
//    return _mainTitleLabel;
//}

- (UILabel *)subTitleLabel {
    if (!_subTitleLabel) {
        _subTitleLabel = [[UILabel alloc]init];
        _subTitleLabel.font = [UIFont themeFontRegular:12];
        _subTitleLabel.textColor = [UIColor themeGray3];
    }
    return _subTitleLabel;
}

- (YYLabel *)tagLabel {
    if (!_tagLabel) {
        _tagLabel = [[YYLabel alloc]init];
        _tagLabel.numberOfLines = 0;
        _tagLabel.font = [UIFont themeFontRegular:12];
        _tagLabel.textColor = [UIColor themeGray3];
        _tagLabel.lineBreakMode = NSLineBreakByWordWrapping;
    }
    return _tagLabel;
}

- (UILabel *)priceLabel {
    if (!_priceLabel) {
        _priceLabel = [[UILabel alloc]init];
        _priceLabel.font = [UIFont themeFontMedium:16];
        _priceLabel.textColor = [UIColor themeOrange1];
    }
    return _priceLabel;
}

- (UILabel *)originPriceLabel {
    if (!_originPriceLabel) {
        _originPriceLabel = [[UILabel alloc]init];
        if ([TTDeviceHelper isScreenWidthLarge320]) {
            _originPriceLabel.font = [UIFont themeFontRegular:13];
        }else {
            _originPriceLabel.font = [UIFont themeFontRegular:11];
        }
        _originPriceLabel.textColor = [UIColor themeGray3];
        _originPriceLabel.hidden = YES;
    }
    return _originPriceLabel;
}

- (UILabel *)pricePerSqmLabel {
    if (!_pricePerSqmLabel) {
        _pricePerSqmLabel = [[UILabel alloc]init];
        if ([TTDeviceHelper isScreenWidthLarge320]) {
            _pricePerSqmLabel.font = [UIFont themeFontRegular:13];
        }else {
            _pricePerSqmLabel.font = [UIFont themeFontRegular:11];
        }
        _pricePerSqmLabel.textColor = [UIColor themeGray3];
    }
    return _pricePerSqmLabel;
}

- (CGFloat)contentMaxWidth {
    return  SCREEN_WIDTH - 170; //根据UI图 直接计算出来
}

- (void)initUI {
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
        layout.width = YGPointValue(50);
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
    
    _priceBgView = [[UIView alloc] init];
    [_rightInfoView addSubview:_priceBgView];
    
    [_priceBgView addSubview:self.priceLabel];
    [_priceBgView addSubview:self.originPriceLabel];
    [_priceBgView addSubview:self.pricePerSqmLabel];
    [_priceBgView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.flexDirection = YGFlexDirectionRow;
        layout.width = YGPercentValue(100);
        layout.height = YGPointValue(22);
        layout.marginTop = YGPointValue(-2);
        layout.alignItems = YGAlignCenter;
    }];
    
    [_priceLabel configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.maxWidth = YGPointValue(130);
    }];
    
    [_originPriceLabel configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.marginLeft = YGPointValue(6);
        layout.isIncludedInLayout = NO;
    }];
    
    [_pricePerSqmLabel configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.marginLeft = YGPointValue(10);
        layout.flexGrow = 1;
    }];
    
    [_rightInfoView addSubview:self.subTitleLabel];
    [_rightInfoView addSubview:self.statInfoLabel];
    [_rightInfoView addSubview:self.tagLabel];
    
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
        layout.marginTop = YGPointValue(6);
        layout.marginLeft = YGPointValue(-3);
        layout.height = YGPointValue(15);
        layout.maxWidth = YGPointValue([self contentMaxWidth]);
    }];
}

- (void)updateWithHouseCellModel:(FHSingleImageInfoCellModel *)cellModel {
    _cellModel = cellModel;
    
    switch (cellModel.houseType) {
        case FHHouseTypeSecondHandHouse:
            [self updateWithSecondHouseModel:cellModel.secondModel];
            break;
        default:
            break;
    }
}

#pragma mark 二手房
-(void)updateWithSecondHouseModel:(FHSearchHouseDataItemsModel *)model {
    FHImageModel *imageModel = model.houseImage.firstObject;
    [self.mainImageView bd_setImageWithURL:[NSURL URLWithString:imageModel.url] placeholder:[FHOldPriceComparisonCell placeholderImage]];
    
    if (model.houseImageTag.text && model.houseImageTag.backgroundColor && model.houseImageTag.textColor) {
        self.imageTagLabel.textColor = [UIColor colorWithHexString:model.houseImageTag.textColor];
        self.imageTagLabel.text = model.houseImageTag.text;
        self.imageTagLabelBgView.backgroundColor = [UIColor colorWithHexString:model.houseImageTag.backgroundColor];
        self.imageTagLabelBgView.hidden = NO;
    }else {
        self.imageTagLabelBgView.hidden = YES;
    }
    
    [self updateImageTopLeft];
    
//    self.mainTitleLabel.text = model.displayTitle;
    self.subTitleLabel.text = model.displaySubtitle;
    self.tagLabel.attributedText = self.cellModel.tagsAttrStr;
    
    self.priceLabel.text = model.displayPricePerSqm;
    self.pricePerSqmLabel.text = model.displayPrice;
    
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
    
    [self updateTitlesLayout:self.cellModel.tagsAttrStr.length > 0];
    
    [self.contentView.yoga applyLayoutPreservingOrigin:NO];
    
}

- (NSString *)getSubTitle:(FHSearchHouseDataItemsModel *)model {
    NSString *str = @"";
    
    NSString *roomType = @"";
    NSString *area = @"";
    NSString *orientation = @"";
    NSString *floor = @"";
    
    for (FHHouseBaseInfoModel *infoModel in model.baseInfo) {
        if([infoModel.attr isEqualToString:@"户型"]){
            roomType = infoModel.value;
        }else if([infoModel.attr isEqualToString:@"面积"]){
            if(infoModel.value.length > 2){
                area = [infoModel.value substringFromIndex:2];
            }else{
                area = infoModel.value;
            }
        }
        if([infoModel.attr isEqualToString:@"朝向"]){
            orientation = infoModel.value;
        }
        if([infoModel.attr isEqualToString:@"楼层"]){
            floor = infoModel.value;
        }
    }
    
    if(![roomType isEqualToString:@""]){
        NSRange range = [roomType rangeOfString:@"[0-9]*室[0-9]*厅" options:NSRegularExpressionSearch];
        if (range.location != NSNotFound) {
            roomType = [roomType substringWithRange:range];
            str = [str stringByAppendingString:roomType];
            str = [str stringByAppendingString:@"/"];
        }
    }
    
    if(![area isEqualToString:@""]){
        str = [str stringByAppendingString:area];
        str = [str stringByAppendingString:@"/"];
    }
    
    if(![orientation isEqualToString:@""]){
        str = [str stringByAppendingString:orientation];
        str = [str stringByAppendingString:@"/"];
    }
    
    if(![floor isEqualToString:@""]){
        str = [str stringByAppendingString:floor];
        str = [str stringByAppendingString:@"/"];
    }
    
    if(str.length > 0){
        str = [str substringToIndex:(str.length - 1)];
    }
    
    return str;
}

- (void)updateImageTopLeft {
    
    CGSize size = [self.imageTagLabel sizeThatFits:CGSizeZero];
    CGFloat labelWidth = ceil(size.width);
    
    if(labelWidth < MAIN_TAG_WIDTH){
        labelWidth = MAIN_TAG_WIDTH;
    }
    
    if(labelWidth > MAIN_IMG_WIDTH - 8){
        labelWidth = MAIN_IMG_WIDTH - 8;
    }
    
    if (self.imageTagLabelBgView.yoga.isIncludedInLayout != self.imageTagLabelBgView.isHidden) {
        [self.imageTagLabelBgView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
            layout.isIncludedInLayout = !self.imageTagLabelBgView.isHidden;
            layout.width = YGPointValue(labelWidth + 8);
        }];
        [self.imageTagLabelBgView.yoga markDirty];
        
        [_imageTagLabel configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
            layout.width = YGPointValue(labelWidth);
        }];
        [self.imageTagLabel.yoga markDirty];
    }
}

- (void)updateTitlesLayout:(BOOL)showTags {
    if (self.tagLabel.yoga.isIncludedInLayout != showTags) {
        [self.tagLabel configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
            layout.isIncludedInLayout = showTags;
        }];
    }
    [self.tagLabel.yoga markDirty];
    
    [self.priceLabel.yoga markDirty];
    [self.originPriceLabel.yoga markDirty];
    [self.pricePerSqmLabel.yoga markDirty];
}

- (void)refreshTopMargin:(CGFloat)top {
    if (self.contentView.yoga.paddingTop.value != top) {
        [self.contentView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
            layout.paddingTop = YGPointValue(top);
        }];
        [self.contentView.yoga markDirty];
    }
}

- (void)refreshBottomMargin:(CGFloat)bottom {
    if (self.contentView.yoga.paddingBottom.value != bottom) {
        [self.contentView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
            layout.paddingBottom = YGPointValue(bottom);
        }];
        [self.contentView.yoga markDirty];
    }
}

- (void)refreshTopMargin:(CGFloat)top bottomMargin:(CGFloat)bottom {
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



