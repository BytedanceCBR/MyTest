//
//  FHHouseListBaseItemCell.m
//  FHHouseBase
//
//  Created by liuyu on 2020/3/5.
//

#import "FHHouseListBaseItemCell.h"
#import <FHCommonUI/UIColor+Theme.h>
#import <FHCommonUI/UIFont+House.h>
#import <YYText/YYLabel.h>
#import "Masonry.h"
#import "FHImageModel.h"
#import <BDWebImage/UIImageView+BDWebImage.h>
#import "FHHouseListBaseItemModel.h"
#import <lottie-ios/Lottie/LOTAnimationView.h>
#import "FHDetailCommonDefine.h"
#import "FHCommonDefines.h"
#import "UIImage+FIconFont.h"
#import "UIViewAdditions.h"

@interface FHHouseListBaseItemCell()
@property (nonatomic, weak) UIImageView *mainIma;
@property (nonatomic, weak) UIImageView *mainImaShadow;
@property (nonatomic, weak) UILabel *maintitle;
@property (nonatomic, weak) UILabel *positionInformation;
@property (nonatomic, weak) UILabel *unitPrice;
@property (nonatomic, weak) UILabel *totalPrice;
@property (nonatomic, weak) YYLabel *tagInformation;
@property (nonatomic, weak) UIView *houseMainImageBackView;
@property (nonatomic, weak) UIImageView *houseVideoImageView;
@property (nonatomic, weak) LOTAnimationView *vrLoadingView;
//针对于新房混盘卡片
@property (nonatomic, weak) UIImageView *radiusView;
@property (nonatomic, weak) UIView *lineView;
@property (nonatomic, weak) UIImageView *mainImaTag;
@property (nonatomic, weak) UIView *houseCellBackView;//背景色
@property (nonatomic, weak) UILabel *displayDescriptionLabel;
@property (nonatomic, weak) YYLabel *tagLabel; // 标签 label
@property (nonatomic, assign) BOOL isHomePage;

@property(nonatomic, strong) UIImageView *topLeftTagImageView;  //企业担保图标
@property(nonatomic, strong) CAShapeLayer *topLeftTagMaskLayer;

@property (nonatomic, copy) NSString *reuseIdentifier;
@end
@implementation FHHouseListBaseItemCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.reuseIdentifier = reuseIdentifier;
        //周边新盘，我关注的新房
        if ([self.reuseIdentifier isEqualToString:@"FHNewHouseCell"] ) {
              [self initNewHouseUI];
        //首页页插入新房
        }else if([self.reuseIdentifier isEqualToString:@"FHSynchysisNewHouseCell"] || [self.reuseIdentifier isEqualToString:@"FHListSynchysisNewHouseCell"]){
            if([self.reuseIdentifier isEqualToString:@"FHSynchysisNewHouseCell"]) {
                _isHomePage = YES;
            } else {
                _isHomePage = NO;
            }
            [self initSynchysisNewHouseUI];
        }else {
              [self initUI];
          }
    }
    return self;
}

