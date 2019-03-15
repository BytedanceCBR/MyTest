//
//  TTPersonalHomeHeaderInfoView.m
//  Article
//
//  Created by 王迪 on 2017/3/13.
//
//

#import "TTPersonalHomeHeaderInfoView.h"
#import "NSStringAdditions.h"
#import <TTVerifyKit/TTVerifyIconHelper.h>
#import "TTTrackerWrapper.h"
#import "TTRoute.h"
#import "SSCommonLogic.h"
#import <TTKitchen/TTKitchenHeader.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <BDWebImage/SDWebImageAdapter.h>
#import "TTPersonalHomeMultiplePlatformFollowersInfoView.h"
#import "TTPersonalHomeMultiplePlatformFollowersInfoViewModel.h"
#import "FRImageInfoModel.h"

typedef enum {
    TTPersonalHomeHeaderInfoNumberViewTypeFollow,
    TTPersonalHomeHeaderInfoNumberViewTypeLike
}TTPersonalHomeHeaderInfoNumberViewType;

@interface TTPersonalHomeHeaderInfoNumberView : SSThemedView

@property (nonatomic, weak) SSThemedLabel *numberLabel;
@property (nonatomic, weak) SSThemedLabel *unitlabel;
@property (nonatomic, weak) SSThemedLabel *descLabel;
@property (nonatomic, strong) NSNumber *number;

- (instancetype)initWithType:(TTPersonalHomeHeaderInfoNumberViewType)type;

@property (nonatomic, copy) NSString *descText;

@end

@implementation TTPersonalHomeHeaderInfoNumberView

- (instancetype)initWithType:(TTPersonalHomeHeaderInfoNumberViewType)type
{
    if(self = [super init]) {
        self.descText = type == TTPersonalHomeHeaderInfoNumberViewTypeLike ? NSLocalizedString(@"粉丝", nil) : NSLocalizedString(@"关注", nil);
        [self stupSubview];
        
    }
    return self;
}

- (void)stupSubview
{
    SSThemedLabel *numberLabel = [[SSThemedLabel alloc] init];
    numberLabel.textColorThemeKey = @"222222";
    numberLabel.font = [UIFont boldSystemFontOfSize:[TTDeviceUIUtils tt_newPadding:17]];
    [self addSubview:numberLabel];
    self.numberLabel = numberLabel;
    
    SSThemedLabel *unitLabel = [[SSThemedLabel alloc] init];
    unitLabel.textColorThemeKey = @"222222";
    unitLabel.font = [UIFont boldSystemFontOfSize:[TTDeviceUIUtils tt_newPadding:14]];
    [self addSubview:unitLabel];
    self.unitlabel = unitLabel;
    
    SSThemedLabel *descLabel = [[SSThemedLabel alloc] init];
    descLabel.textColorThemeKey = kColorText3;
    descLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:13]];
    [self addSubview:descLabel];
    self.descLabel = descLabel;
}

- (void)setNumber:(NSNumber *)number
{
    if(number.integerValue <= 0) {
        number = @(0);
    }
    _number = number;
    self.hidden = NO;
    CGFloat tmpNumber = number.floatValue / 10000;
    NSString *text = nil;
    BOOL hasUnit = NO;
    if(tmpNumber < 1) {
        text = [NSString stringWithFormat:@"%@",number];
        hasUnit = NO;
    } else {
        NSString *tmpStr = [NSString stringWithFormat:@"%f",tmpNumber];
        NSRange dotRange = [tmpStr rangeOfString:@"."];
        if(dotRange.location != NSNotFound) {
            NSString *left = [tmpStr substringToIndex:dotRange.location];
            NSString *right = [tmpStr substringWithRange:NSMakeRange(dotRange.location + 1, 1)];
            if([right isEqualToString:@"0"]) {
                text = [NSString stringWithFormat:@"%@",left];
            } else {
                text = [NSString stringWithFormat:@"%@.%@",left,right];
            }
        }
        hasUnit = YES;
    }
    
    self.numberLabel.text = text;
    self.unitlabel.text = @"万";
    self.descLabel.text = self.descText;
    CGSize numberLabelSize = [self.numberLabel.text sizeWithFontCompatible:self.numberLabel.font];
    self.numberLabel.frame = CGRectMake(0, 0,numberLabelSize.width, [TTDeviceUIUtils tt_newPadding:20]);
    if(hasUnit) {
        self.unitlabel.hidden = NO;
        self.unitlabel.left = self.numberLabel.right;
        self.unitlabel.height = [TTDeviceUIUtils tt_newPadding:20];
        self.unitlabel.width = [TTDeviceUIUtils tt_newPadding:15];
        self.unitlabel.top = self.numberLabel.top;
    } else {
        self.unitlabel.hidden = YES;
        self.unitlabel.frame = CGRectZero;
    }
    CGSize descLabelSize = [self.descLabel.text sizeWithFontCompatible:self.descLabel.font];
    self.descLabel.size = descLabelSize;
    self.descLabel.bottom = self.numberLabel.bottom - 1;
    if(hasUnit) {
        self.descLabel.left = self.unitlabel.right + [TTDeviceUIUtils tt_newPadding:3];
    } else {
        self.descLabel.left = self.numberLabel.right + [TTDeviceUIUtils tt_newPadding:3];
    }
    self.size = CGSizeMake(self.numberLabel.width + self.unitlabel.width + self.descLabel.width + [TTDeviceUIUtils tt_newPadding:3],  numberLabelSize.height);
}

