//
//  FHHouseBaseSmallItemCell.m
//  FHHouseBase
//
//  Created by 谢思铭 on 2019/7/28.
//

#import "FHHouseBaseSmallItemCell.h"
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
#import "FHHouseRecommendReasonView.h"
#import "UIButton+TTAdditions.h"
#import "FHHouseDislikeView.h"
#import <Lottie/LOTAnimationView.h>

#define MAIN_NORMAL_TOP     10
#define MAIN_FIRST_TOP      20
#define MAIN_IMG_WIDTH      70
#define MAIN_IMG_HEIGHT     54.5
#define MAIN_TAG_BG_WIDTH   48
#define MAIN_TAG_BG_HEIGHT  16
#define MAIN_TAG_WIDTH      46
#define MAIN_TAG_HEIGHT     10
#define INFO_TO_ICON_MARGIN 12
#define PRICE_BG_TOP_MARGIN 5
#define CELL_HEIGHT 75

#define YOGA_RIGHT_PRICE_WIDITH 72


@interface FHHouseBaseSmallItemCell ()

@property(nonatomic, strong) FHSingleImageInfoCellModel *cellModel;
//首页的小图model
@property(nonatomic, strong) FHHomeHouseDataItemsModel *homeItemModel;

@property(nonatomic, strong) UIView *leftInfoView;

@property(nonatomic, strong) UIView *maskVRImageView;

@property(nonatomic, strong) UIImageView *houseVideoImageView;

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
@property(nonatomic, strong) UILabel *distanceLabel; // 30 分钟到达
@property(nonatomic, strong) UIImageView *fakeImageView;
@property(nonatomic, strong) UIView *fakeImageViewContainer;
@property(nonatomic, strong) UIView *priceBgView; //底部 包含 价格 分享
//@property(nonatomic, strong) UIButton *closeBtn; //x按钮
@property(nonatomic, strong) YYLabel *trueHouseLabel; // 天眼验真
@property (nonatomic, strong) LOTAnimationView *vrLoadingView;
@property(nonatomic, strong) FHCornerItemLabel *tagTitleLabel; //降 新 榜等标签
@property(nonatomic, strong) FHHouseRecommendReasonView *recReasonView; //榜单

@end

@implementation FHHouseBaseSmallItemCell

+(UIImage *)placeholderImage
{
    static UIImage *placeholderImage = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        placeholderImage = [UIImage imageNamed: @"house_cell_placeholder"];
    });
    return placeholderImage;
}

+(CGFloat)recommendReasonHeight
{
    return 22;
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
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

-(LOTAnimationView *)vrLoadingView
{
    if (!_vrLoadingView) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"VRImageLoading" ofType:@"json"];
        _vrLoadingView = [LOTAnimationView animationWithFilePath:path];
        _vrLoadingView.loopAnimation = YES;
    }
    return _vrLoadingView;
}