#pragma mark ----首页混排 新房UI单独处理
- (void)initSynchysisNewHouseUI {
    [self.houseCellBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(15);
        make.right.equalTo(self.contentView).offset(-15);
        make.size.mas_equalTo(CGSizeMake([UIScreen mainScreen].bounds.size.width-30,88));
        make.bottom.top.equalTo(self.contentView);
    }];
    self.totalPrice.hidden = YES;
    self.unitPrice.font = [UIFont themeFontMedium:16];
    self.unitPrice.textAlignment = NSTextAlignmentRight;
    [self.houseMainImageBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.mainIma);
        make.left.top.equalTo(self.mainIma);
        make.bottom.equalTo(self.mainIma).offset(-1);
        make.right.equalTo(self.mainIma).offset(-1);
    }];
    [self.mainIma mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.contentView).offset([self.reuseIdentifier isEqualToString:@"FHSynchysisNewHouseCell"]?27:15);
        make.size.mas_equalTo(CGSizeMake(85, 64));
    }];
    [self.mainImaTag mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(self.mainIma);
        make.size.mas_equalTo(CGSizeMake(32, 18));
    }];
    [self.maintitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mainIma.mas_right).offset(12);
        make.top.equalTo(self.mainIma);
        make.height.mas_equalTo(18);
        make.right.equalTo(self.contentView).offset(-30);
    }];
    CGFloat rightMargin = 3 + (_isHomePage ? 20 : 12);
    [self.displayDescriptionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_maintitle);
        make.top.mas_equalTo(_maintitle.mas_bottom).offset(8);
        make.right.mas_equalTo(-rightMargin);
        make.height.mas_equalTo(14);
    }];
    [self.unitPrice mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(-12);
        make.right.mas_equalTo(-rightMargin);
        make.height.mas_equalTo(19);
    }];
    [self.unitPrice setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.unitPrice setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.tagLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_maintitle);
        make.top.mas_equalTo(_displayDescriptionLabel.mas_bottom).offset(10);
        make.right.mas_equalTo(_unitPrice.mas_left).offset(-16);
        make.height.mas_equalTo(14);
    }];
    self.positionInformation.textColor = [UIColor themeGray3];
}


#pragma mark ----新房UI单独处理
- (void)initNewHouseUI
{
    self.totalPrice.hidden = YES;
    self.unitPrice.font = [UIFont themeFontMedium:16];
    self.unitPrice.textColor = [UIColor themeOrange1];
    [self.houseMainImageBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.mainIma);
        make.left.top.equalTo(self.mainIma);
        make.size.mas_equalTo(CGSizeMake(107, 81));
    }];
    [self.mainIma mas_makeConstraints:^(MASConstraintMaker *make) {
         make.centerY.equalTo(self.contentView);
         make.left.equalTo(self.contentView).offset(15);
         make.size.mas_equalTo(CGSizeMake(106, 80));
     }];
    [self.maintitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mainIma.mas_right).offset(12);
        make.top.equalTo(self.mainIma);
        make.right.equalTo(self.contentView).offset(-15);
        make.height.mas_equalTo(20);
    }];
    [self.unitPrice mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.maintitle);
        make.right.equalTo(self.contentView).offset(-15);
        make.top.equalTo(self.maintitle.mas_bottom);
    }];
    [self.positionInformation mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.maintitle);
        make.top.equalTo(self.unitPrice.mas_bottom);
        make.right.equalTo(self.contentView).offset(-15);
    }];
    [self.tagInformation mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.maintitle);
        make.top.equalTo(self.positionInformation.mas_bottom).offset(5);
        make.right.equalTo(self.contentView).offset(-15);
    }];
}

#pragma mark ----二手房，小区，租房
- (void)initUI {
    [self.houseMainImageBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.mainIma);
        make.left.top.equalTo(self.mainIma);
        make.bottom.equalTo(self.mainIma).offset(-1);
        make.right.equalTo(self.mainIma).offset(-1);
    }];
    [self.mainIma mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(10);
        make.left.equalTo(self.contentView).offset(15);
        make.size.mas_equalTo(CGSizeMake(85, 64));
    }];
    [self.houseVideoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mainIma).offset(12);
        make.bottom.equalTo(self.mainIma).offset(-10);
        make.size.mas_equalTo(CGSizeMake(16, 16));
    }];
    [self.vrLoadingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mainIma).offset(12);
        make.bottom.equalTo(self.mainIma).offset(-10);
        make.size.mas_equalTo(CGSizeMake(16, 16));
    }];
    [self.maintitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mainIma.mas_right).offset(12);
        make.top.equalTo(self.mainIma).offset(-2);
        make.right.equalTo(self.contentView).offset(-15);
    }];
    [self.positionInformation mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.maintitle);
        make.top.equalTo(self.maintitle.mas_bottom).offset(2);
        //         make.right.lessThanOrEqualTo(self.unitPrice.mas_left).offset(-10);
    }];
    
    [self.unitPrice mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_greaterThanOrEqualTo(self.positionInformation.mas_right).offset(10);
        make.top.equalTo(self.positionInformation);
        make.right.equalTo(self.contentView).offset(-15);
    }];
    //    [self.unitPrice setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    //    [self.positionInformation setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    [self.unitPrice setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.unitPrice setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.tagInformation mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.maintitle);
        make.top.equalTo(self.positionInformation.mas_bottom).offset(7);
    }];
    [self.totalPrice mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.unitPrice.mas_right);
        make.top.equalTo(self.unitPrice.mas_bottom).offset(4);
    }];
    [self.topLeftTagImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(self.mainIma);
        make.size.mas_equalTo(CGSizeMake(48, 18));
    }];
}
#pragma mark ---------------------- UIInit:初始化控件

