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
#import "FHHouseRecommendReasonView.h"
#import "UIButton+TTAdditions.h"
#import "FHHouseDislikeView.h"
#import "FHHomeRequestAPI.h"
#import "ToastManager.h"
#import "TTReachability.h"

#define MAIN_NORMAL_TOP     10
#define MAIN_FIRST_TOP      20
#define MAIN_IMG_WIDTH      114
#define MAIN_IMG_HEIGHT     85
#define MAIN_TAG_BG_WIDTH   48
#define MAIN_TAG_BG_HEIGHT  16
#define MAIN_TAG_WIDTH      46
#define MAIN_TAG_HEIGHT     10
#define INFO_TO_ICON_MARGIN 12
#define PRICE_BG_TOP_MARGIN 5

#define YOGA_RIGHT_PRICE_WIDITH 72


@interface FHHouseBaseItemCell ()

@property(nonatomic, strong) FHSingleImageInfoCellModel *cellModel;
//首页的小图model
@property(nonatomic, strong) FHHomeHouseDataItemsModel *homeItemModel;

@property(nonatomic, strong) UIView *leftInfoView;

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
@property(nonatomic, strong) UIButton *closeBtn; //x按钮

@property(nonatomic, strong) FHHouseRecommendReasonView *recReasonView; //榜单

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

+(CGFloat)recommendReasonHeight
{
    return 22;
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        if (reuseIdentifier && [reuseIdentifier isEqualToString:@"FHHomeSmallImageItemCell"]) {
            [self initSmallImageUI];
        }else
        {
            [self initUI];
        }
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

- (UIButton *)closeBtn {
    if (!_closeBtn) {
        _closeBtn = [[UIButton alloc] init];
        _closeBtn.hidden = YES;
        [_closeBtn setImage:[UIImage imageNamed:@"small_icon_close"] forState:UIControlStateNormal];
        [_closeBtn addTarget:self action:@selector(dislike) forControlEvents:UIControlEventTouchUpInside];
        _closeBtn.hitTestEdgeInsets = UIEdgeInsetsMake(-5, -10, -5, -5);
    }
    return _closeBtn;
}

-(CGFloat)contentMaxWidth
{
    return  SCREEN_WIDTH - 170; //根据UI图 直接计算出来
}

-(CGFloat)contentSmallImageMaxWidth
{
    return  SCREEN_WIDTH - 40 - YOGA_RIGHT_PRICE_WIDITH - 90; //根据UI图 直接计算出来
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
    
    [self.leftInfoView addSubview:self.houseVideoImageView];
    [_houseVideoImageView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.position = YGPositionTypeAbsolute;
        layout.top = YGPointValue(28);
        layout.left = YGPointValue(42);
        layout.width = YGPointValue(30);
        layout.height = YGPointValue(30);
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
        layout.marginTop = YGPointValue(-2);
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
        layout.marginTop = YGPointValue(6);
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
        layout.marginTop = YGPointValue(7);
        layout.alignItems = YGAlignCenter;
    }];
    
    [_priceLabel configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
//        layout.height = YGPointValue(20);
        layout.maxWidth = YGPointValue(130);
//        layout.alignSelf = YGAlignFlexEnd;
//        layout.marginBottom = YGPointValue(-1);
    }];
    
    [_originPriceLabel configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.marginLeft = YGPointValue(6);
        layout.isIncludedInLayout = NO;
//        layout.marginBottom = YGPointValue(0);
    }];
    
    [_pricePerSqmLabel configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.marginLeft = YGPointValue(10);
        layout.flexGrow = 1;
//        layout.marginBottom = YGPointValue(0);
    }];
    
    [_rightInfoView addSubview:self.recReasonView];
    [_recReasonView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isIncludedInLayout = NO;
        layout.marginTop = YGPointValue(4);
        layout.height = YGPointValue(16);
    }];
    _recReasonView.hidden = YES;
    
}