-(UIImageView *)houseVideoImageView
{
    if (!_houseVideoImageView) {
        _houseVideoImageView = [[UIImageView alloc]init];
        _houseVideoImageView.image = [UIImage imageNamed:@"icon_list_house_video"];
        _houseVideoImageView.backgroundColor = [UIColor clearColor];
    }
    return _houseVideoImageView;
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

-(FHCornerItemLabel *)tagTitleLabel {
    if (!_tagTitleLabel) {
        _tagTitleLabel = [[FHCornerItemLabel alloc] init];
        _tagTitleLabel.textAlignment = NSTextAlignmentCenter;
        _tagTitleLabel.font = [UIFont themeFontMedium:10];
        _tagTitleLabel.textColor = [UIColor themeWhite];
        _tagTitleLabel.frame = CGRectMake(0, 0, 16, 16);
    }
    return _tagTitleLabel;
}

-(UILabel *)mainTitleLabel
{
    if (!_mainTitleLabel) {
        _mainTitleLabel = [[UILabel alloc]init];
        _mainTitleLabel.font = [UIFont themeFontMedium:16];
        _mainTitleLabel.textColor = [UIColor themeGray1];
    }
    return _mainTitleLabel;
}

-(UILabel *)subTitleLabel
{
    if (!_subTitleLabel) {
        _subTitleLabel = [[UILabel alloc]init];
        _subTitleLabel.font = [UIFont themeFontRegular:12];
        _subTitleLabel.textColor = [UIColor themeGray2];
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
        _priceLabel.textColor = [UIColor themeRed1];
    
        if ([TTDeviceHelper isScreenWidthLarge320]) {
            _priceLabel.font = [UIFont themeFontDINAlternateBold:16];
        }else {
            _priceLabel.font = [UIFont themeFontDINAlternateBold:15];
        }
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
        _pricePerSqmLabel.font = [UIFont themeFontRegular:10];
        _pricePerSqmLabel.textColor = [UIColor themeGray3];
    }
    return _pricePerSqmLabel;
}

-(UILabel *)distanceLabel
{
    if (!_distanceLabel) {
        _distanceLabel = [[UILabel alloc] init];
        _distanceLabel.textAlignment = NSTextAlignmentRight;
    }
    return _distanceLabel;
}

-(FHHouseRecommendReasonView *)recReasonView {
    
    if (!_recReasonView) {
        _recReasonView = [[FHHouseRecommendReasonView alloc] init];
    }
    return _recReasonView;
}

//- (UIButton *)closeBtn {
//    if (!_closeBtn) {
//        _closeBtn = [[UIButton alloc] init];
//        _closeBtn.hidden = YES;
//        [_closeBtn setImage:[UIImage imageNamed:@"small_icon_close"] forState:UIControlStateNormal];
//        [_closeBtn addTarget:self action:@selector(dislike) forControlEvents:UIControlEventTouchUpInside];
//        _closeBtn.hitTestEdgeInsets = UIEdgeInsetsMake(-5, -10, -5, -5);
//    }
//    return _closeBtn;
//}

-(YYLabel *)trueHouseLabel
{
    if (!_trueHouseLabel) {
        _trueHouseLabel = [[YYLabel alloc]init];
        _trueHouseLabel.font = [UIFont themeFontRegular:10];
        _trueHouseLabel.textColor = [UIColor whiteColor];
        _trueHouseLabel.backgroundColor = [UIColor themeRed1];
        _trueHouseLabel.layer.masksToBounds = YES;
        _trueHouseLabel.layer.cornerRadius = 2;
        _trueHouseLabel.textContainerInset = UIEdgeInsetsMake(0, 4, 0, 4);
        _trueHouseLabel.text = @"天眼验真";
        _trueHouseLabel.hidden = YES;
    }
    return _trueHouseLabel;
}

-(CGFloat)contentMaxWidth
{
    return  SCREEN_WIDTH - HOR_MARGIN * 2 - YOGA_RIGHT_PRICE_WIDITH - MAIN_IMG_WIDTH - INFO_TO_ICON_MARGIN; //根据UI图 直接计算出来
}

-(void)initUI
{
    [self.contentView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.flexDirection = YGFlexDirectionRow;
        layout.paddingLeft = YGPointValue(HOR_MARGIN);
        layout.paddingRight = YGPointValue(HOR_MARGIN);
        layout.width = YGPointValue(SCREEN_WIDTH);
        layout.alignItems = YGAlignFlexStart;
    }];
    
    self.leftInfoView = [[UIView alloc] init];
    [_leftInfoView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.width = YGPointValue(MAIN_IMG_WIDTH);
        layout.height = YGPointValue(CELL_HEIGHT);
    }];
    
    [self.contentView addSubview:_leftInfoView];
    [_leftInfoView addSubview:self.mainImageView];
    [_leftInfoView addSubview:self.imageTagLabelBgView];
    [_imageTagLabelBgView addSubview:self.imageTagLabel];
    
    [_mainImageView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.position = YGPositionTypeAbsolute;
        layout.top = YGPointValue(10.f);
        layout.width = YGPointValue(MAIN_IMG_WIDTH);
        layout.height = YGPointValue(MAIN_IMG_HEIGHT);
    }];
    
    [self.leftInfoView addSubview:self.houseVideoImageView];
    _houseVideoImageView.image = [UIImage imageNamed:@"icon_list_house_video_small"];
    
    [_houseVideoImageView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.position = YGPositionTypeAbsolute;
        layout.top = YGPointValue(27.0f);
        layout.left = YGPointValue(25.0f);
        layout.width = YGPointValue(20.0f);
        layout.height = YGPointValue(20.0f);
    }];
    
    [self.leftInfoView addSubview:self.vrLoadingView];
    self.vrLoadingView.hidden = YES;
    //    [self.vrLoadingView setBackgroundColor:[UIColor redColor]];
    [self.vrLoadingView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.position = YGPositionTypeAbsolute;
        layout.top = YGPointValue(25.0f);
        layout.left = YGPointValue(23.0f);
        layout.width = YGPointValue(24);
        layout.height = YGPointValue(24);
    }];
    
    [_imageTagLabelBgView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.position = YGPositionTypeAbsolute;
        layout.left = YGPointValue(0);
        layout.top = YGPointValue(10);
        layout.width = YGPointValue(48);
        layout.height = YGPointValue(17);
    }];
    
    [_imageTagLabel configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.position = YGPositionTypeAbsolute;
        layout.left = YGPointValue(0);
        layout.top = YGPointValue(0);
        layout.width = YGPointValue(48);
        layout.height = YGPointValue(17);
    }];
    
    _rightInfoView = [[UIView alloc] init];
    [self.contentView addSubview:_rightInfoView];
    
    [_rightInfoView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.marginLeft = YGPointValue(INFO_TO_ICON_MARGIN);
        layout.flexDirection = YGFlexDirectionColumn;
        layout.flexGrow = 1;
        layout.justifyContent = YGJustifyCenter;
        layout.maxWidth = YGPointValue([self contentMaxWidth]);
        layout.height = YGPointValue(CELL_HEIGHT);
    }];
    
    UIView *titleView = [[UIView alloc] init];
    [_rightInfoView addSubview:titleView];
    [_rightInfoView addSubview:self.subTitleLabel];
    [_rightInfoView addSubview:self.statInfoLabel];
    [_rightInfoView addSubview:self.tagLabel];
    
    [titleView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.flexDirection = YGFlexDirectionRow;
        layout.paddingLeft = YGPointValue(0);
        layout.paddingRight = YGPointValue(0);
        layout.alignItems = YGAlignFlexStart;
        layout.marginTop = YGPointValue(0);
        layout.height = YGPointValue(22);
        layout.maxWidth = YGPointValue([self contentMaxWidth]);
    }];
    [titleView addSubview:self.mainTitleLabel];
    [titleView addSubview:self.tagTitleLabel];
    
    _mainTitleLabel.font = [UIFont themeFontSemibold:16];
    [_mainTitleLabel configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.marginTop = YGPointValue(0);
        layout.height = YGPointValue(22);
        layout.maxWidth = YGPointValue([self contentMaxWidth]);
    }];
    
    _tagTitleLabel.hidden = YES;
    [_tagTitleLabel configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.marginTop = YGPointValue(3);
        layout.marginLeft = YGPointValue(4);
        layout.height = YGPointValue(16);
        layout.width = YGPointValue(16);
    }];
    
    [_subTitleLabel configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.marginTop = YGPointValue(2);
        layout.height = YGPointValue(17);
        layout.maxWidth = YGPointValue([self contentMaxWidth]);
        layout.flexGrow = 0;
    }];
    
    [_statInfoLabel configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.marginTop = YGPointValue(0);
        layout.height = YGPointValue(19);
        layout.maxWidth = YGPointValue([self contentMaxWidth]);
        layout.flexGrow = 0;
    }];
    
    _tagLabel.font = [UIFont themeFontRegular:10];
    [_tagLabel configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.marginTop = YGPointValue(2);
        layout.marginLeft = YGPointValue(0);
        layout.height = YGPointValue(14);
        layout.maxWidth = YGPointValue([self contentMaxWidth]);
    }];
    
    
    _priceBgView = [[UIView alloc] init];
    [_priceBgView setBackgroundColor:[UIColor whiteColor]];
    [self.contentView addSubview:_priceBgView];
    [_priceBgView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.flexDirection = YGFlexDirectionColumn;
        layout.width = YGPointValue(YOGA_RIGHT_PRICE_WIDITH);
        layout.height = YGPointValue(CELL_HEIGHT);
        layout.justifyContent = YGJustifyCenter;
        layout.alignItems = YGAlignFlexEnd;
    }];
    
    [_priceBgView addSubview:self.priceLabel];
    [_priceBgView addSubview:self.pricePerSqmLabel];
    //    [_priceBgView addSubview:self.closeBtn];
    [_priceBgView addSubview:self.trueHouseLabel];
    
    [_priceLabel configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.height = YGPointValue(19);
        layout.maxWidth = YGPointValue(YOGA_RIGHT_PRICE_WIDITH);
    }];
    
    _pricePerSqmLabel.textAlignment = 2;
    [_pricePerSqmLabel configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.marginTop = YGPointValue(2);
        layout.height = YGPointValue(14);
        layout.maxWidth = YGPointValue(YOGA_RIGHT_PRICE_WIDITH);
    }];
    
    [_trueHouseLabel configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isIncludedInLayout = NO;
        layout.marginTop = YGPointValue(5);
        layout.height = YGPointValue(14);
    }];
    
    //    [_closeBtn configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
    //        layout.isEnabled = YES;
    //        layout.marginTop = YGPointValue(8);
    //        layout.width = YGPointValue(8);
    //        layout.height = YGPointValue(8);
    //    }];
    //
    [_rightInfoView addSubview:self.recReasonView];
    [_recReasonView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isIncludedInLayout = NO;
        layout.marginTop = YGPointValue(6);
        layout.height = YGPointValue(16);
    }];
    _recReasonView.hidden = YES;
    
}