+ (UIImage *)placeholderImage {
    static UIImage *placeholderImage = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        placeholderImage = [UIImage imageNamed: @"default_image"];
    });
    return placeholderImage;
}

- (UILabel *)displayDescriptionLabel
{
    if (!_displayDescriptionLabel) {
        UILabel *displayDescriptionLabel = [[UILabel alloc] init];
        displayDescriptionLabel.font = [UIFont themeFontRegular:12];
        displayDescriptionLabel.textColor = [UIColor themeGray1];
        [self.contentView addSubview:displayDescriptionLabel];
        _displayDescriptionLabel = displayDescriptionLabel;
    }
    return _displayDescriptionLabel;
}

- (UILabel *)maintitle
{
    if (!_maintitle) {
        UILabel *maintitle = [[UILabel alloc]init];
        maintitle.font = [UIFont themeFontSemibold:18];
        maintitle.textColor = [UIColor themeGray1];
        [self.contentView addSubview:maintitle];
        _maintitle = maintitle;
    }
    return _maintitle;
}

- (UILabel *)positionInformation
{
    if (!_positionInformation) {
        UILabel *positionInformation = [[UILabel alloc]init];
        positionInformation.font = [UIFont themeFontRegular:12];
        positionInformation.textColor = [UIColor themeGray1];
        [self.contentView addSubview:positionInformation];
        _positionInformation = positionInformation;
    }
    return _positionInformation;
}

- (UILabel *)unitPrice
{
    if (!_unitPrice) {
        UILabel *unitPrice = [[UILabel alloc]init];
        unitPrice.font = [UIFont themeFontRegular:12];
        unitPrice.textColor = [UIColor themeGray1];
        [self.contentView addSubview:unitPrice];
        _unitPrice = unitPrice;
    }
    return _unitPrice;
}

- (UILabel *)totalPrice
{
    if (!_totalPrice) {
        UILabel *totalPrice = [[UILabel alloc]init];
        totalPrice.font = [UIFont themeFontMedium:16];
        totalPrice.textColor = [UIColor themeOrange1];
        //        totalPrice.backgroundColor = [UIColor redColor];
        [self.contentView addSubview:totalPrice];
        _totalPrice = totalPrice;
    }
    return _totalPrice;
}

- (YYLabel *)tagInformation
{
    if (!_tagInformation) {
        YYLabel *tagInformation = [[YYLabel alloc]init];
        tagInformation.font = [UIFont themeFontRegular:12];
        tagInformation.textColor = [UIColor themeOrange1];
        [self.contentView addSubview:tagInformation];
        _tagInformation = tagInformation;
    }
    return _tagInformation;
}

- (UIImageView *)mainImaTag {
    if (!_mainImaTag) {
        UIImageView *mainImaTag = [[UIImageView alloc]init];
        [self.contentView addSubview:mainImaTag];
        _mainImaTag = mainImaTag;
    }
    return _mainImaTag;
}

- (UIImageView *)mainIma {
    if (!_mainIma) {
        UIImageView *mainIma = [[UIImageView alloc]init];
        mainIma.layer.cornerRadius = 4;
        mainIma.layer.masksToBounds = YES;
        [self.contentView addSubview:mainIma];
        _mainIma = mainIma;
    }
    return _mainIma;
}