@end

typedef NS_ENUM(NSInteger, TTPersonalHomeHeaderInfoItemType) {
    TTPersonalHomeHeaderInfoItemTypeAuthInfo = 0,
    TTPersonalHomeHeaderInfoItemTypeLocation = 1,
    TTPersonalHomeHeaderInfoItemTypeRecommendReason = 2,
};

@interface TTPersonalHomeHeaderInfoItemView : SSThemedView
@property (nonatomic, strong) SSThemedImageView *iconView;
@property (nonatomic, strong) SSThemedLabel *textLabel;
@end

@implementation TTPersonalHomeHeaderInfoItemView

- (instancetype)init {
    if (self = [super init]) {
        [self addSubview:self.iconView];
        [self addSubview:self.textLabel];
    }
    return self;
}

- (void)refreshWithItemType:(TTPersonalHomeHeaderInfoItemType)type text:(NSString *)infoText {
    switch (type) {
        case TTPersonalHomeHeaderInfoItemTypeAuthInfo:
            self.iconView.imageName = @"personal_homepage_info_auth";
            self.textLabel.numberOfLines = 2;
            break;
        case TTPersonalHomeHeaderInfoItemTypeLocation:
            self.iconView.imageName = @"place";
            self.textLabel.numberOfLines = 1;
            break;
        case TTPersonalHomeHeaderInfoItemTypeRecommendReason:
            self.iconView.imageName = @"personal_homepage_info_rec_reason";
            self.textLabel.numberOfLines = 1;
            break;
        default:
            break;
    }
    
    self.iconView.left = 0;
    self.iconView.top = ([TTDeviceUIUtils tt_fontSize:18] - [TTDeviceUIUtils tt_fontSize:14]) / 2;
    
    self.textLabel.width = self.width - [TTDeviceUIUtils tt_fontSize:14] - [TTDeviceUIUtils tt_fontSize:4];
    self.textLabel.height = self.height;
    self.textLabel.left = self.iconView.right + [TTDeviceUIUtils tt_fontSize:4];
    self.textLabel.top = 0;
    
    self.textLabel.text = infoText;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    self.iconView.left = 0;
    self.iconView.top = ([TTDeviceUIUtils tt_fontSize:18] - [TTDeviceUIUtils tt_fontSize:14]) / 2;
    
    self.textLabel.width = self.width - [TTDeviceUIUtils tt_fontSize:14] - [TTDeviceUIUtils tt_fontSize:4];
    self.textLabel.height = self.height;
    self.textLabel.left = self.iconView.right + [TTDeviceUIUtils tt_fontSize:4];
    self.textLabel.top = 0;
}

- (SSThemedImageView *)iconView {
    if (!_iconView) {
        _iconView = [[SSThemedImageView alloc] initWithFrame:CGRectMake(0, 0, [TTDeviceUIUtils tt_newPadding:14], [TTDeviceUIUtils tt_newPadding:14])];
    }
    return _iconView;
}

- (SSThemedLabel *)textLabel {
    if (!_textLabel) {
        _textLabel = [[SSThemedLabel alloc] init];
        _textLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:13]];
        _textLabel.textColorThemeKey = kColorText1;
    }
    return _textLabel;
}

