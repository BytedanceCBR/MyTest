//
//  FHHouseBaseNewHouseCell.m
//  AKCommentPlugin
//
//  Created by 谢飞 on 2019/11/11.
//

#import "FHHouseBaseNewHouseCell.h"

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
#import <lottie-ios/Lottie/LOTAnimationView.h>
#import "UIColor+Theme.h"
#import "FHSearchHouseModel.h"
#import "Masonry.h"

#define MAIN_NORMAL_TOP     10
#define MAIN_FIRST_TOP      20
#define MAIN_IMG_WIDTH      106
#define MAIN_IMG_HEIGHT     80
#define MAIN_IMG_BACK_WIDTH  117
#define MAIN_IMG_BACK_HEIGHT  89
#define MAIN_TAG_BG_WIDTH   48
#define MAIN_TAG_BG_HEIGHT  16
#define MAIN_TAG_WIDTH      46
#define MAIN_TAG_HEIGHT     10
#define INFO_TO_ICON_MARGIN 12
#define PRICE_BG_TOP_MARGIN 5
#define CELL_HEIGHT 140.5
#define CELL_RIGHTVIEW_HEIGHT 107
#define CELL_PRICE_HEIGHT 22
#define MAIN_IIMAGE_TOP      11.5

#define YOGA_RIGHT_PRICE_WIDITH 172


@interface FHHouseBaseNewHouseCell ()

@property(nonatomic, strong) FHSingleImageInfoCellModel *cellModel;
//首页的小图model
@property(nonatomic, strong) FHHomeHouseDataItemsModel *homeItemModel;

@property(nonatomic, strong) UIView *leftInfoView;


@property(nonatomic, strong) UIImageView *houseVideoImageView;
@property(nonatomic, strong) UIView *houseMainImageBackView;


@property(nonatomic, strong) UILabel *imageTagLabel;
@property(nonatomic, strong) FHCornerView *imageTagLabelBgView;

@property(nonatomic, strong) UIView *rightInfoView;
@property(nonatomic, strong) UILabel *mainTitleLabel; //主title lable
@property(nonatomic, strong) UILabel *subTitleLabel; // sub title lable
@property(nonatomic, strong) UILabel *statInfoLabel; //新房状态信息
@property(nonatomic, strong) YYLabel *tagLabel; // 标签 label
@property(nonatomic, strong) UILabel *priceLabel; //总价
@property(nonatomic, strong) UILabel *originPriceLabel;
//@property(nonatomic, strong) UILabel *pricePerSqmLabel; // 价格/平米
@property(nonatomic, strong) UILabel *distanceLabel; // 30 分钟到达
@property(nonatomic, strong) UIView *priceBgView; //底部 包含 价格 分享
@property(nonatomic, strong) UIView *bottomRecommendView;//底部推荐理由
@property(nonatomic, strong) UIView *bottomRecommendViewBack;//底部背景
@property(nonatomic, strong) UIImageView *bottomIconImageView; //活动icon
@property(nonatomic, strong) UILabel *bottomRecommendLabel; //活动title
@property(nonatomic, strong) UIView *houseCellBackView;//背景色

//@property(nonatomic, strong) UIButton *closeBtn; //x按钮
@property(nonatomic, strong) YYLabel *trueHouseLabel; // 天眼验真
@property (nonatomic, strong) LOTAnimationView *vrLoadingView;
@property(nonatomic, strong) FHCornerItemLabel *tagTitleLabel; //降 新 榜等标签
@property(nonatomic, strong) FHHouseRecommendReasonView *recReasonView; //榜单
@property(nonatomic, strong) UIView *opView; //蒙层
@property(nonatomic, strong) UILabel *offShelfLabel; //下架

@end

@implementation FHHouseBaseNewHouseCell

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