- (UIView *)houseMainImageBackView
{
    if (!_houseMainImageBackView) {
        UIView *houseMainImageBackView = [[UIView alloc] init];
        houseMainImageBackView.backgroundColor = [UIColor whiteColor];
        CALayer * layer = houseMainImageBackView.layer;
        layer.shadowOffset = CGSizeMake(0, 4);
        layer.shadowRadius = 6;
        layer.shadowColor = [UIColor blackColor].CGColor;;
        layer.shadowOpacity = 0.2;
        [self.contentView addSubview:houseMainImageBackView];
        _houseMainImageBackView = houseMainImageBackView;
    }
    return _houseMainImageBackView;
}

- (UIView *)houseCellBackView
{
    if (!_houseCellBackView) {
        UIView *houseCellBackView = [[UIView alloc] init];
        houseCellBackView.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:houseCellBackView];
         houseCellBackView.hidden = YES;
        _houseCellBackView = houseCellBackView;
    }
    return _houseCellBackView;
}

- (UIImageView *)mainImaShadow {
    if (!_mainImaShadow) {
        UIImageView *mainImaShadow = [[UIImageView alloc]init];
        [self.contentView addSubview:mainImaShadow];
        _mainImaShadow = mainImaShadow;
    }
    return _mainImaShadow;
}

- (UIImageView *)houseVideoImageView
{
    if (!_houseVideoImageView) {
        UIImageView *houseVideoImageView = [[UIImageView alloc]init];
        houseVideoImageView.image = [UIImage imageNamed:@"icon_list_house_video"];
        houseVideoImageView.backgroundColor = [UIColor clearColor];
        houseVideoImageView.hidden = YES;
        [self.contentView addSubview:houseVideoImageView];
        _houseVideoImageView = houseVideoImageView;
    }
    return _houseVideoImageView;
}

- (LOTAnimationView *)vrLoadingView
{
    if (!_vrLoadingView) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"VRImageLoading" ofType:@"json"];
        LOTAnimationView *vrLoadingView = [LOTAnimationView animationWithFilePath:path];
        vrLoadingView.loopAnimation = YES;
        [self.contentView addSubview:vrLoadingView];
        _vrLoadingView = vrLoadingView;
    }
    return _vrLoadingView;
}

-(YYLabel *)tagLabel
{
    if (!_tagLabel) {
        YYLabel *tagLabel = [[YYLabel alloc]init];
        tagLabel.font = [UIFont themeFontRegular:12];
        tagLabel.textColor = [UIColor themeGray3];
        tagLabel.lineBreakMode = NSLineBreakByTruncatingTail;  //截断时展示...与安卓端对齐
        [self.contentView addSubview:tagLabel];
        _tagLabel = tagLabel;
    }
    return _tagLabel;
}

- (UIImageView *)topLeftTagImageView {
    if (!_topLeftTagImageView) {
        _topLeftTagImageView = [[UIImageView alloc] init];
        [self.contentView addSubview:_topLeftTagImageView];
    }
    
    return _topLeftTagImageView;
}