@end

@interface TTPersonalHomeHeaderInfoView ()

@property (nonatomic, weak) SSThemedLabel *nameLabel;
@property (nonatomic, weak) SSThemedLabel *realNameLabel;
@property (nonatomic, weak) SSThemedImageView *sexImageView;
@property (nonatomic, weak) SSThemedImageView *toutiaoIcon;
@property (nonatomic, weak) TTPersonalHomeHeaderInfoItemView *recommendReasonView;//推荐理由
@property (nonatomic, weak) TTPersonalHomeHeaderInfoItemView *locationView;//地址
@property (nonatomic, weak) TTPersonalHomeHeaderInfoItemView *authView;//认证信息
@property (nonatomic, weak) SSThemedLabel *introduceLabel;
@property (nonatomic, weak) TTPersonalHomeHeaderInfoNumberView *followNumberView;
@property (nonatomic, weak) TTPersonalHomeHeaderInfoNumberView *likeNumbrView;
@property (nonatomic, weak) SSThemedView *bottomLine;
@property (nonatomic, strong) TTPersonalHomeMultiplePlatformFollowersInfoViewModel *multiplePlatformFollowersInfoViewModel;
@property (nonatomic, strong) TTPersonalHomeMultiplePlatformFollowersInfoView *multiplePlatformFollowersInfoView;
@property (nonatomic, strong) SSThemedImageView *multiplePlatformFollowersTriangleView;
@property (nonatomic, strong) UIButton *multiplePlatformFollowersTriangleButton;

@property (nonatomic, strong) NSMutableArray<SSThemedImageView*> *medalImageViews;
@end

@implementation TTPersonalHomeHeaderInfoView

- (instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame]) {
        self.backgroundColorThemeKey = kColorBackground4;
        _headerViewTopMargin = 2;
        [self setupSubview];
    }
    return self;
}