+ (CGFloat)heightForData:(id)data
{
    if ([data isKindOfClass:[JSONModel class]]) {
        FHSearchHouseItemModel *itemModel = (FHSearchHouseItemModel *)data;
        if (itemModel.advantageDescription.text) {
            return 130;
        }
    }
    return 118;
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
        _imageTagLabel.text = @"";
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

-(UIImageView *)bottomIconImageView
{
    if (!_bottomIconImageView) {
        _bottomIconImageView= [[UIImageView alloc]init];
        _bottomIconImageView.backgroundColor = [UIColor clearColor];
    }
    return _bottomIconImageView;
}

- (UIView *)bottomRecommendView
{
    if (!_bottomRecommendView) {
        _bottomRecommendView = [[UIView alloc] init];
    }
    return _bottomRecommendView;
}


-(UILabel *)bottomRecommendLabel
{
    if (!_bottomRecommendLabel) {
        _bottomRecommendLabel = [[UILabel alloc]init];
        _bottomRecommendLabel.font = [UIFont themeFontMedium:12];
        _bottomRecommendLabel.textColor = [UIColor themeGray1];
    }
    return _bottomRecommendLabel;
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
        _priceLabel.textColor = [UIColor themeOrange1];
        
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


-(CGFloat)contentMaxWidth
{
    return  SCREEN_WIDTH - HOR_MARGIN * 2  - MAIN_IMG_WIDTH - INFO_TO_ICON_MARGIN - 7; //根据UI图 直接计算出来
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
    
    self.houseCellBackView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:self.houseCellBackView];
    self.houseCellBackView.hidden = YES;
    [self.houseCellBackView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.position = YGPositionTypeAbsolute;
        layout.left = YGPointValue(15);
        layout.right = YGPointValue(15);
        layout.width = YGPointValue(SCREEN_WIDTH - 30);
        layout.height = YGPointValue(130);
        layout.flexGrow = 1;
    }];
    [self.houseCellBackView setBackgroundColor:[UIColor whiteColor]];
    [self.houseCellBackView.yoga markDirty];
    
    self.leftInfoView = [[UIView alloc] init];
    [_leftInfoView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.width = YGPointValue(MAIN_IMG_WIDTH + 6);
        layout.height = YGPointValue(CELL_HEIGHT);
    }];
    
    [self.contentView addSubview:_leftInfoView];
    [_leftInfoView addSubview:self.houseMainImageBackView];
    [_leftInfoView addSubview:self.mainImageView];
    [_leftInfoView addSubview:self.imageTagLabelBgView];
    [_imageTagLabelBgView addSubview:self.imageTagLabel];
    
    
    [self.houseMainImageBackView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.position = YGPositionTypeAbsolute;
        layout.top = YGPointValue(MAIN_IIMAGE_TOP + 3);
        layout.left = YGPointValue(8.5);
        layout.width = YGPointValue(MAIN_IMG_WIDTH - 6);
        layout.height = YGPointValue(MAIN_IMG_HEIGHT - 6);
    }];
    
    
    [_mainImageView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.position = YGPositionTypeAbsolute;
        layout.top = YGPointValue(MAIN_IIMAGE_TOP);
        layout.left = YGPointValue(5.5);
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
        layout.marginTop = YGPointValue(MAIN_IIMAGE_TOP - 1.5);
        layout.justifyContent = YGJustifyFlexStart;
        layout.maxWidth = YGPointValue([self contentMaxWidth]);
        layout.height = YGPointValue(CELL_RIGHTVIEW_HEIGHT);
    }];
    
    UIView *titleView = [[UIView alloc] init];
    [_rightInfoView addSubview:titleView];
    _priceBgView = [[UIView alloc] init];
    [_priceBgView setBackgroundColor:[UIColor whiteColor]];
    [_rightInfoView addSubview:_priceBgView];
    [_rightInfoView addSubview:self.subTitleLabel];
    [_rightInfoView addSubview:self.statInfoLabel];
    [_rightInfoView addSubview:self.tagLabel];
    
    [_rightInfoView addSubview:self.bottomRecommendView];
    
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
    [titleView setBackgroundColor:[UIColor whiteColor]];
    
    _mainTitleLabel.font = [UIFont themeFontSemibold:16];
    [_mainTitleLabel configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.marginTop = YGPointValue(0);
        layout.height = YGPointValue(22);
        layout.maxWidth = YGPointValue([self contentMaxWidth]);
    }];
    
    [_priceBgView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.flexDirection = YGFlexDirectionRow;
        layout.width = YGPointValue(YOGA_RIGHT_PRICE_WIDITH);
        layout.height = YGPointValue(CELL_PRICE_HEIGHT);
        layout.marginTop = YGPointValue(2);
        layout.justifyContent = YGJustifyFlexStart;
        layout.alignItems = YGAlignFlexStart;
    }];
    
    [_priceBgView addSubview:self.priceLabel];
    //    [_priceBgView addSubview:self.closeBtn];
    [_priceBgView addSubview:self.trueHouseLabel];
    _priceBgView.backgroundColor = [UIColor whiteColor];
    
    
    [_priceLabel configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.height = YGPointValue(19);
        layout.maxWidth = YGPointValue(YOGA_RIGHT_PRICE_WIDITH);
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
        layout.marginTop = YGPointValue(3);
        layout.height = YGPointValue(15);
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
        layout.marginTop = YGPointValue(5);
        layout.marginLeft = YGPointValue(-2);
        layout.height = YGPointValue(14);
        layout.maxWidth = YGPointValue([self contentMaxWidth]);
    }];
    
    [self.bottomRecommendView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.flexDirection = YGFlexDirectionRow;
        layout.maxWidth = YGPointValue([UIScreen mainScreen].bounds.size.width - MAIN_IMG_WIDTH - 50);
        layout.height = YGPointValue(24);
        layout.marginTop = YGPointValue(5);
        layout.justifyContent = YGJustifyFlexStart;
        layout.alignItems = YGAlignFlexStart;
    }];
    
    
    self.bottomRecommendViewBack = [[UIView alloc] init];
    self.bottomRecommendViewBack.layer.borderWidth = 0.5;
    self.bottomRecommendViewBack.layer.cornerRadius = 2;
    [self.bottomRecommendView addSubview:self.bottomRecommendViewBack];
    [self.bottomRecommendViewBack configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.flexDirection = YGFlexDirectionRow;
        layout.maxWidth = YGPointValue([UIScreen mainScreen].bounds.size.width - MAIN_IMG_WIDTH - 50);
        layout.height = YGPointValue(18);
        layout.marginTop = YGPointValue(3);
        layout.justifyContent = YGJustifyFlexStart;
        layout.alignItems = YGAlignFlexStart;
    }];
    
    
    [self.bottomRecommendViewBack addSubview:self.bottomIconImageView];
    [self.bottomIconImageView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.marginTop = YGPointValue(4);
        layout.marginLeft = YGPointValue(2);
        layout.height = YGPointValue(12);
        layout.width = YGPointValue(12);
    }];
    
    self.bottomRecommendLabel.font = [UIFont themeFontRegular:11];
    self.bottomRecommendLabel.textColor = [UIColor themeGray1];
    [self.bottomRecommendLabel setBackgroundColor:[UIColor whiteColor]];
    [self.bottomRecommendViewBack addSubview:self.bottomRecommendLabel];
    [self.bottomRecommendLabel configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isEnabled = YES;
        layout.marginTop = YGPointValue(3);
        layout.marginLeft = YGPointValue(5);
        layout.maxWidth = YGPointValue([UIScreen mainScreen].bounds.size.width - MAIN_IMG_WIDTH - 80);
        layout.marginRight = YGPointValue(3);
        layout.height = YGPointValue(13);
    }];
    
    
    [_rightInfoView addSubview:self.recReasonView];
    [_recReasonView configureLayoutWithBlock:^(YGLayout * _Nonnull layout) {
        layout.isIncludedInLayout = NO;
        layout.marginTop = YGPointValue(6);
        layout.height = YGPointValue(16);
    }];
    _recReasonView.hidden = YES;
    
}