-(void)updateMainImageWithUrl:(NSString *)url
{
    NSURL *imgUrl = [NSURL URLWithString:url];
    if (imgUrl) {
        [self.mainImageView bd_setImageWithURL:imgUrl placeholder:[FHHouseBaseSmallItemCell placeholderImage]];
    }else{
        self.mainImageView.image = [FHHouseBaseSmallItemCell placeholderImage];
    }
}

-(void)updateHomeHouseCellModel:(FHHomeHouseDataItemsModel *)commonModel andType:(FHHouseType)houseType
{
    self.houseVideoImageView.hidden = !commonModel.houseVideo.hasVideo;
    self.mainTitleLabel.text = commonModel.displayTitle;
    self.subTitleLabel.text = commonModel.displayDescription;
    NSAttributedString * attributeString =  [FHSingleImageInfoCellModel tagsStringWithTagList:commonModel.tags];
    self.tagLabel.attributedText =  attributeString;
    
    self.priceLabel.text = commonModel.displayPricePerSqm;
    //    UIImage *placeholder = [FHHouseBaseItemCell placeholderImage];
    FHImageModel *imageModel = commonModel.images.firstObject;
    [self updateMainImageWithUrl:imageModel.url];
    
    if (houseType == FHHouseTypeSecondHandHouse) {
        FHImageModel *imageModel = commonModel.houseImage.firstObject;
        [self updateMainImageWithUrl:imageModel.url];
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
        
    } else if (houseType == FHHouseTypeRentHouse) {
        
        self.mainTitleLabel.text = commonModel.title;
        self.subTitleLabel.text = commonModel.subtitle;
        self.priceLabel.text = commonModel.pricing;
        self.pricePerSqmLabel.text = nil;
        FHImageModel *imageModel = [commonModel.houseImage firstObject];
        [self updateMainImageWithUrl:imageModel.url];
        
        if (commonModel.houseImageTag.text && commonModel.houseImageTag.backgroundColor && commonModel.houseImageTag.textColor) {
            
            self.imageTagLabel.textColor = [UIColor colorWithHexString:commonModel.houseImageTag.textColor];
            self.imageTagLabel.text = commonModel.houseImageTag.text;
            self.imageTagLabelBgView.backgroundColor = [UIColor colorWithHexString:commonModel.houseImageTag.backgroundColor];
            self.imageTagLabelBgView.hidden = NO;
        }else {
            
            self.imageTagLabelBgView.hidden = YES;
        }
    } else {
        self.pricePerSqmLabel.text = @"";
    }
    
    [self hideRecommendReason];
    [self updateTitlesLayout:YES];
    
    [self.contentView.yoga applyLayoutPreservingOrigin:NO];
}