- (void)setupSubview
{
    SSThemedLabel *nameLabel = [[SSThemedLabel alloc] init];
    nameLabel.numberOfLines = 1;
    nameLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:[TTDeviceUIUtils tt_fontSize:18]] ? : [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:18]];
    nameLabel.textColorThemeKey = kColorText1;
    [self addSubview:nameLabel];
    self.nameLabel = nameLabel;
    
    SSThemedLabel *realNameLabel = [[SSThemedLabel alloc] init];
    realNameLabel.numberOfLines = 1;
    realNameLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:14]];
    realNameLabel.textColorThemeKey = kColorText1;
    [self addSubview:realNameLabel];
    self.realNameLabel = realNameLabel;
    
    SSThemedImageView *sexImageView = [[SSThemedImageView alloc] init];
    [self addSubview:sexImageView];
    self.sexImageView = sexImageView;
    
    SSThemedImageView *toutiaoIcon = [[SSThemedImageView alloc] init];
    toutiaoIcon.imageName = @"toutiaohao";
    toutiaoIcon.hidden = YES;
    [self addSubview:toutiaoIcon];
    self.toutiaoIcon = toutiaoIcon;
    
    TTPersonalHomeHeaderInfoItemView *recommendReasonView = [[TTPersonalHomeHeaderInfoItemView alloc] init];
    recommendReasonView.hidden = YES;
    [self addSubview:recommendReasonView];
    self.recommendReasonView = recommendReasonView;
    
    TTPersonalHomeHeaderInfoItemView *locationView = [[TTPersonalHomeHeaderInfoItemView alloc] init];
    locationView.hidden = YES;
    [self addSubview:locationView];
    self.locationView = locationView;
    
    TTPersonalHomeHeaderInfoItemView *authView = [[TTPersonalHomeHeaderInfoItemView alloc] init];
    authView.hidden = YES;
    [self addSubview:authView];
    self.authView = authView;
    
    SSThemedLabel *introduceLabel = [[SSThemedLabel alloc] init];
    introduceLabel.hidden = YES;
    introduceLabel.preferredMaxLayoutWidth = self.width - [TTDeviceUIUtils tt_newPadding:15];
    introduceLabel.textColorThemeKey = kColorText1;
    //    introduceLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    introduceLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:13]];
    [self addSubview:introduceLabel];
    self.introduceLabel = introduceLabel;
    
    SSThemedButton *spreadOutBtn = [SSThemedButton buttonWithType:UIButtonTypeCustom];
    spreadOutBtn.hidden = YES;
    [spreadOutBtn setTitle:@"展开" forState:UIControlStateNormal];
    spreadOutBtn.titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:13]];
    spreadOutBtn.titleColorThemeKey = kColorText5;
    [self addSubview:spreadOutBtn];
    self.spreadOutBtn = spreadOutBtn;
    
    TTPersonalHomeHeaderInfoNumberView *followNumberView = [[TTPersonalHomeHeaderInfoNumberView alloc] initWithType:TTPersonalHomeHeaderInfoNumberViewTypeFollow];
    followNumberView.hidden = YES;
    UITapGestureRecognizer *followNumberViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(followNumberViewTap)];
    [followNumberView addGestureRecognizer:followNumberViewTap];
    [self addSubview:followNumberView];
    self.followNumberView = followNumberView;
    
    TTPersonalHomeHeaderInfoNumberView *likeNumbrView = [[TTPersonalHomeHeaderInfoNumberView alloc] initWithType:TTPersonalHomeHeaderInfoNumberViewTypeLike];
    likeNumbrView.hidden = YES;
    UITapGestureRecognizer *likeNumberViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(likeNumberViewTap)];
    [likeNumbrView addGestureRecognizer:likeNumberViewTap];
    [self addSubview:likeNumbrView];
    self.likeNumbrView = likeNumbrView;
    
    self.multiplePlatformFollowersInfoView = [[TTPersonalHomeMultiplePlatformFollowersInfoView alloc] initWithFrame:CGRectZero];
    self.multiplePlatformFollowersInfoView.hidden = YES;
    self.multiplePlatformFollowersInfoView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self addSubview:self.multiplePlatformFollowersInfoView];
    
    self.multiplePlatformFollowersTriangleView = [[SSThemedImageView alloc] initWithFrame:CGRectZero];
    self.multiplePlatformFollowersTriangleView.hidden = YES;
    self.multiplePlatformFollowersTriangleView.imageName = @"personal_home_triangle";
    self.multiplePlatformFollowersTriangleView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:self.multiplePlatformFollowersTriangleView];
    
    self.multiplePlatformFollowersTriangleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.multiplePlatformFollowersTriangleButton.hidden = YES;
    self.multiplePlatformFollowersTriangleButton.backgroundColor = [UIColor clearColor];
    [self.multiplePlatformFollowersTriangleButton addTarget:self action:@selector(multiplePlatformFollowersInfoViewDidClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.multiplePlatformFollowersTriangleButton];
    
    SSThemedView *bottomLine = [[SSThemedView alloc] init];
    bottomLine.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    bottomLine.backgroundColorThemeKey = kColorLine1;
    [self addSubview:bottomLine];
    self.bottomLine = bottomLine;
    [self setupSubviewFrameWithTopMargin:self.headerViewTopMargin];
}

- (void)setInfoModel:(TTPersonalHomeUserInfoDataResponseModel *)infoModel
{
    _infoModel = infoModel;
    
    if (!self.multiplePlatformFollowersInfoViewModel || ![self.multiplePlatformFollowersInfoViewModel.userID isEqualToString:infoModel.user_id]) {
        self.multiplePlatformFollowersInfoViewModel = [[TTPersonalHomeMultiplePlatformFollowersInfoViewModel alloc] initWithUserID:infoModel.user_id items:infoModel.platformFollowersInfoArr];
    } else {
        [self.multiplePlatformFollowersInfoViewModel refreshWithItems:infoModel.platformFollowersInfoArr];
    }
    
    [self setupSubviewData];
    [self setupSubviewFrameWithTopMargin:self.headerViewTopMargin];
}