-(void)refreshIndexCorner:(BOOL)isFirst andLast:(BOOL)isLast
{
    self.houseCellBackView.hidden = NO;
    [self.contentView setBackgroundColor:[UIColor themeHomeColor]];
    if (isFirst) {
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.houseCellBackView.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(15, 15)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = self.houseCellBackView.bounds;
        maskLayer.path = maskPath.CGPath;
        self.houseCellBackView.layer.mask = maskLayer;
    } else if (isLast){
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.houseCellBackView.bounds byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii:CGSizeMake(15, 15)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = self.houseCellBackView.bounds;
        maskLayer.path = maskPath.CGPath;
        self.houseCellBackView.layer.mask = maskLayer;
    }else
    {
        self.houseCellBackView.layer.mask = nil;
    }
}

-(void)updateMainImageWithUrl:(NSString *)url
{
    NSURL *imgUrl = [NSURL URLWithString:url];
    if (imgUrl) {
        [self.mainImageView bd_setImageWithURL:imgUrl placeholder:[FHHouseBaseNewHouseCell placeholderImage]];
    }else{
        self.mainImageView.image = [FHHouseBaseNewHouseCell placeholderImage];
    }
}

-(void)updateHomeNewHouseCellModel:(FHHomeHouseDataItemsModel *)commonModel;
{
    if (![commonModel isKindOfClass:[FHHomeHouseDataItemsModel class]]) {
        return;
    }
    
    self.houseVideoImageView.hidden = !commonModel.houseVideo.hasVideo;
    self.mainTitleLabel.text = commonModel.displayTitle;
    self.subTitleLabel.text = commonModel.displayDescription;
    NSAttributedString * attributeString =  [FHSingleImageInfoCellModel tagsStringWithTagList:commonModel.tags];
    self.tagLabel.attributedText =  attributeString;
    self.priceLabel.text = commonModel.displayPricePerSqm;
    
    if ([commonModel.displayPricePerSqm isKindOfClass:[NSString class]] && [commonModel.displayPricePerSqm isEqualToString:@"暂无报价"]) {
        self.priceLabel.textColor = [UIColor themeGray3];
    }else
    {
        self.priceLabel.textColor = [UIColor themeOrange1];
    }
    
    FHImageModel *imageModel = commonModel.images.firstObject;
    [self updateMainImageWithUrl:imageModel.url];
    
    _priceLabel.font = [UIFont themeFontSemibold:16];
    
    if(commonModel.advantageDescription)
    {
        self.bottomRecommendView.hidden = NO;
        self.bottomRecommendViewBack.hidden = NO;
    }else
    {
        self.bottomRecommendView.hidden = YES;
        self.bottomRecommendViewBack.hidden = YES;
    }
    
    if (commonModel.advantageDescription.icon.url) {
        self.bottomIconImageView.hidden = NO;
        [self.bottomIconImageView bd_setImageWithURL:[NSURL URLWithString:commonModel.advantageDescription.icon.url]];
    }else
    {
        self.bottomIconImageView.hidden = YES;
    }
    
    if (commonModel.advantageDescription.text) {
        self.bottomRecommendLabel.hidden = NO;
        self.bottomRecommendLabel.text = commonModel.advantageDescription.text;
        if (commonModel.advantageDescription.textColor) {
            self.bottomRecommendLabel.textColor = [UIColor colorWithHexStr:commonModel.advantageDescription.textColor];
        }
        
        if (commonModel.advantageDescription.borderColor) {
            self.bottomRecommendViewBack.layer.borderColor = [UIColor colorWithHexStr:commonModel.advantageDescription.borderColor].CGColor;
        }
    }else
    {
        self.bottomRecommendLabel.hidden = YES;
    }
    
    if (commonModel.houseImageTag.text && commonModel.houseImageTag.backgroundColor && commonModel.houseImageTag.textColor) {
        self.imageTagLabel.textColor = [UIColor colorWithHexString:commonModel.houseImageTag.textColor];
        self.imageTagLabel.text = commonModel.houseImageTag.text;
        self.imageTagLabelBgView.backgroundColor = [UIColor colorWithHexString:commonModel.houseImageTag.backgroundColor];
        self.imageTagLabelBgView.hidden = NO;
    }else {
        self.imageTagLabelBgView.hidden = YES;
    }
    
    [self hideRecommendReason];
    [self updateTitlesLayout:attributeString.length > 0];
    
    [self.contentView.yoga applyLayoutPreservingOrigin:NO];
}