-(void)initSmallImageUI
{
    [self.contentView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.flexDirection = YGFlexDirectionRow;
        layout.paddingLeft = YGPointValue(HOR_MARGIN);
        layout.paddingRight = YGPointValue(HOR_MARGIN);
//        layout.paddingTop = YGPointValue(10);
        layout.width = YGPointValue(SCREEN_WIDTH);
        layout.flexGrow = 1;
//        layout.justifyContent = YGAlignCenter;
//        layout.alignItems = YGAlignCenter;
    }];
    
    self.leftInfoView = [[UIView alloc] init];
    [_leftInfoView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.width = YGPointValue(75);
        layout.height = YGPointValue(75);
    }];
    
    [self.contentView addSubview:_leftInfoView];
    [_leftInfoView addSubview:self.mainImageView];
    [_leftInfoView addSubview:self.imageTagLabelBgView];
    [_imageTagLabelBgView addSubview:self.imageTagLabel];
    
    [_mainImageView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.position = YGPositionTypeAbsolute;
        layout.top = YGPointValue(10.f);
        layout.width = YGPointValue(70.0f);
        layout.height = YGPointValue(54.0f);
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
//    [_rightInfoView setBackgroundColor:[UIColor redColor]];
    [self.contentView addSubview:_rightInfoView];
    
    [_rightInfoView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.marginLeft = YGPointValue(INFO_TO_ICON_MARGIN);
        layout.flexDirection = YGFlexDirectionColumn;
        layout.flexGrow = 1;
        layout.justifyContent = YGJustifyCenter;
//        layout.alignItems = YGAlignCenter;
        layout.maxWidth = YGPointValue([self contentSmallImageMaxWidth]);
        layout.height = YGPointValue(75);
    }];
    
    [_rightInfoView addSubview:self.mainTitleLabel];
    [_rightInfoView addSubview:self.subTitleLabel];
    [_rightInfoView addSubview:self.statInfoLabel];
    [_rightInfoView addSubview:self.tagLabel];
    
    _mainTitleLabel.font = [UIFont themeFontSemibold:16];
    [_mainTitleLabel configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.marginTop = YGPointValue(0);
        layout.height = YGPointValue(20);
        layout.maxWidth = YGPointValue([self contentSmallImageMaxWidth]);
    }];
    
    [_subTitleLabel configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.marginTop = YGPointValue(0);
        layout.height = YGPointValue(19);
        layout.maxWidth = YGPointValue([self contentSmallImageMaxWidth]);
        layout.flexGrow = 0;
    }];
    
    [_statInfoLabel configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.marginTop = YGPointValue(0);
        layout.height = YGPointValue(19);
        layout.maxWidth = YGPointValue([self contentSmallImageMaxWidth]);
        layout.flexGrow = 0;
    }];
    
    _tagLabel.font = [UIFont themeFontRegular:10];
    [_tagLabel configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.marginTop = YGPointValue(0);
        layout.marginLeft = YGPointValue(0);
        layout.height = YGPointValue(16);
        layout.maxWidth = YGPointValue([self contentSmallImageMaxWidth]);
    }];
    
    
    _priceBgView = [[UIView alloc] init];
    
//    [_rightInfoView addSubview:_priceBgView];
    _rightInfoView = [[UIView alloc] init];
    [self.contentView addSubview:_priceBgView];
    
    [_priceBgView addSubview:self.priceLabel];
//    [_priceBgView addSubview:self.originPriceLabel];
    [_priceBgView addSubview:self.pricePerSqmLabel];
    [_priceBgView addSubview:self.closeBtn];
    [_priceBgView setBackgroundColor:[UIColor whiteColor]];
    [_priceBgView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.flexDirection = YGFlexDirectionColumn;
        layout.width = YGPointValue(YOGA_RIGHT_PRICE_WIDITH);
        layout.height = YGPointValue(60);
        layout.right = YGPointValue(20);
//        layout.marginRight = YGPointValue(20);
        layout.justifyContent = YGJustifyCenter;
        layout.position = YGPositionTypeAbsolute;
        layout.top = YGPointValue(5);
        layout.alignItems = YGAlignFlexEnd;
    }];

    
    [_priceLabel configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        //        layout.height = YGPointValue(20);
        layout.maxWidth = YGPointValue(YOGA_RIGHT_PRICE_WIDITH);
        //        layout.alignSelf = YGAlignFlexEnd;
        //        layout.marginBottom = YGPointValue(-1);
    }];
    
