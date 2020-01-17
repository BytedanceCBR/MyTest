//
//  TTUserInfoView.m
//  Article
//
//  Created by 冯靖君 on 15/12/29.
/**
 *  用户信息View，显示用户名及自定义logo
 */

#import "TTUserInfoView.h"
#import "TTLabelTextHelper.h"
#import "UIViewAdditions.h"
#import "TTDeviceHelper.h"
#import "TTThemeManager.h"
#import <TTBaseLib/NSDictionary+TTAdditions.h>
#import <TTImage/TTImageView.h>
#import <TTImage/TTImageInfosModel.h>
#import <objc/runtime.h>

#define kLogoSpacing    4.f
#define kLocalPlaceholderUrl @"file://temp.png" // 不知道这个TTImageInfosModel初始化如果URL为空会怎么样，干脆构造一个fake的URL

@interface TTUserInfoViewHelper : NSObject
@end
@implementation TTUserInfoViewHelper

+ (CGFloat)verifiedImageWidth {
    return 11.f * [self scaleFactor];
}

+ (CGFloat)verifiedImageHeight {
    return 11.f * [self scaleFactor];
}

+ (CGFloat)verifiedSeperateLineSpacing {
    return 4.f * [self scaleFactor];
}

+ (CGFloat)verifiedSeperateLineHeight {
    return 9.f * [self scaleFactor];
}

+ (CGFloat)verifiedContentFontSize {
    return 12.f * [self scaleFactor];
}

+ (CGFloat)verifiedImageSpacing {
    return 3.f * [self scaleFactor];
}

+ (CGFloat)verifiedContentMinWidth {
    static CGFloat minWidth = 0.f;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *minStr = @"三个字";
        CGSize minSize = [minStr sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:[self verifiedContentFontSize]]}];
        minWidth = ceil(minSize.width) + 2 * [self verifiedSeperateLineSpacing];
    });
    return minWidth;
}
+ (CGFloat)scaleFactor {
    if ([TTDeviceHelper is667Screen] || [TTDeviceHelper is736Screen]) {
        return 1.f;
    } else if ([TTDeviceHelper isPadDevice]) {
        return 1.3f;
    } else if ([TTDeviceHelper is568Screen] || [TTDeviceHelper is480Screen]) {
        return 0.9;
    }
    return 1.f;
}

+ (NSBundle *)imageBundle {
    static dispatch_once_t onceToken;
    static NSBundle *bundle;
    dispatch_once(&onceToken, ^{
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"TTUIWidgetResources" ofType:@"bundle"];
        bundle = [NSBundle bundleWithPath:bundlePath];
    });
    return bundle;
}

+ (NSString *)verifiedImageName {
    return @"ttuiwidget_all_newv";
}

+ (NSString *)ownerImageName {
    return @"details_original_poster_label";
}

+ (NSString *)authorImageName {
    return @"details_author_poster_label";
}


@end

@interface TTUserInfoNightMaskView : SSThemedView

@property (nonatomic, assign) BOOL enableRounded;
@property (nonatomic, assign) CGFloat nightAlpha;
@property (nonatomic, strong) UIImageView *maskView;

- (void)refreshWithMaskImage:(UIImage *)maskImage;

@end

@implementation TTUserInfoNightMaskView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _nightAlpha = 0.5;
        self.userInteractionEnabled = NO;
        [self setupMaskView];
    }
    return self;
}

- (void)themeChanged:(NSNotification *)notification
{
    [self setupMaskView];
}

- (UIImageView *)maskView
{
    if (!_maskView) {
        _maskView = [[UIImageView alloc] init];
        _maskView.contentMode = UIViewContentModeScaleAspectFit;
        self.layer.mask = _maskView.layer;
    }
    
    return _maskView;
}