-(void)updateHouseListNewHouseCellModel:(FHSearchHouseItemModel *)commonModel
{
    if (![commonModel isKindOfClass:[FHSearchHouseItemModel class]]) {
        return ;
    }
    
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
    }else
    {
        self.priceLabel.textColor = [UIColor themeOrange1];
    }
    
    _priceLabel.font = [UIFont themeFontSemibold:16];
    
    if(commonModel.advantageDescription)
    {
        self.bottomRecommendView.hidden = NO;
        self.bottomRecommendViewBack.hidden = NO;
    }else
    {
        self.bottomRecommendView.hidden = YES;
        self.bottomRecommendViewBack.hidden = YES;
    }
    
    if (commonModel.advantageDescription.icon.url) {
        self.bottomIconImageView.hidden = NO;
        [self.bottomIconImageView bd_setImageWithURL:[NSURL URLWithString:commonModel.advantageDescription.icon.url]];
    }else
    {
        self.bottomIconImageView.hidden = YES;
    }
    
    if (commonModel.advantageDescription.text) {
        self.bottomRecommendLabel.hidden = NO;
        self.bottomRecommendLabel.text = commonModel.advantageDescription.text;
        if (commonModel.advantageDescription.textColor) {
            self.bottomRecommendLabel.textColor = [UIColor colorWithHexStr:commonModel.advantageDescription.textColor];
        }
        
        if (commonModel.advantageDescription.borderColor) {
            self.bottomRecommendViewBack.layer.borderColor = [UIColor colorWithHexStr:commonModel.advantageDescription.borderColor].CGColor;
        }
    }else
    {
        self.bottomRecommendLabel.hidden = YES;
    }
    
    if (commonModel.houseImageTag.text && commonModel.houseImageTag.backgroundColor && commonModel.houseImageTag.textColor) {
        self.imageTagLabel.textColor = [UIColor colorWithHexString:commonModel.houseImageTag.textColor];
        self.imageTagLabel.text = commonModel.houseImageTag.text;
        self.imageTagLabelBgView.backgroundColor = [UIColor colorWithHexString:commonModel.houseImageTag.backgroundColor];
        self.imageTagLabelBgView.hidden = NO;
    }else {
        self.imageTagLabelBgView.hidden = YES;
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
        default:
            break;
    }
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
    [self.bottomRecommendLabel.yoga markDirty];
    //    [self.pricePerSqmLabel.yoga markDirty];
    [self.priceBgView.yoga markDirty];
}

