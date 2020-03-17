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
#import "FHUserTracker.h"
#import "UIImage+FIconFont.h"
#import <lottie-ios/Lottie/LOTAnimationView.h>
#import "UIColor+Theme.h"
#import "FHShadowView.h"

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

#define MAIN_SMALL_IMG_WIDTH   85
#define MAIN_SMALL_IMG_HEIGHT  64
#define MAIN_SMALL_IMG_LEFT    6
#define MAIN_SMALL_IMG_TOP     12
#define MAIN_SMALL_CELL_HEIGHT  88

#define MAIN_SMALL_IMG_BACK_WIDTH   97
#define MAIN_SMALL_IMG_BACK_HEIGHT  76


#define YOGA_RIGHT_PRICE_WIDITH 72


@interface FHHouseBaseItemCell ()

@property(nonatomic, strong) FHSingleImageInfoCellModel *cellModel;
//首页的小图model
@property(nonatomic, strong) FHHomeHouseDataItemsModel *homeItemModel;

@property(nonatomic, strong) UIView *leftInfoView;

@property(nonatomic, strong) UIImageView *houseVideoImageView;

@property(nonatomic, strong) UILabel *imageTagLabel;
@property(nonatomic, strong) FHCornerView *imageTagLabelBgView;
@property(nonatomic, strong) UIView *maskVRImageView;
@property(nonatomic, strong) UIView *houseMainImageBackView;

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
@property(nonatomic, strong) UIView *houseCellBackView; //背景
@property(nonatomic, strong) UIButton *closeBtn; //x按钮
@property (nonatomic, strong) LOTAnimationView *vrLoadingView;

@property(nonatomic, strong) FHHouseRecommendReasonView *recReasonView; //榜单
@property(nonatomic, strong) FHCornerItemLabel *tagTitleLabel; //降 新 榜等标签
@property (nonatomic, assign) CGSize titleSize;
@property (nonatomic, assign) BOOL isHomePage;

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
        _isHomePage = YES;
        if (reuseIdentifier && [reuseIdentifier isEqualToString:@"FHHomeSmallImageItemCell"]) {
            [self initSmallImageUI:YES];
        }else if ([reuseIdentifier isEqualToString:@"FHHouseBaseItemCellSecond"]) {
            [self initSmallImageUI:NO];
        }else if ([reuseIdentifier isEqualToString:@"FHHouseBaseItemCellRent"]) {
            [self initRentHouseImageUI:NO];
        }else if ([reuseIdentifier isEqualToString:@"FHHouseBaseItemCellNeighborhood"]) {
            [self initRentHouseImageUI:NO];
        }else if (reuseIdentifier && [reuseIdentifier isEqualToString:@"FHHomeRentHouseItemCell"]) {
            [self initRentHouseImageUI:YES];
        }else if ([reuseIdentifier isEqualToString:@"FHHouseBaseItemCellList"]) {
            [self initSmallImageUI:NO];
        }else
        {
            [self initUI];
        }
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)resumeVRIcon
{
    if (self.vrLoadingView && !self.vrLoadingView.hidden) {
        [self.vrLoadingView play];
    }
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
        _mainImageView.layer.borderColor = [UIColor colorWithHexString:@"e1e1e1"].CGColor;
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

-(FHCornerItemLabel *)tagTitleLabel {
    if (!_tagTitleLabel) {
        _tagTitleLabel = [[FHCornerItemLabel alloc] init];
        _tagTitleLabel.textAlignment = NSTextAlignmentCenter;
        _tagTitleLabel.font = [UIFont themeFontRegular:10];
        _tagTitleLabel.textColor = [UIColor themeWhite];
        _tagTitleLabel.frame = CGRectMake(0, 0, 16, 16);
    }
    return _tagTitleLabel;
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
        _subTitleLabel.textColor = [UIColor themeGray1];
    }
    return _subTitleLabel;
}

-(YYLabel *)tagLabel
{
    if (!_tagLabel) {
        _tagLabel = [[YYLabel alloc]init];
//        _tagLabel.numberOfLines = 0;
        _tagLabel.font = [UIFont themeFontRegular:12];
        _tagLabel.textColor = [UIColor themeGray3];
//        _tagLabel.lineBreakMode = NSLineBreakByWordWrapping;
    }
    return _tagLabel;
}

-(UILabel *)priceLabel
{
    if (!_priceLabel) {
        _priceLabel = [[UILabel alloc]init];
        _priceLabel.font = [UIFont themeFontSemibold:16];
        _priceLabel.textColor = [UIColor themeRed4];
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
        _pricePerSqmLabel.textColor = [UIColor themeGray1];
    }
    return _pricePerSqmLabel;
}