//    [_originPriceLabel setBackgroundColor:[UIColor whiteColor]];
//    [_originPriceLabel configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
//        layout.isEnabled = YES;
//        layout.marginRight = YGPointValue(20);
//        layout.height = YGPointValue(0);
//        layout.isIncludedInLayout = NO;
//        //        layout.marginBottom = YGPointValue(0);
//    }];
    
    _pricePerSqmLabel.textAlignment = 2;
//    [_pricePerSqmLabel setBackgroundColor:[UIColor yellowColor]];
    [_pricePerSqmLabel configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.maxWidth = YGPointValue(YOGA_RIGHT_PRICE_WIDITH);
        //        layout.marginBottom = YGPointValue(0);
    }];
    
    [_closeBtn configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.marginTop = YGPointValue(8);
        layout.width = YGPointValue(8);
        layout.height = YGPointValue(8);
    }];
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
        [self.mainImageView bd_setImageWithURL:imgUrl placeholder:[FHHouseBaseItemCell placeholderImage]];
    }else{
        self.mainImageView.image = [FHHouseBaseItemCell placeholderImage];
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
    self.homeItemModel = commonModel;
    if((houseType == FHHouseTypeSecondHandHouse || houseType == FHHouseTypeRentHouse) && commonModel.dislikeInfo){
        self.closeBtn.hidden = NO;
    }else{
        self.closeBtn.hidden = YES;
    }
    
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
        
        
        if ([TTDeviceHelper isScreenWidthLarge320]) {
            _priceLabel.font = [UIFont themeFontDINAlternateBold:16];
            _pricePerSqmLabel.font = [UIFont themeFontRegular:10];
            _pricePerSqmLabel.textColor = [UIColor themeRed1];
        }else {
            _priceLabel.font = [UIFont themeFontDINAlternateBold:15];
            _pricePerSqmLabel.font = [UIFont themeFontRegular:10];
            _pricePerSqmLabel.textColor = [UIColor themeRed1];
        }
        
        
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
    [self updateSamllTitlesLayout:attributeString.length > 0];
    
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
    self.houseVideoImageView.hidden = YES;
    _priceBgView.yoga.justifyContent = YGJustifyFlexStart;
    FHImageModel *imageModel = model.images.firstObject;
    [self updateMainImageWithUrl:imageModel.url];
    
    self.imageTagLabelBgView.hidden = YES;
    [self updateImageTopLeft];
    
    self.mainTitleLabel.text = model.displayTitle;
    self.subTitleLabel.text = model.displaySubtitle;
    self.tagLabel.text = model.displayStatsInfo;
    self.priceLabel.text = model.displayPrice;
    
    self.originPriceLabel.text = nil;
    self.pricePerSqmLabel.text = nil;
    self.originPriceLabel.hidden = YES;
    self.pricePerSqmLabel.hidden = YES;
    
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
    self.houseVideoImageView.hidden = YES;
    _priceBgView.yoga.justifyContent = YGJustifyFlexStart;
    FHImageModel *imageModel = model.images.firstObject;
    [self updateMainImageWithUrl:imageModel.url];
    
    self.imageTagLabelBgView.hidden = YES;
    [self updateImageTopLeft];
    
    self.mainTitleLabel.text = model.displayTitle;
    self.subTitleLabel.text = model.displayDescription;
    self.tagLabel.attributedText = self.cellModel.tagsAttrStr;
    
    self.priceLabel.text = model.displayPricePerSqm;
    
    self.originPriceLabel.text = nil;
    self.pricePerSqmLabel.text = nil;
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
        FHImageModel *imageModel = model.images.firstObject;
        [self updateMainImageWithUrl:imageModel.url];
    }
}