-(void)updateHomeSmallImageHouseCellModel:(FHHomeHouseDataItemsModel *)commonModel andType:(FHHouseType)houseType
{
    //    self.homeItemModel = commonModel;
    //    if(houseType == FHHouseTypeSecondHandHouse || houseType == FHHouseTypeRentHouse){
    //        self.closeBtn.hidden = NO;
    //    }else{
    //        self.closeBtn.hidden = YES;
    //    }
    self.houseVideoImageView.hidden = !commonModel.houseVideo.hasVideo;
    self.mainTitleLabel.text = commonModel.displayTitle;
    self.subTitleLabel.text = commonModel.displayDescription;
    NSAttributedString * attributeString =  [FHSingleImageInfoCellModel tagsStringSmallImageWithTagList:commonModel.tags];
    self.tagLabel.attributedText =  attributeString;
    self.priceLabel.text = commonModel.displayPricePerSqm;
    //    UIImage *placeholder = [FHHouseBaseItemCell placeholderImage];
    FHImageModel *imageModel = commonModel.images.firstObject;
    [self updateMainImageWithUrl:imageModel.url];
    
    if (houseType == FHHouseTypeSecondHandHouse) {
        FHImageModel *imageModel = commonModel.houseImage.firstObject;
        [self updateMainImageWithUrl:imageModel.url];
        self.subTitleLabel.text = commonModel.displaySubtitle;
        
        if ([TTDeviceHelper isScreenWidthLarge320]) {
            _priceLabel.font = [UIFont themeFontDINAlternateBold:16];
        }else {
            _priceLabel.font = [UIFont themeFontDINAlternateBold:15];
        }
        _pricePerSqmLabel.textColor = [UIColor themeGray3];
        
        self.priceLabel.text = commonModel.displayPrice;
        if (commonModel.originPrice) {
            self.pricePerSqmLabel.attributedText = [self originPriceAttr:commonModel.originPrice];
        }else
        {
            self.pricePerSqmLabel.text = commonModel.displayPricePerSqm;
        }
        
        if (commonModel.houseImageTag.text && commonModel.houseImageTag.backgroundColor && commonModel.houseImageTag.textColor) {
            
            self.imageTagLabel.textColor = [UIColor colorWithHexString:commonModel.houseImageTag.textColor];
            self.imageTagLabel.text = commonModel.houseImageTag.text;
            self.imageTagLabelBgView.backgroundColor = [UIColor colorWithHexString:commonModel.houseImageTag.backgroundColor];
            self.imageTagLabelBgView.hidden = NO;
        }else {
            self.imageTagLabelBgView.hidden = YES;
        }
        
    } else if (houseType == FHHouseTypeRentHouse) {
        
        self.mainTitleLabel.text = commonModel.title;
        self.subTitleLabel.text = commonModel.subtitle;
        self.priceLabel.text = commonModel.pricingNum;
        self.pricePerSqmLabel.text = commonModel.pricingUnit;
        self.pricePerSqmLabel.textColor = [UIColor themeRed1];
        
        FHImageModel *imageModel = [commonModel.houseImage firstObject];
        [self updateMainImageWithUrl:imageModel.url];
        
        if (commonModel.houseImageTag.text && commonModel.houseImageTag.backgroundColor && commonModel.houseImageTag.textColor) {
            
            self.imageTagLabel.textColor = [UIColor colorWithHexString:commonModel.houseImageTag.textColor];
            self.imageTagLabel.text = commonModel.houseImageTag.text;
            self.imageTagLabelBgView.backgroundColor = [UIColor colorWithHexString:commonModel.houseImageTag.backgroundColor];
            self.imageTagLabelBgView.hidden = NO;
        }else {
            
            self.imageTagLabelBgView.hidden = YES;
        }
    } else {
        
        if ([TTDeviceHelper isScreenWidthLarge320]) {
            _priceLabel.font = [UIFont themeFontDINAlternateBold:16];
            _pricePerSqmLabel.font = [UIFont themeFontRegular:10];
            _pricePerSqmLabel.textColor = [UIColor themeRed1];
        }else {
            _priceLabel.font = [UIFont themeFontDINAlternateBold:15];
            _pricePerSqmLabel.font = [UIFont themeFontRegular:10];
            _pricePerSqmLabel.textColor = [UIColor themeRed1];
        }
        
        self.priceLabel.text = commonModel.pricePerSqmNum;
        self.pricePerSqmLabel.text = commonModel.pricePerSqmUnit;
        
        
        if (commonModel.houseImageTag.text && commonModel.houseImageTag.backgroundColor && commonModel.houseImageTag.textColor) {
            
            self.imageTagLabel.textColor = [UIColor colorWithHexString:commonModel.houseImageTag.textColor];
            self.imageTagLabel.text = commonModel.houseImageTag.text;
            self.imageTagLabelBgView.backgroundColor = [UIColor colorWithHexString:commonModel.houseImageTag.backgroundColor];
            self.imageTagLabelBgView.hidden = NO;
        }else {
            
            self.imageTagLabelBgView.hidden = YES;
        }
    }
    
    [self hideRecommendReason];
    [self updateTitlesLayout:attributeString.length > 0];
    
    [self.contentView.yoga applyLayoutPreservingOrigin:NO];
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
    self.houseVideoImageView.hidden = !model.houseVideo.hasVideo;
    FHImageModel *imageModel = model.images.firstObject;
    [self updateMainImageWithUrl:imageModel.url];
    
    self.imageTagLabelBgView.hidden = YES;
    [self updateImageTopLeft];
    
    self.mainTitleLabel.text = model.displayTitle;
    self.subTitleLabel.text = model.displaySubtitle;
    self.tagLabel.text = model.displayStatsInfo;
    self.priceLabel.text = model.pricePerSqmNum;
    self.pricePerSqmLabel.text = model.pricePerSqmUnit;
    self.pricePerSqmLabel.textColor = [UIColor themeRed1];
    
    [self hideRecommendReason];
    [self updateTitlesLayout:YES];
    
    [self.contentView.yoga applyLayoutPreservingOrigin:NO];
    
}