-(UIView *)houseMainImageBackView
{
    if (!_houseMainImageBackView) {
        _houseMainImageBackView = [[UIView alloc] init];
        _houseMainImageBackView.backgroundColor = [UIColor whiteColor];
        CALayer * layer = _houseMainImageBackView.layer;
        layer.shadowOffset = CGSizeMake(0, 4);
        layer.shadowRadius = 6;
        layer.shadowColor = [UIColor blackColor].CGColor;;
        layer.shadowOpacity = 0.2;
    }
    return _houseMainImageBackView;
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


-(UILabel *)distanceLabel
{
    if (!_distanceLabel) {
        _distanceLabel = [[UILabel alloc] init];
        _distanceLabel.textAlignment = NSTextAlignmentLeft;
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
        UIImage *img = ICON_FONT_IMG(16, @"\U0000e673", [UIColor themeGray5]);
        [_closeBtn setImage:img forState:UIControlStateNormal];
        [_closeBtn addTarget:self action:@selector(dislike) forControlEvents:UIControlEventTouchUpInside];
        _closeBtn.hitTestEdgeInsets = UIEdgeInsetsMake(-10, -20, -10, -20);
    }
    return _closeBtn;
}

-(CGFloat)contentMaxWidth
{
    return  SCREEN_WIDTH - 170; //根据UI图 直接计算出来
}

-(CGFloat)contentSmallImageMaxWidth
{
    return  SCREEN_WIDTH - (_isHomePage ? 20 : 5) - YOGA_RIGHT_PRICE_WIDITH - 90; //根据UI图 直接计算出来
}

-(CGFloat)contentSmallImageTagMaxWidth
{
    return  SCREEN_WIDTH - 65 - YOGA_RIGHT_PRICE_WIDITH - 90; //根据UI图 直接计算出来
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

-(void)initSmallImageUI:(BOOL)isHomePage
{
    _isHomePage = isHomePage;
    CGFloat leftMargin = isHomePage ? HOR_MARGIN : 9;
    CGFloat rightMargin = isHomePage ? HOR_MARGIN : 12;
    self.contentView.backgroundColor = isHomePage ? [UIColor themeGray8] : [UIColor whiteColor];
    [self.contentView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.flexDirection = YGFlexDirectionRow;

        layout.paddingLeft = YGPointValue(leftMargin);
        layout.paddingRight = YGPointValue(leftMargin);
        layout.paddingTop = YGPointValue(0);
        //        layout.paddingTop = YGPointValue(10);

        layout.width = YGPointValue(SCREEN_WIDTH);
        layout.height = YGPointValue(MAIN_SMALL_CELL_HEIGHT);
        layout.flexGrow = 1;
        //        layout.justifyContent = YGAlignCenter;
        //        layout.alignItems = YGAlignCenter;
    }];
    //    [self.contentView setBackgroundColor:[UIColor redColor]];
    
    self.houseCellBackView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:self.houseCellBackView];
    [self.houseCellBackView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.position = YGPositionTypeAbsolute;
        layout.left = YGPointValue(15);
        layout.right = YGPointValue(15);
        layout.top = YGPointValue(0);
        layout.width = YGPointValue(SCREEN_WIDTH - 30);
        layout.height = YGPointValue(MAIN_SMALL_CELL_HEIGHT);
        layout.flexGrow = 1;
    }];
    [self.houseCellBackView setBackgroundColor:[UIColor whiteColor]];
    self.houseCellBackView.hidden = !isHomePage;
    
    self.leftInfoView = [[UIView alloc] init];
    [_leftInfoView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.position = YGPositionTypeAbsolute;
        layout.width = YGPointValue(97);
        layout.left = YGPointValue(leftMargin);
        layout.top = YGPointValue(0);
        layout.height = YGPointValue(MAIN_SMALL_CELL_HEIGHT);
    }];
    
    [self.contentView addSubview:_leftInfoView];
    [_leftInfoView addSubview:self.houseMainImageBackView];
    [_leftInfoView addSubview:self.mainImageView];
    
        [_leftInfoView addSubview:self.imageTagLabelBgView];
        [_imageTagLabelBgView addSubview:self.imageTagLabel];
    
    [_mainImageView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.position = YGPositionTypeAbsolute;
        layout.top = YGPointValue(MAIN_SMALL_IMG_TOP);
        layout.left = YGPointValue(MAIN_SMALL_IMG_LEFT);
        layout.width = YGPointValue(MAIN_SMALL_IMG_WIDTH);
        layout.height = YGPointValue(MAIN_SMALL_IMG_HEIGHT);
    }];
    
    [self.houseMainImageBackView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.position = YGPositionTypeAbsolute;
        layout.top = YGPointValue(MAIN_SMALL_IMG_TOP + 3);
        layout.left = YGPointValue(MAIN_SMALL_IMG_LEFT + 3);
        layout.width = YGPointValue(MAIN_SMALL_IMG_WIDTH - 6);
        layout.height = YGPointValue(MAIN_SMALL_IMG_HEIGHT - 6);
    }];
    
    [self.leftInfoView addSubview:self.houseVideoImageView];
    
    [_houseVideoImageView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.position = YGPositionTypeAbsolute;
        layout.top = YGPointValue(MAIN_SMALL_IMG_HEIGHT - 10);
        layout.left = YGPointValue(12);
        layout.width = YGPointValue(16);
        layout.height = YGPointValue(16.0f);
    }];
    
    
    _rightInfoView = [[UIView alloc] init];
    [self.contentView addSubview:_rightInfoView];
    
    [_rightInfoView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.position = YGPositionTypeAbsolute;
        layout.left = YGPointValue((isHomePage ? 113 : 102) + INFO_TO_ICON_MARGIN);
        layout.flexDirection = YGFlexDirectionColumn;
        layout.flexGrow = 1;
        layout.top = YGPointValue(0);
        layout.justifyContent = YGJustifyFlexStart;
        //        layout.alignItems = YGAlignCenter;
        layout.maxWidth = YGPointValue([self contentSmallImageMaxWidth]);
        layout.height = YGPointValue(MAIN_SMALL_CELL_HEIGHT);
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
        layout.marginTop = YGPointValue(12);
        layout.height = YGPointValue(22);
        layout.maxWidth = YGPointValue([self contentSmallImageMaxWidth]);
    }];
    [titleView addSubview:self.mainTitleLabel];
    [titleView addSubview:self.tagTitleLabel];
    
    if ([TTDeviceHelper isScreenWidthLarge320]) {
        _mainTitleLabel.font = [UIFont themeFontSemibold:18];
    }else {
        _mainTitleLabel.font = [UIFont themeFontSemibold:16];
    }
    
    [_mainTitleLabel configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.marginTop = YGPointValue(0);
        layout.height = YGPointValue(20);
        layout.maxWidth = YGPointValue([self contentSmallImageMaxWidth]);
    }];
    
    _tagTitleLabel.hidden = YES;
    [_tagTitleLabel configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.marginTop = YGPointValue(1.5);
        layout.marginLeft = YGPointValue(4);
        layout.height = YGPointValue(16);
        layout.width = YGPointValue(16);
    }];
    
    [_subTitleLabel configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.marginTop = YGPointValue(1);
        layout.height = YGPointValue(19);
        layout.maxWidth = YGPointValue([self contentSmallImageMaxWidth] - 36);
        layout.flexGrow = 0;
    }];
    
    [_statInfoLabel configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.marginTop = YGPointValue(0);
        layout.height = YGPointValue(19);
        layout.maxWidth = YGPointValue([self contentSmallImageTagMaxWidth]);
        layout.flexGrow = 0;
    }];
    CGFloat maxWidth = [self contentSmallImageMaxWidth] - 45;
    if (_isHomePage) {
        maxWidth = [self contentSmallImageMaxWidth] - 60;
    }
    [_tagLabel configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.marginTop = YGPointValue(8);
        layout.marginLeft = YGPointValue(0);
        layout.height = YGPointValue(16);
        layout.maxWidth = YGPointValue(maxWidth);
    }];
    
    _priceBgView = [[UIView alloc] init];
    
    //    [_rightInfoView addSubview:_priceBgView];r
    _rightInfoView = [[UIView alloc] init];
    [self.contentView addSubview:_priceBgView];
    
    [_priceBgView addSubview:self.closeBtn];
    [_priceBgView addSubview:self.pricePerSqmLabel];
    [_priceBgView addSubview:self.priceLabel];
    
    [_priceBgView setBackgroundColor:[UIColor clearColor]];
    [_priceBgView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.flexGrow = 1;
        layout.flexDirection = YGFlexDirectionColumn;
        layout.width = YGPointValue(YOGA_RIGHT_PRICE_WIDITH + rightMargin);
        layout.height = YGPointValue(MAIN_SMALL_CELL_HEIGHT);
        layout.right = YGPointValue(0);
        layout.top = YGPointValue(0);
        layout.right = YGPointValue(3);
        layout.justifyContent = YGJustifyFlexStart;
        layout.position = YGPositionTypeAbsolute;
        layout.alignItems = YGAlignFlexEnd;
    }];
    
    [_closeBtn configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.right = YGPointValue(rightMargin);
        layout.marginTop = YGPointValue(14);
        layout.width = YGPointValue(16);
        layout.height = YGPointValue(16);
    }];
    
    _pricePerSqmLabel.textAlignment = 2;
    [_pricePerSqmLabel configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.marginTop = YGPointValue(6);
        layout.right = YGPointValue(rightMargin);
        layout.maxWidth = YGPointValue(YOGA_RIGHT_PRICE_WIDITH);
    }];
    
    [_priceLabel configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.right = YGPointValue(rightMargin);
        layout.marginTop = YGPointValue(6);
        layout.maxWidth = YGPointValue(YOGA_RIGHT_PRICE_WIDITH);
    }];
    
    
    [_rightInfoView addSubview:self.recReasonView];
    [_recReasonView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isIncludedInLayout = NO;
        layout.marginTop = YGPointValue(6);
        layout.height = YGPointValue(16);
    }];
    _recReasonView.hidden = YES;
    
}