#pragma mark ---------------------- dataPross:数据加载
- (void)refreshWithData:(id)data {
    self.currentData = data;
    //    if ([data isKindOfClass:[FHSingleImageInfoCellModel class]] ) {
    //        [self updateWithHouseCellModel:data];
    if([data isKindOfClass:[FHHouseListBaseItemModel class]]){
        FHHouseListBaseItemModel *model = (FHHouseListBaseItemModel *)data;
        FHImageModel *imageModel = model.houseImage.firstObject;
        [self.mainIma bd_setImageWithURL:[NSURL URLWithString:imageModel.url] placeholder:[FHHouseListBaseItemCell placeholderImage]];
        self.maintitle.text = model.title;
        self.positionInformation.text = model.displaySubtitle;
        if (model.originPrice) {
            self.unitPrice.attributedText = [self originPriceAttr:model.originPrice];
        }else{
            self.unitPrice.attributedText = [[NSMutableAttributedString alloc]initWithString:model.displayPricePerSqm attributes:@{}];
        }
        
        self.totalPrice.text = model.displayPrice;
        self.houseVideoImageView.hidden = !model.houseVideo.hasVideo;
        if (model.reasonTags.count>0) {
            self.tagInformation.attributedText = model.recommendReasonStr;
        }else {
            self.tagInformation.attributedText = model.tagString;
        }
        [self updateContentWithModel:model];
        if (model.vrInfo.hasVr) {
            self.houseVideoImageView.hidden = YES;
            self.vrLoadingView.hidden = NO;
            [self.vrLoadingView play];
        }else {
            self.vrLoadingView.hidden = YES;
            [self.vrLoadingView stop];
        }
        
        /**
         周边新盘，我关注的新房 这两种场景也使用了tag_image字段（用于下发左上角“新房”标签），
         这里绕过这两种场景，即在这两个页面不走“企业担保”逻辑
         */
        if (![self.reuseIdentifier isEqualToString:@"FHNewHouseCell"]) {
            [self configTopLeftTagWithTagImages:model.tagImage];
        }
    };
}

- (void)updateContentWithModel:(FHHouseListBaseItemModel *)model {
    switch (model.houseType ) {
        case FHHouseTypeRentHouse:
            self.tagInformation.text = model.addrData;
            self.tagInformation.font = [UIFont themeFontRegular:12];
            [self.tagInformation setTextColor:[UIColor themeGray2]];
            break;
        case FHHouseTypeNeighborhood:
            self.tagInformation.text = model.salesInfo;
            self.tagInformation.font = [UIFont themeFontRegular:12];
            [self.tagInformation setTextColor:[UIColor themeGray2]];
        case FHHouseTypeNewHouse:

        default:
            break;
    }
    
}

#pragma mark 字符串处理
- (NSAttributedString *)originPriceAttr:(NSString *)originPrice {
    
    if (originPrice.length < 1) {
        return nil;
    }
    NSMutableAttributedString *attri = [[NSMutableAttributedString alloc] initWithString:originPrice];
    [attri addAttribute:NSStrikethroughStyleAttributeName value:@(NSUnderlineStyleSingle) range:NSMakeRange(0, originPrice.length)];
    [attri addAttribute:NSStrikethroughColorAttributeName value:[UIColor themeGray1] range:NSMakeRange(0, originPrice.length)];
    return attri;
}
#pragma mark 更新首页混排新房cell
- (void)updateSynchysisNewHouseCellWithModel:(FHHomeHouseDataItemsModel *)model {
    if ([model isKindOfClass:[FHHomeHouseDataItemsModel class]]) {
        self.maintitle.text = model.displayTitle;
        self.unitPrice.text = model.displayPricePerSqm;
        FHImageModel *imageModel = model.images.firstObject;
        [self.mainIma bd_setImageWithURL:[NSURL URLWithString:imageModel.url] placeholder:[FHHouseListBaseItemCell placeholderImage]];
        FHImageModel *tagimageModel = model.tagImage.firstObject;
        [self.mainImaTag bd_setImageWithURL:[NSURL URLWithString:tagimageModel.url]];
        //只展示display_description，跟安卓端保持一致
        self.displayDescriptionLabel.text = model.displayDescription ?: @"";
        if (model.displayPriceColor) {
            self.unitPrice.textColor = [UIColor colorWithHexStr:model.displayPriceColor];
        }else {
           self.unitPrice.textColor = [UIColor themeOrange1];
        }
        CGFloat maxWidth = SCREEN_WIDTH - 257.f;
        NSAttributedString *attributeString = [FHSingleImageInfoCellModel newTagsStringWithTagList:model.tags maxWidth:maxWidth];
//             _tagLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.tagLabel.attributedText = attributeString;
    }
}
#pragma mark 更新大类页混排新房cell
- (void)updateSynchysisNewHouseCellWithSearchHouseModel:(FHSearchHouseItemModel *)model {
    if ([model isKindOfClass:[FHSearchHouseItemModel class]]) {
        self.maintitle.text = model.displayTitle;
        self.unitPrice.text = model.displayPricePerSqm;
        FHImageModel *imageModel = model.images.firstObject;
        [self.mainIma bd_setImageWithURL:[NSURL URLWithString:imageModel.url] placeholder:[FHHouseListBaseItemCell placeholderImage]];
        FHImageModel *tagimageModel = model.tagImage.firstObject;
        [self.mainImaTag bd_setImageWithURL:[NSURL URLWithString:tagimageModel.url]];
        //只展示display_description，跟安卓端保持一致
        self.displayDescriptionLabel.text = model.displayDescription ?: @"";
        if (model.displayPriceColor) {
            self.unitPrice.textColor = [UIColor colorWithHexStr:model.displayPriceColor];
        }else {
           self.unitPrice.textColor = [UIColor themeOrange1];
        }

        CGFloat maxWidth = SCREEN_WIDTH - 237.f;
        NSAttributedString *attributeString = [FHSingleImageInfoCellModel newTagsStringWithTagList:model.tags maxWidth:maxWidth];
//             _tagLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.tagLabel.attributedText = attributeString;
    }
}