- (void)setupSubviewData
{
    self.nameLabel.text = self.infoModel.name;
    self.realNameLabel.text = !isEmptyString(self.infoModel.remark_name) ? [NSString stringWithFormat:@"(%@)", self.infoModel.remark_name] : nil;
    
    NSString *sexImageName = nil;
    if(self.infoModel.gender.integerValue == 1) {
        sexImageName = @"boy";
//        self.sexImageView.hidden = NO;
    } else if(self.infoModel.gender.integerValue == 2) {
        sexImageName = @"girl";
//        self.sexImageView.hidden = NO;
    } else {
        self.sexImageView.hidden = YES;
    }
    self.sexImageView.imageName = sexImageName;
    if (self.infoModel.no_display_pgc_icon.integerValue != 0 || self.infoModel.media_id.integerValue == 0) {
        self.toutiaoIcon.hidden = YES;
    } else {
//        self.toutiaoIcon.hidden = NO;
    }
    
    if(!isEmptyString(self.infoModel.verified_content_v6)) {
//        self.authView.hidden = NO;
        [self.authView refreshWithItemType:TTPersonalHomeHeaderInfoItemTypeAuthInfo text:self.infoModel.verified_content_v6];
    } else {
        self.authView.hidden = YES;
    }
    
    if(!isEmptyString(self.infoModel.area)) {
//        self.locationView.hidden = NO;
        [self.locationView refreshWithItemType:TTPersonalHomeHeaderInfoItemTypeLocation text:self.infoModel.area];
    } else {
        self.locationView.hidden = YES;
    }
    
    if (!isEmptyString(self.infoModel.remark_desc)) {
//        self.recommendReasonView.hidden = NO;
        [self.recommendReasonView refreshWithItemType:TTPersonalHomeHeaderInfoItemTypeRecommendReason text:self.infoModel.remark_desc];
    } else {
        self.recommendReasonView.hidden = YES;
    }

    if(!isEmptyString(self.infoModel.desc)) {
//        self.introduceLabel.hidden = NO;
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.infoModel.desc];
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.lineSpacing = 1.4;
        [attributedString addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, attributedString.length)];
        [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:13]] range:NSMakeRange(0, attributedString.length)];
        style.lineBreakMode = NSLineBreakByTruncatingTail;
        self.introduceLabel.attributedText = attributedString;
    } else {
        self.introduceLabel.hidden = YES;
        self.introduceLabel.text = nil;
    }
    
    if([SSCommonLogic isPersonalHomeMediaTypeThreeEnable]) {
        if(self.infoModel.media_type.integerValue == 3) {
            self.followNumberView.hidden = YES;
            self.likeNumbrView.hidden = YES;
            self.followNumberView.size = CGSizeZero;
            self.likeNumbrView.size = CGSizeZero;
        } else {
            self.followNumberView.number = self.infoModel.followings_count;
            
            if ([self.multiplePlatformFollowersInfoViewModel canExpand]) {
                self.likeNumbrView.number = self.infoModel.multiplePlatformFollowersCount;
            } else {
                self.likeNumbrView.number = self.infoModel.followers_count;
            }
        }
    } else {
        self.followNumberView.number = self.infoModel.followings_count;
        
        if ([self.multiplePlatformFollowersInfoViewModel canExpand]) {
            self.likeNumbrView.number = self.infoModel.multiplePlatformFollowersCount;
        } else {
            self.likeNumbrView.number = self.infoModel.followers_count;
        }
    }
    
    self.multiplePlatformFollowersInfoView.viewModel = self.multiplePlatformFollowersInfoViewModel;
}