-(void)initRentHouseImageUI:(BOOL)isHomePage
{
    _isHomePage = isHomePage;
    
    CGFloat leftMargin = isHomePage ? HOR_MARGIN : 9;
    CGFloat rightMargin = isHomePage ? HOR_MARGIN : 12;
    self.contentView.backgroundColor = isHomePage ? [UIColor themeGray8] : [UIColor whiteColor];
    
    [self.contentView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.flexDirection = YGFlexDirectionRow;
        layout.paddingLeft = YGPointValue(leftMargin);
        layout.paddingRight = YGPointValue(rightMargin);
        layout.paddingTop = YGPointValue(0);
        //        layout.paddingTop = YGPointValue(10);
        layout.width = YGPointValue(SCREEN_WIDTH);
        layout.height = YGPointValue(MAIN_SMALL_CELL_HEIGHT);
        layout.flexGrow = 1;
        //        layout.justifyContent = YGAlignCenter;
        //        layout.alignItems = YGAlignCenter;
    }];
    //    [self.contentView setBackgroundColor:[UIColor redColor]];
    
    self.houseCellBackView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:self.houseCellBackView];
    [self.houseCellBackView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.position = YGPositionTypeAbsolute;
        layout.left = YGPointValue(15);
        layout.right = YGPointValue(15);
        layout.top = YGPointValue(0);
        layout.width = YGPointValue(SCREEN_WIDTH - 30);
        layout.height = YGPointValue(MAIN_SMALL_CELL_HEIGHT);
        layout.flexGrow = 1;
    }];
    [self.houseCellBackView setBackgroundColor:[UIColor whiteColor]];
    self.houseCellBackView.hidden = !isHomePage;
    
    self.leftInfoView = [[UIView alloc] init];
    [_leftInfoView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.position = YGPositionTypeAbsolute;
        layout.width = YGPointValue(97);
        layout.left = YGPointValue(leftMargin);
        layout.top = YGPointValue(0);
        layout.height = YGPointValue(MAIN_SMALL_CELL_HEIGHT);
    }];
    
    [self.contentView addSubview:_leftInfoView];
    [_leftInfoView addSubview:self.houseMainImageBackView];
    [_leftInfoView addSubview:self.mainImageView];
    
        [_leftInfoView addSubview:self.imageTagLabelBgView];
        [_imageTagLabelBgView addSubview:self.imageTagLabel];
    
    [_mainImageView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.position = YGPositionTypeAbsolute;
        layout.top = YGPointValue(MAIN_SMALL_IMG_TOP);
        layout.left = YGPointValue(MAIN_SMALL_IMG_LEFT);
        layout.width = YGPointValue(MAIN_SMALL_IMG_WIDTH);
        layout.height = YGPointValue(MAIN_SMALL_IMG_HEIGHT);
    }];
    
    [self.houseMainImageBackView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.position = YGPositionTypeAbsolute;
        layout.top = YGPointValue(MAIN_SMALL_IMG_TOP + 3);
        layout.left = YGPointValue(MAIN_SMALL_IMG_LEFT + 3);
        layout.width = YGPointValue(MAIN_SMALL_IMG_WIDTH - 6);
        layout.height = YGPointValue(MAIN_SMALL_IMG_HEIGHT - 6);
    }];
    
    [self.leftInfoView addSubview:self.houseVideoImageView];
    _houseVideoImageView.image = [UIImage imageNamed:@"icon_list_house_video_small"];
    
    [_houseVideoImageView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.position = YGPositionTypeAbsolute;
        layout.top = YGPointValue(MAIN_SMALL_IMG_HEIGHT - 10);
        layout.left = YGPointValue(12);
        layout.width = YGPointValue(16);
        layout.height = YGPointValue(16.0f);
    }];
    
    _rightInfoView = [[UIView alloc] init];
    [self.contentView addSubview:_rightInfoView];

    [_rightInfoView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.position = YGPositionTypeAbsolute;
        layout.left = YGPointValue((isHomePage ? 113 : 102) + INFO_TO_ICON_MARGIN);
        layout.flexDirection = YGFlexDirectionColumn;
//        layout.flexGrow = 1;
        layout.top = YGPointValue(0);
        layout.justifyContent = YGJustifyFlexStart;
        //        layout.alignItems = YGAlignCenter;
        layout.maxWidth = YGPointValue([self contentSmallImageMaxWidth]);
        layout.height = YGPointValue(MAIN_SMALL_CELL_HEIGHT);
    }];
    
    UIView *titleView = [[UIView alloc] init];
    [_rightInfoView addSubview:titleView];
    [_rightInfoView addSubview:self.subTitleLabel];
    [_rightInfoView addSubview:self.statInfoLabel];
    [_rightInfoView addSubview:self.tagLabel];
    [_rightInfoView addSubview:self.distanceLabel];

    [titleView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.flexDirection = YGFlexDirectionRow;
        layout.paddingLeft = YGPointValue(0);
        layout.paddingRight = YGPointValue(0);
        layout.alignItems = YGAlignFlexStart;
        layout.marginTop = YGPointValue(12);
        layout.height = YGPointValue(22);
        layout.maxWidth = YGPointValue([self contentSmallImageMaxWidth]);
    }];
    [titleView addSubview:self.mainTitleLabel];
    [titleView addSubview:self.tagTitleLabel];
    
    _mainTitleLabel.font = [UIFont themeFontSemibold:18];
    [_mainTitleLabel configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.marginTop = YGPointValue(0);
        layout.height = YGPointValue(20);
        layout.maxWidth = YGPointValue([self contentSmallImageMaxWidth]);
    }];
    
    _tagTitleLabel.hidden = YES;
    [_tagTitleLabel configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.marginTop = YGPointValue(1.5);
        layout.marginLeft = YGPointValue(4);
        layout.height = YGPointValue(16);
        layout.width = YGPointValue(16);
    }];
    
    [_subTitleLabel configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.marginTop = YGPointValue(1);
        layout.height = YGPointValue(19);
        layout.maxWidth = YGPointValue([self contentSmallImageMaxWidth] - 36);
        layout.flexGrow = 0;
    }];
    
    [_statInfoLabel configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.marginTop = YGPointValue(0);
        layout.height = YGPointValue(19);
        layout.maxWidth = YGPointValue([self contentSmallImageTagMaxWidth]);
        layout.flexGrow = 0;
    }];
    
    CGFloat maxWidth = [self contentSmallImageMaxWidth] - 45;
    if (_isHomePage) {
        maxWidth = [self contentSmallImageMaxWidth] - 60;
    }
    [_tagLabel configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.marginTop = YGPointValue(8);
        layout.marginLeft = YGPointValue(0);
        layout.height = YGPointValue(16);
        layout.maxWidth = YGPointValue(maxWidth);
    }];
    self.distanceLabel.hidden = YES;
    [self.distanceLabel configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.marginTop = YGPointValue(8);
        layout.marginLeft = YGPointValue(0);
        layout.height = YGPointValue(16);
        layout.maxWidth = YGPointValue([self contentSmallImageTagMaxWidth] - 10);
    }];
    
    _priceBgView = [[UIView alloc] init];
    
    //    [_rightInfoView addSubview:_priceBgView];
    _rightInfoView = [[UIView alloc] init];
    [self.contentView addSubview:_priceBgView];
    
    [_priceBgView addSubview:self.closeBtn];
    [_priceBgView addSubview:self.pricePerSqmLabel];
    [_priceBgView addSubview:self.priceLabel];
    
    [_priceBgView setBackgroundColor:[UIColor clearColor]];
    [_priceBgView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.flexGrow = 1;
        layout.flexDirection = YGFlexDirectionColumn;
        layout.width = YGPointValue(YOGA_RIGHT_PRICE_WIDITH + 20);
        layout.height = YGPointValue(MAIN_SMALL_CELL_HEIGHT);
        layout.right = YGPointValue(0);
        layout.top = YGPointValue(0);
        layout.right = YGPointValue(3);
        layout.justifyContent = YGJustifyFlexStart;
        layout.position = YGPositionTypeAbsolute;
        layout.alignItems = YGAlignFlexEnd;
    }];
    
    [_closeBtn configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.right = YGPointValue(20);
        layout.marginTop = YGPointValue(14);
        layout.width = YGPointValue(16);
        layout.height = YGPointValue(16);
    }];
    
    //    _pricePerSqmLabel.textAlignment = 2;
    //    [_pricePerSqmLabel configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
    //        layout.isEnabled = YES;
    //        layout.marginTop = YGPointValue(6);
    //        layout.right = YGPointValue(20);
    //        layout.maxWidth = YGPointValue(YOGA_RIGHT_PRICE_WIDITH);
    //    }];
    
    [_priceLabel configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.right = YGPointValue(rightMargin);
        layout.marginTop = YGPointValue(28.5);
        layout.maxWidth = YGPointValue(YOGA_RIGHT_PRICE_WIDITH + 20);
    }];
    
    
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
//        [self updateTitlesLayout:YES];
    
    [self.contentView.yoga applyLayoutPreservingOrigin:NO];
}