-(void)refreshIndexCorner:(BOOL)isFirst andLast:(BOOL)isLast
{
    self.contentView.backgroundColor = [UIColor themeHomeColor];
    self.houseCellBackView.hidden = NO;
    if (isFirst) {
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width-30, 88) byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(15, 15)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width-30, 88);
        maskLayer.path = maskPath.CGPath;
        self.houseCellBackView.layer.mask = maskLayer;
    } else if (isLast){
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0,  [UIScreen mainScreen].bounds.size.width-30, 88) byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii:CGSizeMake(15, 15)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width-30, 88);
        maskLayer.path = maskPath.CGPath;
        self.houseCellBackView.layer.mask = maskLayer;
    }else
    {
        self.houseCellBackView.layer.mask = nil;
    }
}

- (void)configTopLeftTagWithTagImages:(NSArray<FHImageModel> *)tagImages {
    if (tagImages.count > 0) {
        FHImageModel *tagImageModel = tagImages.firstObject;
        if (!tagImageModel.url.length) {
            return;
        }
        
        NSURL *imageUrl = [NSURL URLWithString:tagImageModel.url];
        [self.topLeftTagImageView bd_setImageWithURL:imageUrl];
        CGFloat width = [tagImageModel.width floatValue];
        CGFloat height = [tagImageModel.height floatValue];
        [self.topLeftTagImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(width > 0.0 ? width : 48);
        }];
        [self.topLeftTagImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(height > 0.0 ? height : 18);
        }];
        
        self.topLeftTagImageView.hidden = NO;
        [self layoutIfNeeded];
    }else {
        self.topLeftTagImageView.hidden = YES;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    //图片圆角
    if (!CGRectEqualToRect(self.topLeftTagImageView.frame, CGRectZero)) {
        if (!_topLeftTagMaskLayer || !CGSizeEqualToSize(_topLeftTagMaskLayer.frame.size, self.topLeftTagImageView.frame.size)) {
            UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.topLeftTagImageView.bounds
                                                           byRoundingCorners:UIRectCornerTopLeft | UIRectCornerBottomRight
                                                                 cornerRadii:CGSizeMake(4, 4)];
            _topLeftTagMaskLayer = [[CAShapeLayer alloc] init];
            _topLeftTagMaskLayer.frame = self.topLeftTagImageView.bounds;
            _topLeftTagMaskLayer.path = maskPath.CGPath;
            self.topLeftTagImageView.layer.mask = _topLeftTagMaskLayer;
        }
    }
}

@end