#pragma mark 新房
-(void)updateWithNewHouseModel:(FHNewHouseItemModel *)model {
    self.houseVideoImageView.hidden = YES;
    FHImageModel *imageModel = model.images.firstObject;
    [self updateMainImageWithUrl:imageModel.url];
    
    self.imageTagLabelBgView.hidden = YES;
    [self updateImageTopLeft];
    
    self.mainTitleLabel.text = model.displayTitle;
    self.subTitleLabel.text = model.displayDescription;
    NSAttributedString * attributeString =  [FHSingleImageInfoCellModel tagsStringSmallImageWithTagList:model.tags];
    self.tagLabel.attributedText =  attributeString;
    
    self.priceLabel.text = model.pricePerSqmNum;
    self.pricePerSqmLabel.text = model.pricePerSqmUnit;
    self.pricePerSqmLabel.textColor = [UIColor themeRed1];
    
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
        FHImageModel *imageModel = model.images.firstObject;
        [self updateMainImageWithUrl:imageModel.url];
    }else if ([data isKindOfClass:[FHSingleImageInfoCellModel class]]) {
        [self updateWithHouseCellModel:data];
    }else if ([data isKindOfClass:[FHSearchHouseItemModel class]]) {

        FHSearchHouseItemModel *commonModel = (FHSearchHouseItemModel *)data;
        [self refreshTopMargin:commonModel.topMargin];
        FHHouseType houseType = commonModel.houseType.integerValue;
        self.houseVideoImageView.hidden = !commonModel.houseVideo.hasVideo;
        self.mainTitleLabel.text = commonModel.displayTitle;
        self.subTitleLabel.text = commonModel.displayDescription;
        NSAttributedString * attributeString =  [FHSingleImageInfoCellModel tagsStringSmallImageWithTagList:commonModel.tags];
        self.priceLabel.text = commonModel.displayPricePerSqm;
        //    UIImage *placeholder = [FHHouseBaseItemCell placeholderImage];
        FHImageModel *imageModel = commonModel.images.firstObject;
        [self updateMainImageWithUrl:imageModel.url];
        
        if (houseType == FHHouseTypeSecondHandHouse) {
            
            self.tagLabel.attributedText =  attributeString;
            self.tagTitleLabel.hidden = YES;
            FHImageModel *imageModel = commonModel.houseImage.firstObject;
            [self updateMainImageWithUrl:imageModel.url];

            if (commonModel.houseImageTag.text && commonModel.houseImageTag.backgroundColor && commonModel.houseImageTag.textColor) {
                
                self.imageTagLabel.textColor = [UIColor colorWithHexString:commonModel.houseImageTag.textColor];
                self.imageTagLabel.text = commonModel.houseImageTag.text;
                self.imageTagLabelBgView.backgroundColor = [UIColor colorWithHexString:commonModel.houseImageTag.backgroundColor];
                self.imageTagLabelBgView.hidden = NO;
            }else {
                self.imageTagLabelBgView.hidden = YES;
            }
            
            if (commonModel.skyEyeTag.content && commonModel.skyEyeTag.backgroundColor && commonModel.skyEyeTag.textColor) {
                self.trueHouseLabel.textColor = [UIColor colorWithHexString:commonModel.skyEyeTag.textColor];
                self.trueHouseLabel.text = commonModel.skyEyeTag.content;
                self.trueHouseLabel.backgroundColor = [UIColor colorWithHexString:commonModel.skyEyeTag.backgroundColor];
                self.trueHouseLabel.hidden = NO;
                [_trueHouseLabel configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
                    layout.isIncludedInLayout = YES;
                }];
                [_trueHouseLabel.yoga markDirty];
            }else {
                self.trueHouseLabel.hidden = YES;
                [_trueHouseLabel configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
                    layout.isIncludedInLayout = NO;
                }];
                [_trueHouseLabel.yoga markDirty];
            }
            [self updateImageTopLeft];

            self.mainTitleLabel.text = commonModel.displayTitle;
            self.subTitleLabel.text = commonModel.displaySubtitle;
            
            //处理标签
            BOOL imageTagHidden = self.imageTagLabelBgView.hidden;
            if (commonModel.houseTitleTag) {
                self.imageTagLabelBgView.hidden = YES;
                self.tagTitleLabel.hidden = NO;
                [self.mainTitleLabel configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
                    layout.maxWidth = YGPointValue([self contentMaxWidth] - 20);
                }];
                self.tagTitleLabel.text = commonModel.houseTitleTag.text;
                self.tagTitleLabel.backgroundColor = [UIColor colorWithHexString:commonModel.houseTitleTag.backgroundColor];
                self.tagTitleLabel.textColor = [UIColor colorWithHexString:commonModel.houseTitleTag.textColor];
            } else {
                self.imageTagLabelBgView.hidden = imageTagHidden;
                self.tagTitleLabel.hidden = YES;
                [self.mainTitleLabel configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
                    layout.maxWidth = YGPointValue([self contentMaxWidth]);
                }];
            }
            [self.mainTitleLabel.yoga markDirty];

            if (commonModel.externalInfo && commonModel.externalInfo.isExternalSite.boolValue) {
                [self updateThirdPartHouseSourceStr:commonModel.externalInfo.externalName];
            }else
            {
                NSAttributedString * attributeString =  [FHSingleImageInfoCellModel tagsStringSmallImageWithTagList:commonModel.tags];
                self.tagLabel.attributedText =  attributeString;
            }
            if (self.maskVRImageView) {
                [self.maskVRImageView removeFromSuperview];
                self.maskVRImageView = nil;
            }
            
            if (_vrLoadingView && commonModel.vrInfo.hasVr) {
                _vrLoadingView.hidden = NO;
                [_vrLoadingView play];
                self.houseVideoImageView.hidden = YES;
                
                self.maskVRImageView = [UIView new];
                self.maskVRImageView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1];
                [self.mainImageView addSubview:self.maskVRImageView];
                [self.maskVRImageView setFrame:CGRectMake(0.0f, 0.0f, MAIN_IMG_WIDTH, MAIN_IMG_HEIGHT)];
            }else
            {
                _vrLoadingView.hidden = YES;
            }
            
            self.priceLabel.text = commonModel.displayPrice;
            self.pricePerSqmLabel.text = commonModel.displayPricePerSqm;

            if (commonModel.originPrice) {
                self.pricePerSqmLabel.attributedText = [self originPriceAttr:commonModel.originPrice];
            }else
            {
                self.pricePerSqmLabel.text = commonModel.displayPricePerSqm;
            }
            [self.pricePerSqmLabel.yoga markDirty];

            [self hideRecommendReason];
            if (self.recReasonView.yoga.isIncludedInLayout == self.recReasonView.isHidden) {
                [self.recReasonView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
                    layout.isIncludedInLayout = !self.recReasonView.isHidden;
                }];
                [self.recReasonView.yoga markDirty];
            }
            if (commonModel.externalInfo && commonModel.externalInfo.isExternalSite.boolValue) {
                [self updateTitlesLayout:YES];
            }else
            {
                [self updateTitlesLayout:attributeString.length > 0];
            }
        } else if (houseType == FHHouseTypeRentHouse) {
            
            self.houseVideoImageView.hidden = YES;
            self.mainTitleLabel.text = commonModel.title;
            self.subTitleLabel.text = commonModel.subtitle;
            self.tagLabel.attributedText =  attributeString;
            self.priceLabel.text = commonModel.pricingNum;
            self.pricePerSqmLabel.text = commonModel.pricingUnit;
            self.pricePerSqmLabel.textColor = [UIColor themeRed1];
            
            FHImageModel *imageModel = [commonModel.houseImage firstObject];
            [self updateMainImageWithUrl:imageModel.url];
            
            if (commonModel.houseImageTag.text && commonModel.houseImageTag.backgroundColor && commonModel.houseImageTag.textColor) {
                
                self.imageTagLabel.textColor = [UIColor colorWithHexString:commonModel.houseImageTag.textColor];
                self.imageTagLabel.text = commonModel.houseImageTag.text;
                self.imageTagLabelBgView.backgroundColor = [UIColor colorWithHexString:commonModel.houseImageTag.backgroundColor];
                self.imageTagLabelBgView.hidden = NO;
            }else {
                
                self.imageTagLabelBgView.hidden = YES;
            }
            [self updateImageTopLeft];
            [self hideRecommendReason];
            [self updateTitlesLayout:attributeString.length > 0];
        } else if (houseType == FHHouseTypeNeighborhood) {
            
            self.houseVideoImageView.hidden = !commonModel.houseVideo.hasVideo;
            FHImageModel *imageModel = commonModel.images.firstObject;
            [self updateMainImageWithUrl:imageModel.url];
            
            self.imageTagLabelBgView.hidden = YES;
            [self updateImageTopLeft];
            
            self.mainTitleLabel.text = commonModel.displayTitle;
            self.subTitleLabel.text = commonModel.displaySubtitle;
            self.tagLabel.text = commonModel.displayStatsInfo;
            self.priceLabel.text = commonModel.pricePerSqmNum;
            self.pricePerSqmLabel.text = commonModel.pricePerSqmUnit;
            self.pricePerSqmLabel.textColor = [UIColor themeRed1];
            
            [self hideRecommendReason];
            [self updateTitlesLayout:YES];
        }
        
        [self.contentView.yoga applyLayoutPreservingOrigin:NO];
    }
}