- (void)setupMaskView
{
    BOOL isDayMode = [[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay;
    if (isDayMode) {
        self.backgroundColor = [UIColor clearColor];
    } else {
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:self.nightAlpha];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (self.enableRounded) {
        self.layer.cornerRadius = self.bounds.size.width / 2;
    } else {
        self.layer.cornerRadius = 0;
    }
    if (self.maskView.image) {
        self.maskView.frame = self.frame;
    }
}

- (void)refreshWithMaskImage:(UIImage *)maskImage
{
    // 为了性能，不使用[UIImage isEqual]，前者会比较CGImage的Data。直接比较指针地址
    if (!maskImage || maskImage == self.maskView.image) {
        return;
    }
    self.maskView.image = maskImage;
    [self setNeedsLayout];
}

@end

@interface TTImageView (TTUserInfoNightMaskView)

@property (nonatomic, strong) TTUserInfoNightMaskView *ttUserInfoNightMaskView;

@end

@implementation TTImageView (TTUserInfoNightMaskView)

- (void)setTtUserInfoNightMaskView:(TTUserInfoNightMaskView *)ttUserInfoNightMaskView
{
    objc_setAssociatedObject(self, @selector(ttUserInfoNightMaskView), ttUserInfoNightMaskView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (TTUserInfoNightMaskView *)ttUserInfoNightMaskView
{
    TTUserInfoNightMaskView *nightMaskView = objc_getAssociatedObject(self, @selector(ttUserInfoNightMaskView));
    if (!nightMaskView) {
        nightMaskView = [[TTUserInfoNightMaskView alloc] init];
        [self setTtUserInfoNightMaskView:nightMaskView];
        [self addSubview:nightMaskView];
    }
    
    return nightMaskView;
}

@end

@interface TTImageInfosModel (TTUserInfoView)

@property (nonatomic, assign) NSString *tt_localImageName; //本地图片的ImageName

@end

@implementation TTImageInfosModel (TTUserInfoView)

- (NSString *)tt_localImageName {
    return objc_getAssociatedObject(self, @selector(tt_localImageName));
}

- (void)setTt_localImageName:(NSString *)tt_localImageName {
    objc_setAssociatedObject(self, @selector(tt_localImageName), tt_localImageName, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

@interface TTUserInfoView ()

@property(nonatomic, strong) NSMutableArray<TTImageInfosModel *> *logoModelArray;
@property(nonatomic, strong) NSMutableArray<TTImageView *> * logoViewArray;
@property(nonatomic, strong) NSArray<NSDictionary *> *origLogoArray;
@property(nonatomic, assign) CGFloat maxWidth;
@property(nonatomic, assign) CGFloat limitHeight;
@property(nonatomic, assign) CGFloat fontSize;
@property(nonatomic, assign) CGFloat logoAreaWidth;
@property(nonatomic, copy) TitleLinkBlock clickTitleAction;
@property(nonatomic, copy) LogoLinkBlock clickLogoAction;
@property(nonatomic, strong) UITapGestureRecognizer *tap;
@property(nonatomic, strong) SSThemedView *verifiedSeperateLine;
@property(nonatomic, strong) SSThemedLabel *relationLabel;
@property(nonatomic, assign) BOOL isVerifiedUser;
@property(nonatomic, assign) BOOL hasVerifiedInfo;
@property(nonatomic, assign) BOOL isOwner;
@property(nonatomic, copy) NSString *relation;
@property(nonatomic, strong) TTImageInfosModel *ownerModel;
@property(nonatomic, strong) TTImageInfosModel *verifiedModel;

@end

@implementation TTUserInfoView

- (instancetype)initWithBaselineOrigin:(CGPoint)baselineOriginPoint
                              maxWidth:(CGFloat)maxWidth
                           limitHeight:(CGFloat)limitHeight
                                 title:(NSString *)title
                              fontSize:(CGFloat)fontSize
                   appendLogoInfoArray:(NSArray<NSDictionary *>*)logoArray
{
    return [self initWithBaselineOrigin:baselineOriginPoint maxWidth:maxWidth limitHeight:limitHeight title:title fontSize:fontSize verifiedInfo:nil appendLogoInfoArray:logoArray];
}

- (instancetype)initWithBaselineOrigin:(CGPoint)baselineOriginPoint maxWidth:(CGFloat)maxWidth limitHeight:(CGFloat)limitHeight title:(NSString *)title fontSize:(CGFloat)fontSize verifiedInfo:(NSString *)verifiedInfo appendLogoInfoArray:(NSArray<NSDictionary *> *)logoArray
{
    return [self initWithBaselineOrigin:baselineOriginPoint maxWidth:maxWidth limitHeight:limitHeight title:title fontSize:fontSize verifiedInfo:verifiedInfo verified:!isEmptyString(verifiedInfo) owner:NO appendLogoInfoArray:logoArray];
}

- (instancetype)initWithBaselineOrigin:(CGPoint)baselineOriginPoint
                              maxWidth:(CGFloat)maxWidth
                           limitHeight:(CGFloat)limitHeight
                                 title:(NSString *)title
                              fontSize:(CGFloat)fontSize
                          verifiedInfo:(NSString *)verifiedInfo
                              verified:(BOOL)isVerified
                                 owner:(BOOL)isOwner
                   appendLogoInfoArray:(NSArray<NSDictionary *> *)logoArray
{
    self = [super initWithFrame:CGRectMake(baselineOriginPoint.x, 0, 0, 0)];
    if (self) {
        NSInteger logoCount = verifiedInfo.length? logoArray.count + 1: logoArray.count;
        
        _maxWidth = maxWidth;
        _limitHeight = limitHeight;
        _fontSize = fontSize;
        _ownerType = TTOwnerType_CommentAuthor;
        self.centerY = baselineOriginPoint.y;
        _textColorThemedKey = kColorText3;
        _titleClickActionExtendToLogos = YES;

        _logoModelArray = [NSMutableArray arrayWithCapacity:logoCount];
        _logoViewArray = [NSMutableArray arrayWithCapacity:logoCount];
        
        _titleLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _titleLabel.backgroundColor = [UIColor clearColor];
//        _titleLabel.textColorThemeKey = _textColorThemedKey;
        _titleLabel.textColor = [UIColor tt_themedColorForKey:_textColorThemedKey];
        _titleLabel.font = [UIFont systemFontOfSize:fontSize];
        _titleLabel.numberOfLines = 1;
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        
        [self addSubview:_titleLabel];
        _tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        [self addGestureRecognizer:_tap];

        _isBanShowAuthor = NO;
        
        [self _constructUserInfoViewWithTitle:title relation:nil verified:isVerified owner:isOwner verifiedInfo:verifiedInfo logoInfoArray:logoArray];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    return [self initWithBaselineOrigin:CGPointZero maxWidth:0 limitHeight:0 title:nil fontSize:0 verifiedInfo:nil appendLogoInfoArray:nil];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    return [self initWithBaselineOrigin:CGPointZero maxWidth:0 limitHeight:0 title:nil fontSize:0 verifiedInfo:nil appendLogoInfoArray:nil];
}

- (void)layoutSubviews {
    if (self.titleLabel) {
        self.titleLabel.centerY = self.height / 2.f;
    }

    if (self.verifiedLabel) {
        self.verifiedLabel.centerY = self.height / 2.f;
    }

    if (self.verifiedSeperateLine) {
        self.verifiedSeperateLine.centerY = self.height / 2.f;
    }

    if (self.relationLabel) {
        self.relationLabel.centerY = self.height / 2.f;
    }

    for (TTImageView *imageView in self.logoViewArray) {
        imageView.centerY = self.height / 2.f;
        imageView.top = ceil(imageView.top);
    }
}

- (void)refreshWithTitle:(NSString *)title appendLogoInfoArray:(NSArray<NSDictionary *>*)logoArray
{
    [self refreshWithTitle:title verifedInfo:nil appendLogoInfoArray:logoArray];
}

- (void)refreshWithTitle:(NSString *)title relation:(NSString *)relation verifiedInfo:(NSString *)verifiedInfo verified:(BOOL)isVerified owner:(BOOL)isOwner maxWidth:(CGFloat)maxWidth appendLogoInfoArray:(NSArray<NSDictionary *> *)logoArray {
    _maxWidth = maxWidth? : _maxWidth;
    [self _clearSubViews];
    [self _constructUserInfoViewWithTitle:title relation:relation verified:isVerified owner:isOwner verifiedInfo:verifiedInfo logoInfoArray:logoArray];
}

- (void)refreshWithTitle:(NSString *)title verifedInfo:(NSString *)verifiedInfo appendLogoInfoArray:(NSArray<NSDictionary *> *)logoArray {
    [self refreshWithTitle:title relation:nil verifiedInfo:verifiedInfo verified:!isEmptyString(verifiedInfo) owner:NO maxWidth:_maxWidth appendLogoInfoArray:logoArray];

}

- (void)_constructUserInfoViewWithTitle:(NSString *)title
                               relation:(NSString *)relation
                               verified:(BOOL)isVerified
                                  owner:(BOOL)isOwner
                           verifiedInfo:(NSString *)verifiedInfo
                          logoInfoArray:(NSArray<NSDictionary *>*)logoArray
{
    if (isEmptyString(title)) {
        return;
    }
    _isVerifiedUser = isVerified;
    _hasVerifiedInfo = !isEmptyString(verifiedInfo);
    _isOwner = isOwner;
    _relation = relation;
    _origLogoArray = logoArray;
    
    [self buildVerifiedViewsIfNeed];
    [self buildRelationLabelIfNeed];
    [self buildOwnerViewIfNeed];
    _titleLabel.text = title;
    [_titleLabel sizeToFit];
    if (_titleLabel.width > _maxWidth) {
        _titleLabel.width = _maxWidth;
    }
    _titleLabel.left = 0;
    _titleLabel.centerY = self.height / 2;
    _verifiedLabel.text = verifiedInfo;
    [_verifiedLabel sizeToFit];
    _verifiedLabel.width = ceil(_verifiedLabel.width);
    _verifiedLabel.centerY = _titleLabel.centerY;
    _relationLabel.text = relation;
    [_relationLabel sizeToFit];
    _relationLabel.width = ceil(_relationLabel.width);
    
    _verifiedLabel.hidden = _verifiedSeperateLine.hidden = !_hasVerifiedInfo;
    _relationLabel.hidden = isEmptyString(relation);
    
    if (_isVerifiedUser && _verifiedModel) {
        [_logoModelArray addObject:_verifiedModel];
    }
    
    if (!_isBanShowAuthor) {
        if (_isOwner && _ownerModel) {
            [_logoModelArray addObject:_ownerModel];
        }
        for (NSDictionary * dict in logoArray) {
            TTImageInfosModel *model = [[TTImageInfosModel alloc] initWithDictionary:dict];
            if (model) {
                [_logoModelArray addObject:model];
            }
            
        }
    }

    CGFloat totalWidth = _titleLabel.width + _relationLabel.width;
    if (_hasVerifiedInfo) {
        totalWidth += _verifiedLabel.width + (2 * [TTUserInfoViewHelper verifiedSeperateLineSpacing]);
    }

    CGSize size = [self _buildLogoViewsWithSize:CGSizeMake(ceilf(totalWidth), _titleLabel.height)];
    self.size = size;
}

- (void)buildVerifiedViewsIfNeed {
    if (_hasVerifiedInfo && !_verifiedLabel) {
        _verifiedLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _verifiedLabel.backgroundColor = [UIColor clearColor];
        _verifiedLabel.textColorThemeKey = kColorText3;
        _verifiedLabel.font = [UIFont systemFontOfSize:[TTUserInfoViewHelper verifiedContentFontSize]];
        _verifiedLabel.numberOfLines = 1;
        _verifiedLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        
        _verifiedSeperateLine = [[SSThemedView alloc] initWithFrame:CGRectMake(0, 0, [TTDeviceHelper ssOnePixel], [TTUserInfoViewHelper verifiedSeperateLineHeight])];
        _verifiedSeperateLine.backgroundColorThemeKey = kColorLine7;
        [self addSubview:_verifiedLabel];
        [self addSubview:_verifiedSeperateLine];
    }

    if (_isVerifiedUser && !_verifiedModel) {
        NSString *imageName = [TTUserInfoViewHelper verifiedImageName];
        if (!isEmptyString(imageName)) {
            NSString *url = kLocalPlaceholderUrl;
            _verifiedModel = [[TTImageInfosModel alloc] initWithDictionary:@{@"height": @(33),
                                                                             @"width": @(33),
                                                                             @"url_list":@[@{@"url":url},@{@"url":url}],
                                                                             @"url":url}];
            _verifiedModel.tt_localImageName = imageName;
        }
    }
}

- (void)buildRelationLabelIfNeed {
    if (!isEmptyString(_relation) && !_relationLabel) {
        _relationLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _relationLabel.textColorThemeKey = kColorText3;
        _relationLabel.font = [self.titleLabel.font copy];
        [self addSubview:_relationLabel];
    }
}

- (void)buildOwnerViewIfNeed {
    if (_isOwner && !_ownerModel) {
        NSString *imageName;
        if (self.ownerType == TTOwnerType_ContentAuthor) {
            imageName = [TTUserInfoViewHelper authorImageName];
        }
        else {
            imageName = [TTUserInfoViewHelper ownerImageName];
        }
        if (!isEmptyString(imageName)) {
            NSString *url = kLocalPlaceholderUrl;
            _ownerModel = [[TTImageInfosModel alloc] initWithDictionary:@{@"height": @(42),
                                                                      @"width": @(78),
                                                                      @"url_list":@[@{@"url":url},@{@"url":url}],
                                                                      @"url":url}];
            _ownerModel.tt_localImageName = imageName;
        }
    }
}

- (void)setVerifiedLogoInfo:(NSDictionary *)verifiedLogoInfo
{
    if (SSIsEmptyDictionary(verifiedLogoInfo)) return;
    _verifiedLogoInfo = verifiedLogoInfo;
    TTImageInfosModel *verifiedModel = [[TTImageInfosModel alloc] initWithDictionary:verifiedLogoInfo];
    self.verifiedModel = verifiedModel;
}

- (void)setOwnerLogoInfo:(NSDictionary *)ownerLogoInfo
{
    if (SSIsEmptyDictionary(ownerLogoInfo)) return;
    _ownerLogoInfo = ownerLogoInfo;
    TTImageInfosModel *ownerModel = [[TTImageInfosModel alloc] initWithDictionary:ownerLogoInfo];
    self.ownerModel = ownerModel;
}

- (void)_clearSubViews
{
    [_logoModelArray removeAllObjects];
    [_logoViewArray makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_logoViewArray removeAllObjects];
}

- (CGSize)_buildLogoViewsWithSize:(CGSize)size {
    /**
     *  UI又说logo尺寸不能超过文字高度，更改限高为字体高度(有修正值)，忽略外部传入limitHeight值
     */
    //有认证信息时logo大小不能超过认证信息
    _limitHeight =  (_hasVerifiedInfo? [TTUserInfoViewHelper verifiedContentFontSize]: _fontSize) - 1.f;

    _logoAreaWidth = 0;
    for (NSInteger i = 0; i < _logoModelArray.count; i++ ) {
        //限高
        TTImageInfosModel *model =  [_logoModelArray objectAtIndex:i];
        if (_limitHeight > 0 && model.height > _limitHeight) {
            //等比压缩
            CGFloat height = _limitHeight;
            CGFloat width = height * model.width / model.height;
            model.width = ceilf(width);
            model.height = ceilf(height);
        }
        _logoAreaWidth += kLogoSpacing + model.width;
    }
    size.width += _logoAreaWidth; // 先计算logo的width

    if (ceilf(size.width) > _maxWidth) {
        CGFloat restWidth = _maxWidth - _titleLabel.width - _logoAreaWidth - _relationLabel.width;
        if (restWidth < 0) {
            _titleLabel.width = ceil(_maxWidth - _logoAreaWidth - _relationLabel.width);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            CGSize actual = [_titleLabel.text sizeWithFont:_titleLabel.font constrainedToSize:CGSizeMake(_titleLabel.width, _titleLabel.height) lineBreakMode:NSLineBreakByTruncatingTail];
#pragma clang diagnostic pop
            _titleLabel.width = ceil(actual.width);
            _verifiedLabel.hidden = YES;
            _verifiedSeperateLine.hidden = YES;
        } else {
            _verifiedLabel.hidden = restWidth < [TTUserInfoViewHelper verifiedContentMinWidth] ? YES: NO;
            _verifiedSeperateLine.hidden = _verifiedLabel.hidden;
            _verifiedLabel.width = restWidth - (2 * [TTUserInfoViewHelper verifiedSeperateLineSpacing]);
        }
        size.width = _maxWidth;
    }
    CGFloat offset = _titleLabel.right;
    if (_hasVerifiedInfo && !_verifiedLabel.hidden) {
        _verifiedSeperateLine.left = _titleLabel.right + [TTUserInfoViewHelper verifiedSeperateLineSpacing];
        _verifiedLabel.left = _verifiedSeperateLine.right + [TTUserInfoViewHelper verifiedSeperateLineSpacing];
        offset = _verifiedLabel.right;
    }

    CGFloat startLogoOriX = offset;
    CGFloat maxLogoHeight = _titleLabel.height;
    for (NSInteger i = 0; i < _logoModelArray.count; i++ ) {
        //限高
        TTImageInfosModel *model =  [_logoModelArray objectAtIndex:i];
        startLogoOriX += (kLogoSpacing);

        CGFloat top = ceilf((size.height - model.height) / 2.f);
        TTImageView *imageView = [[TTImageView alloc] initWithFrame:CGRectMake(startLogoOriX, top, model.width, model.height)];
        imageView.imageContentMode = TTImageViewContentModeScaleToFill;
        imageView.enableNightCover = NO;
        imageView.enableAlphaNightCover = NO;
        if (!isEmptyString(model.tt_localImageName)) {
            NSString *imageName = model.tt_localImageName;
            NSBundle *imageBundle = [TTUserInfoViewHelper imageBundle];
            UIImage *image = [UIImage imageNamed:imageName inBundle:imageBundle compatibleWithTraitCollection:nil];
            if (image) {
                [imageView setImage:image];
                if (!self.disableLogoNightMask) {
                    imageView.ttUserInfoNightMaskView.size = imageView.bounds.size;
                    [imageView.ttUserInfoNightMaskView refreshWithMaskImage:image];
                }
            }
        } else {
            __weak __typeof(imageView) weakImageView = imageView;
            __weak __typeof(self) weakSelf = self;
            [imageView setImageWithModel:model placeholderImage:self.placeholderImage options:0 success:^(UIImage *image, BOOL cached) {
                __strong __typeof(weakImageView) strongImageView = weakImageView;
                __strong __typeof(weakSelf) strongSelf = weakSelf;
                if (!strongSelf.disableLogoNightMask) {
                    strongImageView.ttUserInfoNightMaskView.size = strongImageView.bounds.size;
                    [strongImageView.ttUserInfoNightMaskView refreshWithMaskImage:image];
                }
            } failure:nil];
        }
        if (!isEmptyString(model.openURL)) {
            imageView.userInteractionEnabled = YES;
            UITapGestureRecognizer *logoTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(logoTap:)];
            [imageView addGestureRecognizer:logoTap];
        }
        [_logoViewArray addObject:imageView];
        [self addSubview:imageView];
        
        startLogoOriX += imageView.width;
        if (imageView.height > maxLogoHeight) {
            maxLogoHeight = imageView.height;
        }
    }


    _relationLabel.left = MAX([_logoViewArray lastObject].right, _titleLabel.right);
    _relationLabel.left += 2.f;
    _titleLabel.top = (size.height - _titleLabel.height)/2;
    if (_hasVerifiedInfo && !_verifiedLabel.hidden) {
        _verifiedSeperateLine.centerY = _titleLabel.centerY - 2.f;
        _verifiedLabel.centerY = _titleLabel.centerY - 2.f;
    }
    _relationLabel.top = ceilf((size.height - _relationLabel.height) / 2.f);

    return size;
}

- (void)setTextColorThemedKey:(NSString *)textColorThemedKey
{
    _textColorThemedKey = textColorThemedKey;
    [self reloadThemeUI];
}

- (void)setTitleClickActionExtendToLogos:(BOOL)titleClickActionExtendToLogos
{
    _titleClickActionExtendToLogos = titleClickActionExtendToLogos;
    _tap.enabled = _titleClickActionExtendToLogos;
}

- (void)themeChanged:(NSNotification *)notification
{
//    self.titleLabel.textColorThemeKey = _textColorThemedKey;
    self.titleLabel.textColor = [UIColor tt_themedColorForKey:_textColorThemedKey];
    self.backgroundColor = [UIColor clearColor];
//    [self buildVerifiedViewsIfNeed];
//    [self buildOwnerViewIfNeed];
    [self refreshWithTitle:_titleLabel.text relation:_relation verifiedInfo:_verifiedLabel.text verified:_isVerifiedUser owner:_isOwner maxWidth:_maxWidth appendLogoInfoArray:_origLogoArray];
}

- (void)clickTitleWithAction:(TitleLinkBlock)block
{
    if (block) {
        _clickTitleAction = block;
    }
}

- (void)clickLogoWithAction:(LogoLinkBlock)block
{
    if (block) {
        _clickLogoAction = block;
    }
}

#pragma mark - Tap
- (void)tap:(id)sender
{
    if (_clickTitleAction) {
        _clickTitleAction(nil);
    }
}

- (void)logoTap:(UITapGestureRecognizer *)tapGesture
{
    TTImageView *logo = (TTImageView *)tapGesture.view;
//    if ([[SSAppPageManager sharedManager] canOpenURL:[NSURL URLWithString:logo.model.openURL]]) {
//        [[SSAppPageManager sharedManager] openURL:[NSURL URLWithString:logo.model.openURL]];
//    }
    if (_clickLogoAction) {
        _clickLogoAction(logo.model.openURL);
    }
}

@end