-(void)updateHomeSmallImageHouseCellModel:(FHHomeHouseDataItemsModel *)commonModel andType:(FHHouseType)houseType
{
    self.homeItemModel = commonModel;
    //不感兴趣x按钮
    if((houseType == FHHouseTypeSecondHandHouse || houseType == FHHouseTypeRentHouse) && commonModel.dislikeInfo){
        self.closeBtn.hidden = NO;
        [self.closeBtn configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
            layout.isIncludedInLayout = YES;
        }];
    }else{
        self.closeBtn.hidden = YES;
        [self.closeBtn configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
            layout.isIncludedInLayout = NO;
        }];
    }
    
    self.houseVideoImageView.hidden = !commonModel.houseVideo.hasVideo;
    self.mainTitleLabel.text = commonModel.displayTitle;
    self.subTitleLabel.text = commonModel.displayDescription;
    NSAttributedString *attributeString = nil;
    if (commonModel.reasonTags.count > 0) {
        FHHouseTagsModel *element = commonModel.reasonTags.firstObject;
        if (element.content && element.textColor && element.backgroundColor) {
            UIColor *textColor = [UIColor colorWithHexString:element.textColor] ? : [UIColor themeRed4];
            UIColor *backgroundColor = [UIColor colorWithHexString:element.backgroundColor] ? : [UIColor whiteColor];
            attributeString = [FHSingleImageInfoCellModel createTagAttrString:element.content textColor:textColor backgroundColor:backgroundColor];
            _tagLabel.lineBreakMode = NSLineBreakByTruncatingTail;

        }
    }else {
        _tagLabel.lineBreakMode = NSLineBreakByWordWrapping;
        CGFloat maxWidth = [self contentSmallImageMaxWidth] - 60;
        attributeString = [FHSingleImageInfoCellModel newTagsStringWithTagList:commonModel.tags maxWidth:maxWidth];
    }
    self.tagLabel.attributedText =  attributeString;
    self.priceLabel.text = commonModel.displayPricePerSqm;
    //    UIImage *placeholder = [FHHouseBaseItemCell placeholderImage];
    FHImageModel *imageModel = commonModel.images.firstObject;
    [self updateMainImageWithUrl:imageModel.url];
    
    if (houseType == FHHouseTypeSecondHandHouse) {
        FHImageModel *imageModel = commonModel.houseImage.firstObject;
        [self updateMainImageWithUrl:imageModel.url];
        self.subTitleLabel.text = commonModel.displaySubtitle;
        
        _priceLabel.font = [UIFont themeFontSemibold:[TTDeviceHelper isScreenWidthLarge320] ? 16 : 15];
        _pricePerSqmLabel.textColor = [UIColor themeGray1];
        _pricePerSqmLabel.font = [UIFont themeFontRegular:12];
        self.priceLabel.text = commonModel.displayPrice;
        if (commonModel.originPrice) {
            self.pricePerSqmLabel.attributedText = [self originPriceAttr:commonModel.originPrice];
        }else{
            self.pricePerSqmLabel.text = commonModel.displayPricePerSqm;
        }
        
        if (self.maskVRImageView) {
            [self.maskVRImageView removeFromSuperview];
            self.maskVRImageView = nil;
        }
        
        if (commonModel.vrInfo.hasVr) {
            if (![self.leftInfoView.subviews containsObject:self.vrLoadingView]) {
                [self.leftInfoView addSubview:self.vrLoadingView];
                self.vrLoadingView.hidden = YES;
                //    [self.vrLoadingView setBackgroundColor:[UIColor redColor]];
                [self.vrLoadingView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
                    layout.isEnabled = YES;
                    layout.position = YGPositionTypeAbsolute;
                    layout.top = YGPointValue(MAIN_SMALL_IMG_HEIGHT - 10);
                    layout.left = YGPointValue(12);
                    layout.width = YGPointValue(16);
                    layout.height = YGPointValue(16);
                }];
            }
            
            _vrLoadingView.hidden = NO;
            [_vrLoadingView play];
            self.houseVideoImageView.hidden = YES;
            
            self.maskVRImageView = [UIView new];
            self.maskVRImageView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1];
            [self.mainImageView addSubview:self.maskVRImageView];
            [self.maskVRImageView setFrame:CGRectMake(0.0f, 0.0f, MAIN_IMG_WIDTH, MAIN_IMG_HEIGHT)];
        }else
        {
            if (_vrLoadingView) {
                _vrLoadingView.hidden = YES;
            }
        }
        
        //处理标签
        BOOL imageTagHidden = self.imageTagLabelBgView.hidden;
        if (commonModel.titleTag) {
            self.imageTagLabelBgView.hidden = YES;
            self.tagTitleLabel.hidden = NO;
            [self.mainTitleLabel configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
                layout.maxWidth = YGPointValue([self contentSmallImageMaxWidth] - 20);
            }];
            self.tagTitleLabel.text = commonModel.titleTag.text;
            self.tagTitleLabel.backgroundColor = [UIColor colorWithHexString:commonModel.titleTag.backgroundColor];
            self.tagTitleLabel.textColor = [UIColor colorWithHexString:commonModel.titleTag.textColor];
        } else {
            self.imageTagLabelBgView.hidden = imageTagHidden;
            self.tagTitleLabel.hidden = YES;
            [self.mainTitleLabel configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
                layout.maxWidth = YGPointValue([self contentSmallImageMaxWidth]);
            }];
        }
        [self.mainTitleLabel.yoga markDirty];
    } else if (houseType == FHHouseTypeRentHouse) {
        _mainTitleLabel.numberOfLines = 2;
        self.mainTitleLabel.text = commonModel.title;
        self.subTitleLabel.text = commonModel.subtitle;
        self.priceLabel.text = commonModel.pricing;
        if (commonModel.addrData.length > 0) {
            self.tagLabel.lineBreakMode = NSLineBreakByTruncatingTail;
            attributeString = [FHSingleImageInfoCellModel createTagAttrString:commonModel.addrData textColor:[UIColor themeGray2] backgroundColor:[UIColor whiteColor]];
            self.tagLabel.attributedText =  attributeString;
        }
        [self.mainTitleLabel.yoga markDirty];
        [self.subTitleLabel.yoga markDirty];
        [self.rightInfoView.yoga markDirty];
        
        _priceLabel.font = [UIFont themeFontSemibold:[TTDeviceHelper isScreenWidthLarge320] ? 16 : 15];
        
        FHImageModel *imageModel = [commonModel.houseImage firstObject];
        [self updateMainImageWithUrl:imageModel.url];
        
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
-(void)updateWithOldHouseDetailCellModel:(FHSingleImageInfoCellModel *)cellModel {
    
    _cellModel = cellModel;
    FHSearchHouseDataItemsModel *model  = cellModel.secondModel;
    //    self.closeBtn.hidden = YES;
    //    [self.closeBtn configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
    //        layout.isIncludedInLayout = NO;
    //    }];
    //
    self.houseVideoImageView.hidden =  !model.houseVideo.hasVideo;
    self.mainTitleLabel.text = model.displayTitle;
    self.subTitleLabel.text =model.displaySubtitle;
    NSAttributedString * attributeStrings =  [FHSingleImageInfoCellModel tagsStringSmallImageWithTagList:model.tags];
    self.tagLabel.attributedText =  attributeStrings;
    self.priceLabel.text = model.displayPrice;
    FHImageModel *imageModel = model.houseImage.firstObject;
    [self updateMainImageWithUrl:imageModel.url];
    
    _priceLabel.font = [UIFont themeFontSemibold:[TTDeviceHelper isScreenWidthLarge320] ? 16 : 15];
    _pricePerSqmLabel.textColor = [UIColor themeGray1];
    _pricePerSqmLabel.font = [UIFont themeFontRegular:12];
    if (model.originPrice) {
        self.pricePerSqmLabel.attributedText = [self originPriceAttr:model.originPrice];
    }else{
        self.pricePerSqmLabel.text = model.displayPricePerSqm;
    }
    
    
    self.tagTitleLabel.hidden = YES;
    [self.mainTitleLabel configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.maxWidth = YGPointValue([self contentSmallImageMaxWidth]);
    }];
    [self.mainTitleLabel.yoga markDirty];
    
    [self.contentView.yoga applyLayoutPreservingOrigin:NO];
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
    self.currentData = data;
    if([data isKindOfClass:[FHNewHouseItemModel class]])
    {
        FHNewHouseItemModel *model = (FHNewHouseItemModel *)data;
        self.mainTitleLabel.text = model.displayTitle;
        self.subTitleLabel.text = model.displayDescription;
        self.tagLabel.attributedText = self.cellModel.tagsAttrStr;
        NSAttributedString * attributeString =  [FHSingleImageInfoCellModel tagsStringWithTagList:model.tags];
        self.tagLabel.attributedText =  attributeString;
        self.pricePerSqmLabel.hidden = YES;

        self.priceLabel.text = model.displayPricePerSqm;
        FHImageModel *imageModel = model.images.firstObject;
        [self updateMainImageWithUrl:imageModel.url];
    }else if ([data isKindOfClass:[FHSearchHouseItemModel class]])
    {
        FHSearchHouseItemModel *commonModel = (FHSearchHouseItemModel *)data;
        self.closeBtn.hidden = YES;

        self.priceLabel.text = commonModel.pricePerSqmNum;
        self.pricePerSqmLabel.text = commonModel.pricePerSqmUnit;
        self.pricePerSqmLabel.hidden = NO;

        self.houseVideoImageView.hidden = !commonModel.houseVideo.hasVideo;
        self.mainTitleLabel.text = commonModel.displayTitle;
        self.subTitleLabel.text = commonModel.displayDescription;
        NSAttributedString * attributeString = nil;
        if (commonModel.reasonTags.count > 0) {
            FHHouseTagsModel *element = commonModel.reasonTags.firstObject;
            if (element.content && element.textColor && element.backgroundColor) {
                UIColor *textColor = [UIColor colorWithHexString:element.textColor] ? : [UIColor themeRed4];
                UIColor *backgroundColor = [UIColor colorWithHexString:element.backgroundColor] ? : [UIColor whiteColor];
                attributeString = [FHSingleImageInfoCellModel createTagAttrString:element.content textColor:textColor backgroundColor:backgroundColor];
                _tagLabel.lineBreakMode = NSLineBreakByTruncatingTail;
            }
        }else {
            CGFloat maxWidth = [self contentSmallImageMaxWidth] - 45;
            attributeString = [FHSingleImageInfoCellModel newTagsStringWithTagList:commonModel.tags maxWidth:maxWidth];
            _tagLabel.lineBreakMode = NSLineBreakByWordWrapping;
        }
        self.priceLabel.text = commonModel.displayPricePerSqm;
        //    UIImage *placeholder = [FHHouseBaseItemCell placeholderImage];
        FHImageModel *imageModel = commonModel.images.firstObject;
        [self updateMainImageWithUrl:imageModel.url];
        
        FHHouseType houseType = commonModel.houseType.integerValue;
        if (houseType == FHHouseTypeSecondHandHouse) {
           
            _priceLabel.font = [UIFont themeFontSemibold:[TTDeviceHelper isScreenWidthLarge320] ? 16 : 15];
            _pricePerSqmLabel.textColor = [UIColor themeGray1];
            _pricePerSqmLabel.font = [UIFont themeFontRegular:12];
            
            self.tagLabel.attributedText =  attributeString;
            
            FHImageModel *imageModel = commonModel.houseImage.firstObject;
            [self updateMainImageWithUrl:imageModel.url];
            self.subTitleLabel.text = commonModel.displaySubtitle;
            self.priceLabel.text = commonModel.displayPrice;
            if (commonModel.originPrice) {
                self.pricePerSqmLabel.attributedText = [self originPriceAttr:commonModel.originPrice];
            }else{
//                self.pricePerSqmLabel.text = commonModel.displayPricePerSqm;
                self.pricePerSqmLabel.attributedText = [[NSMutableAttributedString alloc]initWithString:commonModel.displayPricePerSqm attributes:@{}];
            }
            [self.pricePerSqmLabel.yoga markDirty];
            if (commonModel.houseImageTag.text && commonModel.houseImageTag.backgroundColor && commonModel.houseImageTag.textColor) {
                self.imageTagLabel.textColor = [UIColor colorWithHexString:commonModel.houseImageTag.textColor];
                self.imageTagLabel.text = commonModel.houseImageTag.text;
                self.imageTagLabelBgView.backgroundColor = [UIColor colorWithHexString:commonModel.houseImageTag.backgroundColor];
                self.imageTagLabelBgView.hidden = NO;
            }else {
                
                self.imageTagLabelBgView.hidden = YES;
            }
            if (self.maskVRImageView) {
                [self.maskVRImageView removeFromSuperview];
                self.maskVRImageView = nil;
            }
            
            if (commonModel.vrInfo.hasVr) {
                if (![self.leftInfoView.subviews containsObject:self.vrLoadingView]) {
                    [self.leftInfoView addSubview:self.vrLoadingView];
                    self.vrLoadingView.hidden = YES;
                    //    [self.vrLoadingView setBackgroundColor:[UIColor redColor]];
                    [self.vrLoadingView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
                        layout.isEnabled = YES;
                        layout.position = YGPositionTypeAbsolute;
                        layout.top = YGPointValue(MAIN_SMALL_IMG_HEIGHT - 10);
                        layout.left = YGPointValue(12);
                        layout.width = YGPointValue(16);
                        layout.height = YGPointValue(16);
                    }];
                }
                
                _vrLoadingView.hidden = NO;
                [_vrLoadingView play];
                self.houseVideoImageView.hidden = YES;
                
                self.maskVRImageView = [UIView new];
                self.maskVRImageView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1];
                [self.mainImageView addSubview:self.maskVRImageView];
                [self.maskVRImageView setFrame:CGRectMake(0.0f, 0.0f, MAIN_IMG_WIDTH, MAIN_IMG_HEIGHT)];
            }else
            {
                if (_vrLoadingView) {
                    _vrLoadingView.hidden = YES;
                }
            }
            //处理标签
            BOOL imageTagHidden = self.imageTagLabelBgView.hidden;
            if (commonModel.houseTitleTag) {
                self.imageTagLabelBgView.hidden = YES;
                self.tagTitleLabel.hidden = NO;
                [self.mainTitleLabel configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
                    layout.maxWidth = YGPointValue([self contentSmallImageMaxWidth] - 20);
                }];
                self.tagTitleLabel.text = commonModel.houseTitleTag.text;
                self.tagTitleLabel.backgroundColor = [UIColor colorWithHexString:commonModel.houseTitleTag.backgroundColor];
                self.tagTitleLabel.textColor = [UIColor colorWithHexString:commonModel.houseTitleTag.textColor];
            } else {
                self.imageTagLabelBgView.hidden = imageTagHidden;
                self.tagTitleLabel.hidden = YES;
                [self.mainTitleLabel configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
                    layout.maxWidth = YGPointValue([self contentSmallImageMaxWidth]);
                }];
            }
            [self.mainTitleLabel.yoga markDirty];
            [self updateSamllTitlesLayout:attributeString.length > 0];
        } else if (houseType == FHHouseTypeRentHouse) {
            
            self.tagLabel.attributedText =  attributeString;
            _priceLabel.font = [UIFont themeFontSemibold:[TTDeviceHelper isScreenWidthLarge320] ? 16 : 15];

            NSArray *firstRow = [commonModel.bottomText firstObject];
            NSDictionary *bottomText = nil;
            if ([firstRow isKindOfClass:[NSArray class]]) {
                NSDictionary *info = [firstRow firstObject];
                if ([info isKindOfClass:[NSDictionary class]]) {
                    bottomText = info;
                }
            }
            [self updateBottomText:bottomText];
            
            self.mainTitleLabel.text = commonModel.title;
            self.subTitleLabel.text = commonModel.subtitle;
            self.priceLabel.text = commonModel.pricing;
            self.pricePerSqmLabel.text = nil;
            self.pricePerSqmLabel.hidden = YES;
//            [_tagLabel configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
//                layout.maxWidth = YGPointValue([self contentSmallImageTagMaxWidth]);
//            }];
            if (commonModel.addrData.length > 0) {
                self.tagLabel.lineBreakMode = NSLineBreakByTruncatingTail;
                attributeString = [FHSingleImageInfoCellModel createTagAttrString:commonModel.addrData textColor:[UIColor themeGray2] backgroundColor:[UIColor whiteColor]];
                self.tagLabel.attributedText =  attributeString;
            }
            _priceLabel.font = [UIFont themeFontSemibold:[TTDeviceHelper isScreenWidthLarge320] ? 16 : 15];
            [_priceLabel configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
                if (self.priceLabel.yoga.marginTop.value != 28.5) {
                    layout.marginTop = YGPointValue(28.5);
                }
                layout.maxWidth = YGPointValue(YOGA_RIGHT_PRICE_WIDITH + 20);
            }];
            [self.mainTitleLabel.yoga markDirty];
            [self.subTitleLabel.yoga markDirty];
            [self.distanceLabel.yoga markDirty];
            [self.rightInfoView.yoga markDirty];
            [self.rightInfoView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
                layout.flexGrow = 0;
            }];
            FHImageModel *imageModel = [commonModel.houseImage firstObject];
            [self updateMainImageWithUrl:imageModel.url];
            self.imageTagLabelBgView.hidden = YES;
            [self updateSamllTitlesLayout:attributeString.length > 0];
        } else if (houseType == FHHouseTypeNeighborhood) {
            
            self.houseVideoImageView.hidden = !commonModel.houseVideo.hasVideo;
            FHImageModel *imageModel = commonModel.images.firstObject;
            [self updateMainImageWithUrl:imageModel.url];
            _priceLabel.font = [UIFont themeFontSemibold:[TTDeviceHelper isScreenWidthLarge320] ? 16 : 15];

            self.imageTagLabelBgView.hidden = YES;
            [self updateImageTopLeft];
            
            self.mainTitleLabel.text = commonModel.displayTitle;
            self.subTitleLabel.text = commonModel.displaySubtitle;
            self.tagLabel.textColor = [UIColor themeGray2];
            self.tagLabel.font = [UIFont themeFontRegular:12];
            self.tagLabel.text = commonModel.displayStatsInfo;
            self.priceLabel.text = commonModel.displayPrice;
            self.pricePerSqmLabel.text = nil;
            self.pricePerSqmLabel.hidden = YES;
            [self.tagLabel configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
                layout.maxWidth = YGPointValue([self contentSmallImageTagMaxWidth] - 10);
                if (self.tagLabel.yoga.marginLeft.value != 0) {
                    layout.marginLeft = YGPointValue(0);
                }
            }];
            _priceLabel.font = [UIFont themeFontSemibold:[TTDeviceHelper isScreenWidthLarge320] ? 16 : 15];
            [_priceLabel configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
                if (self.priceLabel.yoga.marginTop.value != 28.5) {
                    layout.marginTop = YGPointValue(28.5);
                }
                layout.maxWidth = YGPointValue(YOGA_RIGHT_PRICE_WIDITH + 20);
            }];
            if ([TTDeviceHelper isScreenWidthLarge320]) {
                _priceLabel.font = [UIFont themeFontDINAlternateBold:16];
                _pricePerSqmLabel.font = [UIFont themeFontRegular:10];
                _pricePerSqmLabel.textColor = [UIColor themeRed4];
            }else {
                _priceLabel.font = [UIFont themeFontDINAlternateBold:15];
                _pricePerSqmLabel.font = [UIFont themeFontRegular:10];
                _pricePerSqmLabel.textColor = [UIColor themeRed4];
            }
            
            [self hideRecommendReason];
            [self updateSamllTitlesLayout:YES];
        } else {
            self.pricePerSqmLabel.text = @"";
        }
        
        [self hideRecommendReason];

        [self.contentView.yoga applyLayoutPreservingOrigin:NO];
    }
}