+ (CGFloat)heightForData:(id)data
{
    BOOL isLastCell = NO;
    if([data isKindOfClass:[FHSearchHouseItemModel class]]) {
        FHSearchHouseItemModel *model = (FHSearchHouseItemModel *)data;
        isLastCell = model.isLastCell;
        CGFloat reasonHeight = [model showRecommendReason] ? [FHHouseBaseSmallItemCell recommendReasonHeight] : 0;
        return (isLastCell ? 95 : 75) + reasonHeight + model.topMargin;
    }
}

#pragma mark 二手房
-(void)updateWithSecondHouseModel:(FHSearchHouseDataItemsModel *)model
{
    self.tagTitleLabel.hidden = YES;
    self.houseVideoImageView.hidden = !model.houseVideo.hasVideo;
    FHImageModel *imageModel = model.houseImage.firstObject;
    [self updateMainImageWithUrl:imageModel.url];
    
    if (model.houseImageTag.text && model.houseImageTag.backgroundColor && model.houseImageTag.textColor) {
        self.imageTagLabel.textColor = [UIColor colorWithHexString:model.houseImageTag.textColor];
        self.imageTagLabel.text = model.houseImageTag.text;
        self.imageTagLabelBgView.backgroundColor = [UIColor colorWithHexString:model.houseImageTag.backgroundColor];
        self.imageTagLabelBgView.hidden = NO;
    }else {
        self.imageTagLabelBgView.hidden = YES;
    }
    
    if (model.skyEyeTag.content && model.skyEyeTag.backgroundColor && model.skyEyeTag.textColor) {
        self.trueHouseLabel.textColor = [UIColor colorWithHexString:model.skyEyeTag.textColor];
        self.trueHouseLabel.text = model.skyEyeTag.content;
        self.trueHouseLabel.backgroundColor = [UIColor colorWithHexString:model.skyEyeTag.backgroundColor];
        self.trueHouseLabel.hidden = NO;
        [_trueHouseLabel configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
            layout.isIncludedInLayout = YES;
        }];
        [_trueHouseLabel.yoga markDirty];
    }else {
        self.trueHouseLabel.hidden = YES;
        [_trueHouseLabel configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
            layout.isIncludedInLayout = NO;
        }];
        [_trueHouseLabel.yoga markDirty];
    }
    
    [self updateImageTopLeft];
    
    self.mainTitleLabel.text = model.displayTitle;
    self.subTitleLabel.text = model.displaySubtitle;

    BOOL imageTagHidden = self.imageTagLabelBgView.hidden;
    if (model.houseTitleTag) {
        self.imageTagLabelBgView.hidden = YES;
        self.tagTitleLabel.hidden = NO;
        [self.mainTitleLabel configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
            layout.maxWidth = YGPointValue([self contentMaxWidth] - 20);
        }];
        self.tagTitleLabel.text = model.houseTitleTag.text;
        self.tagTitleLabel.backgroundColor = [UIColor colorWithHexString:model.houseTitleTag.backgroundColor];
        self.tagTitleLabel.textColor = [UIColor colorWithHexString:model.houseTitleTag.textColor];
    } else {
        self.imageTagLabelBgView.hidden = imageTagHidden;
        self.tagTitleLabel.hidden = YES;
        [self.mainTitleLabel configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
            layout.maxWidth = YGPointValue([self contentMaxWidth]);
        }];
    }
    [self.mainTitleLabel.yoga markDirty];
    
    if (model.externalInfo && model.externalInfo.isExternalSite.boolValue) {
        [self updateThirdPartHouseSourceStr:model.externalInfo.externalName];
    }else
    {
        NSAttributedString * attributeString =  [FHSingleImageInfoCellModel tagsStringSmallImageWithTagList:model.tags];
        self.tagLabel.attributedText =  attributeString;
    }
    
    if (self.maskVRImageView) {
        [self.maskVRImageView removeFromSuperview];
        self.maskVRImageView = nil;
    }

    if (_vrLoadingView && model.vrInfo.hasVr) {
        _vrLoadingView.hidden = NO;
        [_vrLoadingView play];
        self.houseVideoImageView.hidden = YES;
        
        self.maskVRImageView = [UIView new];
        self.maskVRImageView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1];
        [self.mainImageView addSubview:self.maskVRImageView];
        [self.maskVRImageView setFrame:CGRectMake(0.0f, 0.0f, MAIN_IMG_WIDTH, MAIN_IMG_HEIGHT)];
        
    }else
    {
        _vrLoadingView.hidden = YES;
    }
    
    self.priceLabel.text = model.displayPrice;
    self.pricePerSqmLabel.text = model.displayPricePerSqm;
    
    if (model.originPrice) {
        self.pricePerSqmLabel.attributedText = [self originPriceAttr:model.originPrice];
    }else{
        self.pricePerSqmLabel.text = model.displayPricePerSqm;
    }

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
    
    if (model.externalInfo && model.externalInfo.isExternalSite.boolValue) {
        [self updateTitlesLayout:YES];
    }else
    {
        [self updateTitlesLayout:self.cellModel.tagsAttrStr.length > 0];
    }
    
    [self.contentView.yoga applyLayoutPreservingOrigin:NO];
}