- (void)updateThirdPartHouseSourceStr:(NSString *)sourceStr
{
    self.tagLabel.text = [NSString stringWithFormat:@"%@",sourceStr];
    self.tagLabel.textColor = [UIColor themeGray3];
    self.tagLabel.font = [UIFont themeFontRegular:12];
}

- (void)updateHouseStatus {
    if (self.opView) {
        [self.opView removeFromSuperview];
        self.opView = nil;
    }
    if (self.offShelfLabel) {
        [self.offShelfLabel removeFromSuperview];
        self.offShelfLabel = nil;
    }
    self.opView = [[UIView alloc] init];
    [self.opView setBackgroundColor:[UIColor colorWithRed:170.0/255 green:170.0/255 blue:170.0/255 alpha:0.8]];
    [self.opView setFrame:CGRectMake(0, 0, self.mainImageView.frame.size.width, self.mainImageView.frame.size.height)];
    self.opView.layer.shadowOffset = CGSizeMake(4, 6);
    self.opView.layer.cornerRadius = 4;
    self.opView.clipsToBounds = YES;
    self.opView.layer.shadowColor = [[UIColor colorWithRed:0 green:0 blue:0 alpha:0.1] CGColor];
    [self.mainImageView addSubview:_opView];
    
    self.offShelfLabel = [[UILabel alloc] init];
    self.offShelfLabel.text = @"已下架";
    self.offShelfLabel.font = [UIFont themeFontSemibold:14];
    self.offShelfLabel.textColor = [UIColor whiteColor];
    [self.mainImageView addSubview:_offShelfLabel];
    [self.offShelfLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.mainImageView);
    }];
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