- (void)setupSubviewFrameWithTopMargin:(CGFloat)topMargin
{
    _headerViewTopMargin = topMargin;
    CGFloat commonMargin = [TTDeviceUIUtils tt_newPadding:8];
    CGFloat toutiaoIconWidth = 30;
    CGFloat sexIconWidth = 14;
    CGSize nameLabelSize = [self.nameLabel.text boundingRectWithSize:CGSizeMake(self.width - 2 * [TTDeviceUIUtils tt_newPadding:15] - toutiaoIconWidth - sexIconWidth - [TTDeviceUIUtils tt_newPadding:4], [TTDeviceUIUtils tt_newPadding:25]) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : self.nameLabel.font} context:nil].size;
    self.nameLabel.frame = CGRectMake([TTDeviceUIUtils tt_newPadding:15], [TTDeviceUIUtils tt_newPadding:topMargin], nameLabelSize.width, [TTDeviceUIUtils tt_newPadding:25]);
    CGSize realNameLabelSize = [self.realNameLabel.text boundingRectWithSize:CGSizeMake(self.width - 2 * [TTDeviceUIUtils tt_newPadding:15] - toutiaoIconWidth - sexIconWidth - 2 * [TTDeviceUIUtils tt_newPadding:4] - self.nameLabel.width, [TTDeviceUIUtils tt_newPadding:25]) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : self.realNameLabel.font} context:nil].size;
    self.realNameLabel.size = CGSizeMake(realNameLabelSize.width, realNameLabelSize.height);
    self.realNameLabel.left = self.nameLabel.right + [TTDeviceUIUtils tt_newPadding:4];
    self.realNameLabel.bottom = self.nameLabel.bottom - 2;
    
    self.sexImageView.left = self.realNameLabel.right + [TTDeviceUIUtils tt_newPadding:4];
    if(!self.sexImageView.hidden) {
        self.sexImageView.size = CGSizeMake(sexIconWidth, sexIconWidth);
        self.toutiaoIcon.left = self.sexImageView.right + [TTDeviceUIUtils tt_newPadding:4];
    } else {
        self.sexImageView.size = CGSizeZero;
        self.toutiaoIcon.left = self.sexImageView.left;
    }
    self.sexImageView.centerY = self.nameLabel.centerY;
    self.toutiaoIcon.size = CGSizeMake(toutiaoIconWidth, 15);
    self.toutiaoIcon.centerY = self.nameLabel.centerY;
    
    CGFloat medalX = self.toutiaoIcon.right + 4;
    if (self.toutiaoIcon.hidden) {
        medalX = self.toutiaoIcon.left;
    }
    CGFloat medalHeight = 15;
    for (SSThemedImageView* medalImageView in _medalImageViews) {
        [medalImageView removeFromSuperview];
    }
    _medalImageViews = @[].mutableCopy;
    NSDictionary* settingMedals = [TTKitchen getDictionary:kKCUGCMedals];

    if (self.infoModel.medals.count > 0) {
        for (NSString* medal in self.infoModel.medals) {
            if ([medal isKindOfClass:[NSString class]]) {
                if ([settingMedals isKindOfClass:[NSDictionary class]]) {
                    NSDictionary* modelDic = [settingMedals tt_dictionaryValueForKey:medal];
                    FRImageInfoModel *model = [[FRImageInfoModel alloc] initWithDictionary:modelDic];
                    if (model && model.width > 0 && model.height > 0) {
                        
                        CGFloat width = (CGFloat) medalHeight*model.width/model.height;
                        if (medalX + width > self.width) {
                            continue;
                        }
                        
                        SSThemedImageView* imageView = [[SSThemedImageView alloc] initWithFrame:CGRectMake(medalX, 0, width, medalHeight)];
                        imageView.enableNightCover = YES;
                        imageView.centerY = self.nameLabel.centerY;
                        NSURL *url = [TTStringHelper URLWithURLString:model.url];
                        [imageView sda_setImageWithURL:url];//!!!备注，这里原来是用model加载的，包含重试机制，
                        medalX = imageView.right + 4;
                        [self addSubview:imageView];
                        [_medalImageViews addObject:imageView];
                    }
                }
            }
        }
    }
    
    self.locationView.left = self.nameLabel.left;
    self.recommendReasonView.left = self.nameLabel.left;
    self.authView.left = self.nameLabel.left;
    
    CGFloat currentBottom = self.nameLabel.bottom;
    if (!self.authView.hidden) {
        CGSize authViewSize = [self.authView.textLabel.text boundingRectWithSize:CGSizeMake(self.width - 2 * [TTDeviceUIUtils tt_newPadding:15] - [TTDeviceUIUtils tt_newPadding:14] - [TTDeviceUIUtils tt_newPadding:4], MAXFLOAT)
                                                                         options:NSStringDrawingUsesLineFragmentOrigin
                                                                      attributes:@{NSFontAttributeName : self.authView.textLabel.font} context:nil].size;
        if(authViewSize.height > [TTDeviceUIUtils tt_newPadding:22]) {
            self.authView.size = CGSizeMake(self.width - 2 * [TTDeviceUIUtils tt_newPadding:15], [TTDeviceUIUtils tt_newPadding:37]);
        } else {
            self.authView.size = CGSizeMake(self.width - 2 * [TTDeviceUIUtils tt_newPadding:15], [TTDeviceUIUtils tt_newPadding:18]);
        }
        self.authView.top = currentBottom + [TTDeviceUIUtils tt_newPadding:6];
    } else {
        self.authView.size = CGSizeZero;
        self.authView.top = currentBottom;
    }
    currentBottom = self.authView.bottom;
    
    if(!self.locationView.hidden) {
        self.locationView.size = CGSizeMake(self.width - 2 * [TTDeviceUIUtils tt_newPadding:15], [TTDeviceUIUtils tt_newPadding:18]);
        self.locationView.top = currentBottom + [TTDeviceUIUtils tt_newPadding:6];
    } else {
        self.locationView.size = CGSizeZero;
        self.locationView.top = currentBottom;
    }
    currentBottom = self.locationView.bottom;
    
    if(!self.recommendReasonView.hidden) {
        self.recommendReasonView.size = CGSizeMake(self.width - 2 * [TTDeviceUIUtils tt_newPadding:15], [TTDeviceUIUtils tt_newPadding:18]);
        self.recommendReasonView.top = currentBottom + [TTDeviceUIUtils tt_newPadding:6];
    } else {
        self.recommendReasonView.size = CGSizeZero;
        self.recommendReasonView.top = currentBottom;
    }
    currentBottom = self.recommendReasonView.bottom;
    
    self.introduceLabel.left = self.nameLabel.left;
    self.introduceLabel.top = currentBottom + [TTDeviceUIUtils tt_newPadding:6];
    
    self.spreadOutBtn.width = [TTDeviceUIUtils tt_newPadding:27];
    self.spreadOutBtn.height = [TTDeviceUIUtils tt_newPadding:18];
    if(!self.introduceLabel.hidden) {
        self.introduceLabel.numberOfLines = 0;
        CGSize introdeceLabelSize = [self.introduceLabel sizeThatFits:CGSizeMake(self.width - 2 * [TTDeviceUIUtils tt_newPadding:15], MAXFLOAT)];
        if(introdeceLabelSize.height > [TTDeviceUIUtils tt_newPadding:18]) {
            if(!self.spreadOutBtn.selected) {
//                self.spreadOutBtn.hidden = NO;
                self.introduceLabel.size = CGSizeMake(self.width - 2 * [TTDeviceUIUtils tt_newPadding:15] - self.spreadOutBtn.width, [TTDeviceUIUtils tt_newPadding:18]);
                self.spreadOutBtn.right = self.width - [TTDeviceUIUtils tt_newPadding:15];
                self.spreadOutBtn.centerY = self.introduceLabel.centerY;
                self.introduceLabel.numberOfLines = 1;
            } else {
                self.introduceLabel.numberOfLines = 0;
                self.introduceLabel.size = CGSizeMake(self.width - 2 * [TTDeviceUIUtils tt_newPadding:15], introdeceLabelSize.height);
                self.spreadOutBtn.hidden = YES;
            }
        } else {
            self.introduceLabel.size = CGSizeMake(introdeceLabelSize.width, [TTDeviceUIUtils tt_newPadding:18]);
            self.introduceLabel.numberOfLines = 1;
            self.spreadOutBtn.hidden = YES;
        }
        
        if([SSCommonLogic isPersonalHomeMediaTypeThreeEnable]) {
            if(!self.followNumberView.hidden) {
                self.followNumberView.top = self.introduceLabel.bottom + commonMargin;
            } else {
                self.followNumberView.top = self.introduceLabel.bottom;
            }
        } else {
            self.followNumberView.top = self.introduceLabel.bottom + commonMargin;
        }
    } else {
        self.introduceLabel.size = CGSizeZero;
        self.followNumberView.top = self.introduceLabel.top;
        self.spreadOutBtn.hidden = YES;
    }
    
    // 爱看：只显示关注数和粉丝数
    self.followNumberView.top = self.recommendReasonView.top + 10.f;
    
    self.followNumberView.left = self.nameLabel.left;
    
    if(!self.followNumberView.hidden) {
        self.likeNumbrView.left = self.followNumberView.right + [TTDeviceUIUtils tt_newPadding:12];
    } else {
        self.likeNumbrView.left = self.followNumberView.left;
    }
    self.likeNumbrView.top = self.followNumberView.top;
    
    [self refreshUIWithMultiplePlatformFollowersInfoViewSpreadOut:self.multiplePlatformFollowersInfoViewModel.isExpanded];
}