#pragma mark 租房
-(void)updateWithRentHouseModel:(FHHouseRentDataItemsModel *)model
{
    self.houseVideoImageView.hidden = YES;
    self.mainTitleLabel.text = model.title;
    self.subTitleLabel.text = model.subtitle;
    NSAttributedString * attributeString =  [FHSingleImageInfoCellModel tagsStringSmallImageWithTagList:model.tags];
    self.tagLabel.attributedText =  attributeString;
    self.priceLabel.text = model.pricingNum;
    self.pricePerSqmLabel.text = model.pricingUnit;
    self.pricePerSqmLabel.textColor = [UIColor themeRed1];

    FHImageModel *imageModel = [model.houseImage firstObject];
    [self updateMainImageWithUrl:imageModel.url];
    
    if (model.houseImageTag.text && model.houseImageTag.backgroundColor && model.houseImageTag.textColor) {
        self.imageTagLabel.textColor = [UIColor colorWithHexString:model.houseImageTag.textColor];
        self.imageTagLabel.text = model.houseImageTag.text;
        self.imageTagLabelBgView.backgroundColor = [UIColor colorWithHexString:model.houseImageTag.backgroundColor];
        self.imageTagLabelBgView.hidden = NO;
    }else {
        self.imageTagLabelBgView.hidden = YES;
    }
    
    [self updateImageTopLeft];
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
    if (self.tagLabel.yoga.isIncludedInLayout != showTags) {
        [self.tagLabel configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
            layout.isIncludedInLayout = showTags;
        }];
    }
    
    [self.mainTitleLabel.yoga markDirty];
    [self.rightInfoView.yoga markDirty];
    [self.tagLabel.yoga markDirty];
    [self.priceLabel.yoga markDirty];
    [self.pricePerSqmLabel.yoga markDirty];
    [self.priceBgView.yoga markDirty];
}