#pragma mark 二手房
-(void)updateWithSecondHouseModel:(FHSearchHouseDataItemsModel *)model
{
    self.houseVideoImageView.hidden = !model.houseVideo.hasVideo;
    _priceBgView.yoga.justifyContent = YGJustifyFlexStart;
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
    self.houseVideoImageView.hidden = YES;
    self.mainTitleLabel.text = model.title;
    self.subTitleLabel.text = model.subtitle;
    self.tagLabel.attributedText = self.cellModel.tagsAttrStr;
    self.priceLabel.text = model.pricing;
    self.pricePerSqmLabel.text = nil;
    self.originPriceLabel.text = nil;
    if (!self.originPriceLabel.hidden) {
        self.originPriceLabel.hidden = YES;
        [self.originPriceLabel configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
            layout.isIncludedInLayout = NO;
        }];
    }
    
    
    NSArray *firstRow = [model.bottomText firstObject];
    NSDictionary *bottomText = nil;
    if ([firstRow isKindOfClass:[NSArray class]]) {
        NSDictionary *info = [firstRow firstObject];
        if ([info isKindOfClass:[NSDictionary class]]) {
            bottomText = info;
        }
    }
    
    NSString *infoText = bottomText[@"text"];
    
    if (bottomText && bottomText[@"color"] && !IS_EMPTY_STRING(infoText)) {
        
        NSMutableAttributedString *commuteAttr = [[NSMutableAttributedString alloc]init];
        
        UIImage *clockImg =  SYS_IMG(@"clock_small");
        NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
        attachment.image = clockImg;
        attachment.bounds = CGRectMake(0, -1.5, 12, 12);
        
        NSAttributedString *clockAttr = [NSAttributedString attributedStringWithAttachment:attachment];
        
        [commuteAttr appendAttributedString:clockAttr];
        
        UIColor *textColor = [UIColor colorWithHexStr:bottomText[@"color"]]?:[UIColor themeGray3];
        
        NSDictionary *attr = @{NSFontAttributeName:[UIFont themeFontRegular:12],NSForegroundColorAttributeName:textColor};
        NSAttributedString *timeAttr = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@",infoText] attributes:attr];
        
        [commuteAttr appendAttributedString:timeAttr];
        
        self.distanceLabel.attributedText = commuteAttr;
        
        if (!_distanceLabel){
            [self.distanceLabel configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
                layout.isEnabled = YES;
                layout.marginLeft = YGPointValue(10);
                layout.alignSelf = YGAlignCount;
                layout.flexGrow = 1;
            }];
        }
        [self.priceBgView addSubview:self.distanceLabel];
        //因为有表情 强制计算宽度
        [self.distanceLabel sizeToFit];
        [self.distanceLabel configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
            layout.width = YGPointValue(ceil(self.distanceLabel.frame.size.width));//x 设备上会出现因为小数计算显示不全的，改为上取整
        }];
        _priceBgView.yoga.justifyContent = YGJustifySpaceBetween;
        [self.distanceLabel.yoga markDirty];
    }else{
        [_distanceLabel removeFromSuperview];
        _priceBgView.yoga.justifyContent = YGJustifyFlexStart;
    }
    
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
    self.mainTitleLabel.numberOfLines = showTags?1:2;
    
    BOOL oneRow = showTags || self.cellModel.titleSize.height < 30;
    
    [self.mainTitleLabel configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.marginTop = YGPointValue(oneRow?-2:-5);
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
    [self.rightInfoView.yoga markDirty];
    [self.tagLabel.yoga markDirty];
    
    [self.priceLabel.yoga markDirty];
    [self.originPriceLabel.yoga markDirty];
    [self.pricePerSqmLabel.yoga markDirty];
    
    CGFloat priceBgTopMargin = showTags?PRICE_BG_TOP_MARGIN:(oneRow?6:2);
    if (self.priceBgView.yoga.marginTop.value != priceBgTopMargin) {
        [self.priceBgView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
            layout.marginTop = YGPointValue(priceBgTopMargin);
        }];
        [self.priceBgView.yoga markDirty];
    }

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
    self.tagLabel.text = [NSString stringWithFormat:@" %@",sourceStr];
    self.tagLabel.textColor = [UIColor themeGray3];
    self.tagLabel.font = [UIFont themeFontRegular:12];
}