- (void)refreshUIWithMultiplePlatformFollowersInfoViewSpreadOut:(BOOL)spreadOut
{
    self.multiplePlatformFollowersTriangleView.size = CGSizeMake([TTDeviceUIUtils tt_newPadding:8], [TTDeviceUIUtils tt_newPadding:8]);
    self.multiplePlatformFollowersTriangleView.left = self.likeNumbrView.right + [TTDeviceUIUtils tt_newPadding:3];
    self.multiplePlatformFollowersTriangleView.centerY = self.likeNumbrView.centerY;
    
    self.multiplePlatformFollowersTriangleButton.size = CGSizeMake([TTDeviceUIUtils tt_newPadding:20], self.likeNumbrView.height);
    self.multiplePlatformFollowersTriangleButton.left = self.likeNumbrView.right;
    self.multiplePlatformFollowersTriangleButton.centerY = self.likeNumbrView.centerY;
    
    self.multiplePlatformFollowersInfoView.size = CGSizeMake(self.width, [TTPersonalHomeMultiplePlatformFollowersInfoView heightForViewModel:self.multiplePlatformFollowersInfoViewModel]);
    self.multiplePlatformFollowersInfoView.left = 0;
    
    self.bottomLine.width = self.width;
    self.bottomLine.height = [TTDeviceHelper ssOnePixel];
    self.bottomLine.left = 0;
    
    CGFloat height = self.followNumberView.hidden ? self.likeNumbrView.bottom : self.followNumberView.bottom;
    
//    if (!self.likeNumbrView.hidden && [self.multiplePlatformFollowersInfoViewModel canExpand]) {
////        self.multiplePlatformFollowersTriangleView.hidden = NO;
////        self.multiplePlatformFollowersTriangleButton.hidden = NO;
//        self.multiplePlatformFollowersTriangleView.transform = spreadOut ? CGAffineTransformMakeRotation(M_PI) : CGAffineTransformIdentity;
//        self.multiplePlatformFollowersInfoView.alpha = spreadOut ? 1 : 0;
//        self.multiplePlatformFollowersInfoView.top = height + (spreadOut ? [TTDeviceUIUtils tt_newPadding:10] : 0);
//        height = spreadOut ? self.multiplePlatformFollowersInfoView.bottom + [TTDeviceUIUtils tt_newPadding:15] : height + [TTDeviceUIUtils tt_newPadding:8];
//    } else {
//        self.multiplePlatformFollowersInfoView.alpha = 0;
//        self.multiplePlatformFollowersTriangleView.hidden = YES;
//        self.multiplePlatformFollowersTriangleButton.hidden = YES;
//        height = height + [TTDeviceUIUtils tt_newPadding:8];
//    }
    
    self.height = height + [TTDeviceUIUtils tt_newPadding:15];
    
    self.bottomLine.top = self.height - self.bottomLine.height;
    
    if (self.infoModel.live_data) {
        self.bottomLine.hidden = YES;
    }
}