- (void)updateFakeHouseImageWithUrl:(NSString *)urlStr andSourceStr:(NSString *)sourceStr
{
    if (self.fakeImageViewContainer) {
        [self.fakeImageViewContainer removeFromSuperview];
        self.fakeImageViewContainer = nil;
    }
    
    if(self.fakeImageView)
    {
        [self.fakeImageView removeFromSuperview];
        self.fakeImageView = nil;
    }
    
    if(urlStr)
    {
        self.fakeImageViewContainer = [UIView new];
        [self.fakeImageViewContainer setBackgroundColor:[UIColor whiteColor]];
        self.fakeImageViewContainer.alpha = 0.5;
        [self.fakeImageViewContainer setFrame:CGRectMake(0, 0, self.mainImageView.frame.size.width, self.mainImageView.frame.size.height)];
        [self.mainImageView addSubview:self.fakeImageViewContainer];
        
        
        self.fakeImageView = [UIImageView new];
        if (urlStr) {
            [self.fakeImageView bd_setImageWithURL:[NSURL URLWithString:urlStr]];
        }
        [self.mainImageView addSubview:self.fakeImageView];
        
        [self.fakeImageView setFrame:CGRectMake((self.mainImageView.frame.size.width - 100) / 2, (self.mainImageView.frame.size.height - 39) / 2, 100, 39)];
    }
    
    if (sourceStr) {
        self.tagLabel.text = [NSString stringWithFormat:@" %@",sourceStr];
        self.tagLabel.textColor = [UIColor themeGray3];
        self.tagLabel.font = [UIFont themeFontRegular:12];
    }
    
    self.imageTagLabel.hidden = YES;
    self.imageTagLabelBgView.hidden = YES;
}

- (void)updateThirdPartHouseSourceStr:(NSString *)sourceStr
{
    self.tagLabel.text = [NSString stringWithFormat:@"%@",sourceStr];
    self.tagLabel.textColor = [UIColor themeGray3];
    self.tagLabel.font = [UIFont themeFontRegular:12];
}

-(void)hideRecommendReason
{
    if ( _recReasonView && self.recReasonView.yoga.isIncludedInLayout) {
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
#pragma mark 字符串处理
-(NSAttributedString *)originPriceAttr:(NSString *)originPrice {
    
    if (originPrice.length < 1) {
        return nil;
    }
    NSMutableAttributedString *attri = [[NSMutableAttributedString alloc] initWithString:originPrice];
    [attri addAttribute:NSStrikethroughStyleAttributeName value:@(NSUnderlineStyleSingle) range:NSMakeRange(0, originPrice.length)];
    [attri addAttribute:NSStrikethroughColorAttributeName value:[UIColor themeGray3] range:NSMakeRange(0, originPrice.length)];
    return attri;
}

- (void)dislike {
    //    __weak typeof(self) wself = self;
    //    FHHouseDislikeView *dislikeView = [[FHHouseDislikeView alloc] init];
    //    FHHouseDislikeViewModel *viewModel = [[FHHouseDislikeViewModel alloc] init];
    //    viewModel.keywords = @[
    //                           @{
    //                               @"id" : @"1",
    //                               @"name":@"看过了看过了",
    //                               @"mutual_exclusive_ids":@[@2,@5],
    //                               },
    //                           @{
    //                               @"id" : @"2",
    //                               @"name":@"内容太水"
    //                               },
    //                           @{
    //                               @"id" : @"3",
    //                               @"name":@"不想看",
    //                               @"mutual_exclusive_ids":@[@4],
    //                               },
    //                           @{
    //                               @"id" : @"4",
    //                               @"name":@"不想看不想看",
    //                               @"mutual_exclusive_ids":@[@3],
    //                               },
    //                           @{
    //                               @"id" : @"5",
    //                               @"name":@"一点意思都没有"
    //                               },
    //                           ];
    //    viewModel.groupID = self.cellModel.houseId;
    ////    viewModel.logExtra = self.orderedData.log_extra;
    //    [dislikeView refreshWithModel:viewModel];
    //    CGPoint point = self.closeBtn.center;
    //    [dislikeView showAtPoint:point
    //                    fromView:self.closeBtn
    //             didDislikeBlock:^(FHHouseDislikeView * _Nonnull view) {
    //                 [wself dislikeConfirm:view];
    //             }];
}

- (void)dislikeConfirm:(FHHouseDislikeView *)view {
    if(self.delegate && [self.delegate respondsToSelector:@selector(dislikeConfirm:)] && self.homeItemModel){
        [self.delegate dislikeConfirm:self.homeItemModel.idx];
    }
}

@end