-(void)refreshIndexCorner:(BOOL)isFirst andLast:(BOOL)isLast
{
    if (isFirst) {
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.houseCellBackView.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(15, 15)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = self.houseCellBackView.bounds;
        maskLayer.path = maskPath.CGPath;
        self.houseCellBackView.layer.mask = maskLayer;
    } else if (isLast){
        self.houseCellBackView.layer.mask = nil;
    }else
    {
        self.houseCellBackView.layer.mask = nil;
    }
}

- (void)updateBottomText:(NSDictionary *)bottomText
{
    if (![bottomText isKindOfClass:[NSDictionary class]]) {
        return;
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
        self.distanceLabel.hidden = NO;
        [self.distanceLabel.yoga markDirty];
    }else{
        self.distanceLabel.hidden = YES;
    }
}

+ (CGFloat)heightForData:(id)data
{
    BOOL isLastCell = NO;
    if([data isKindOfClass:[FHSearchHouseItemModel class]]) {
        FHSearchHouseItemModel *model = (FHSearchHouseItemModel *)data;
        isLastCell = model.isLastCell;
        CGFloat reasonHeight = [model showRecommendReason] ? [FHHouseBaseItemCell recommendReasonHeight] : 0;
        return (isLastCell ? 108 : 88) + reasonHeight;
    }
    return 88;
}