-(void)updateSamllTitlesLayout:(BOOL)showTags
{
    if (self.tagLabel.yoga.isIncludedInLayout != showTags) {
        [self.tagLabel configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
            layout.isIncludedInLayout = showTags;
        }];
    }
    [self.rightInfoView.yoga markDirty];
    [self.tagLabel.yoga markDirty];
    
    [self.priceLabel.yoga markDirty];
//    [self.originPriceLabel.yoga markDirty];
    [self.pricePerSqmLabel.yoga markDirty];
    
//    CGFloat priceBgTopMargin = showTags?PRICE_BG_TOP_MARGIN:(oneRow?6:2);
//    if (self.priceBgView.yoga.marginTop.value != priceBgTopMargin) {
//        [self.priceBgView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
//            layout.marginTop = YGPointValue(priceBgTopMargin);
//        }];
    [self.priceBgView.yoga markDirty];
//    }
    
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
    NSArray *dislikeInfo = self.homeItemModel.dislikeInfo;
    if(dislikeInfo && [dislikeInfo isKindOfClass:[NSArray class]]){
        __weak typeof(self) wself = self;
        FHHouseDislikeView *dislikeView = [[FHHouseDislikeView alloc] init];
        FHHouseDislikeViewModel *viewModel = [[FHHouseDislikeViewModel alloc] init];
        
        NSMutableArray *keywords = [NSMutableArray array];
        for (FHHomeHouseDataItemsDislikeInfoModel *infoModel in dislikeInfo) {
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            if(infoModel.id){
                [dic setObject:infoModel.id forKey:@"id"];
            }
            if(infoModel.text){
                [dic setObject:infoModel.text forKey:@"name"];
            }
            if(infoModel.mutualExclusiveIds){
                [dic setObject:infoModel.mutualExclusiveIds forKey:@"mutual_exclusive_ids"];
            }
            [keywords addObject:dic];
        }
        
        viewModel.keywords = keywords;
        viewModel.groupID = self.cellModel.houseId;
        //    viewModel.logExtra = self.orderedData.log_extra;
        [dislikeView refreshWithModel:viewModel];
        CGPoint point = self.closeBtn.center;
        [dislikeView showAtPoint:point
                        fromView:self.closeBtn
                 didDislikeBlock:^(FHHouseDislikeView * _Nonnull view) {
                     [wself dislikeConfirm:view];
                 }];
    }
}

- (void)dislikeConfirm:(FHHouseDislikeView *)view {
    if (![TTReachability isNetworkConnected]) {
        [[ToastManager manager] showToast:@"网络异常"];
        return;
    }
    
    NSMutableArray *dislikeInfo = [NSMutableArray array];
    for (FHHouseDislikeWord *word in view.dislikeWords) {
        if(word.isSelected){
            [dislikeInfo addObject:@([word.ID integerValue])];
        }
    }
    //发起请求
    [FHHomeRequestAPI requestHomeHouseDislike:self.homeItemModel.idx houseType:[self.homeItemModel.houseType integerValue] dislikeInfo:dislikeInfo completion:^(bool success, NSError * _Nonnull error) {
        if(success){
            [[ToastManager manager] showToast:@"感谢反馈，将减少推荐类似房源"];
            //代理
            if(self.delegate && [self.delegate respondsToSelector:@selector(dislikeConfirm:cell:)] && self.homeItemModel){
                [self.delegate dislikeConfirm:self.homeItemModel cell:self];
            }
        }else{
            [[ToastManager manager] showToast:@"反馈失败"];
        }
    }];
}

@end