- (void)followNumberViewTap
{
    NSString *url = [NSString stringWithFormat:@"sslocal://relation/following?uid=%@",self.infoModel.user_id];
    [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:url]];
    wrapperTrackEventWithCustomKeys(@"profile", @"follows_enter", self.infoModel.user_id, nil, @{@"follows_num" : @(self.infoModel.followings_count.integerValue)});
}

- (void)likeNumberViewTap
{
    if ([self.multiplePlatformFollowersInfoViewModel canExpand]) {
        [self multiplePlatformFollowersInfoViewDidClick];
    } else {
        NSString *url = [NSString stringWithFormat:@"sslocal://relation/follower?uid=%@",self.infoModel.user_id];
        [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:url]];
        wrapperTrackEventWithCustomKeys(@"profile", @"fans_enter", self.infoModel.user_id, nil, @{@"fans_num" : @(self.infoModel.followers_count.integerValue)});
    }
}

- (void)multiplePlatformFollowersInfoViewDidClick
{
    [self.multiplePlatformFollowersInfoViewModel changeExpandStatus];
    
    if (self.multiplePlatformFollowersInfoViewSpreadOutBlock) {
        self.multiplePlatformFollowersInfoViewSpreadOutBlock(self.multiplePlatformFollowersInfoViewModel.isExpanded);
    }
}

@end