#pragma mark 二手房
-(void)updateWithSecondHouseModel:(FHSearchHouseDataItemsModel *)model
{
    self.houseVideoImageView.hidden = !model.houseVideo.hasVideo;
    [self.houseCellBackView setBackgroundColor:[UIColor clearColor]];
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
    
//        [self updateImageTopLeft];
    
    self.mainTitleLabel.text = model.displayTitle;
    self.subTitleLabel.text = model.displaySubtitle;
    NSAttributedString * attributeString = self.cellModel.tagsAttrStr;
    self.tagLabel.attributedText =  attributeString;
    //    self.tagLabel.attributedText = self.cellModel.tagsAttrStr;
    
    
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
    [self updateBottomText:bottomText];
    
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
    CGSize titleSize = self.cellModel ? self.cellModel.titleSize : self.titleSize;
    self.mainTitleLabel.numberOfLines = showTags?1:2;
    BOOL oneRow = showTags || titleSize.height < 30;
    
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
    if (self.mainTitleLabel) {
        self.mainTitleLabel.textColor = [UIColor themeGray2];
    }
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
    [self.mainTitleLabel.yoga markDirty];
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

+ (CGSize)titleSizeWithTagList:(NSArray<FHHouseTagsModel *> *)tagList titleStr:(NSString *)titleStr {
    
    UILabel *majorTitle = [[UILabel alloc]init];
    majorTitle.font = [UIFont themeFontRegular:16];
    majorTitle.textColor = [UIColor themeGray1];
    if (tagList.count < 1) {
        
        majorTitle.numberOfLines = 2;
    }else {
        majorTitle.numberOfLines = 1;
    }
    majorTitle.text = titleStr;
    CGSize fitSize = [majorTitle sizeThatFits:CGSizeMake([UIScreen mainScreen].bounds.size.width * ([UIScreen mainScreen].bounds.size.width > 376 ? 0.61 : [UIScreen mainScreen].bounds.size.width > 321 ? 0.56 : 0.48), 0)];
    return fitSize;
}
#pragma mark 字符串处理
-(NSAttributedString *)originPriceAttr:(NSString *)originPrice {
    
    if (originPrice.length < 1) {
        return nil;
    }
    NSMutableAttributedString *attri = [[NSMutableAttributedString alloc] initWithString:originPrice];
    [attri addAttribute:NSStrikethroughStyleAttributeName value:@(NSUnderlineStyleSingle) range:NSMakeRange(0, originPrice.length)];
    [attri addAttribute:NSStrikethroughColorAttributeName value:[UIColor themeGray1] range:NSMakeRange(0, originPrice.length)];
    return attri;
}

- (void)dislike {
    if(self.delegate && [self.delegate respondsToSelector:@selector(canDislikeClick)]){
        BOOL canDislike = [self.delegate canDislikeClick];
        if(!canDislike){
            return;
        }
    }
    
    [self trackClickHouseDislke];
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
        viewModel.extrasDict = self.homeItemModel.tracerDict;
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

#pragma mark - dislike埋点

- (void)trackClickHouseDislke {
    if(self.homeItemModel.tracerDict){
        NSMutableDictionary *tracerDict = [self.homeItemModel.tracerDict mutableCopy];
        tracerDict[@"click_position"] = @"house_dislike";
        [tracerDict removeObjectsForKeys:@[@"enter_from",@"element_from"]];
        TRACK_EVENT(@"click_house_dislike", tracerDict);
    }
}

@end
