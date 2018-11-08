//
//  TTVPlayerTipRelatedImageIcon.m
//  Article
//
//  Created by panxiang on 2017/10/12.
//

#import "TTVPlayerTipRelatedImageIcon.h"
#import "NSTimer+NoRetain.h"
#import <BDWebImage/SDWebImageAdapter.h>
#import "TTVSwipeView.h"
#import "StyledPageControl.h"
#import "TTRoute.h"
#import "TTURLUtils.h"
#import "UIColor+TTThemeExtension.h"

extern NSString *ttvs_playerFinishedRelatedType(void);

@class TTVPlayerTipRelatedIconItem;
@protocol TTVPlayerTipRelatedIconItemDelegate <NSObject>
- (void)relatedItemClicked:(TTVPlayerTipRelatedIconItem *)item;
@end;

#define TTVPlayerTipRelatedImageIconTopSpace 12
#define TTVPlayerTipRelatedImageIconLeftSpace 12

@interface TTVPlayerTipRelatedIconItem : UIView
@property (nonatomic ,strong)TTVPlayerTipRelatedEntity *entity;
@property (nonatomic ,weak)id <TTVPlayerTipRelatedIconItemDelegate> delegate;
@end

@implementation TTVPlayerTipRelatedIconItem
@end

@interface TTVPlayerTipRelatedImageIconItem : TTVPlayerTipRelatedIconItem
@property (nonatomic ,strong)UIButton *button;
@property (nonatomic ,strong)UIButton *bgbutton;
@property (nonatomic ,strong)UILabel *titleLabel;
@property (nonatomic ,strong)UILabel *arrowImageView;
@property (nonatomic ,strong)UIImageView *iconImageView;
@property (nonatomic ,strong)UIImageView *playIcon;
@end

@implementation TTVPlayerTipRelatedImageIconItem

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _iconImageView = [[UIImageView alloc] init];
        _iconImageView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground5];

        [self addSubview:_iconImageView];
        
        _playIcon = [[UIImageView alloc] init];
        _playIcon.image = [UIImage imageNamed:@"Play"];
        [_iconImageView addSubview:_playIcon];
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:[TTDeviceUIUtils tt_fontSize:12]] ? : [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:12]];
        _titleLabel.numberOfLines = 2;
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self addSubview:_titleLabel];
        
        self.button = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.button setBackgroundColor:[UIColor colorWithRed:248/255.0f green:89/255.0f blue:89/255.0f alpha:1]];
        self.button.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:[TTDeviceUIUtils tt_fontSize:11]] ? : [UIFont boldSystemFontOfSize:[TTDeviceUIUtils tt_fontSize:11]];
        self.button.layer.cornerRadius = 4.0f;
        self.button.layer.borderWidth = [TTDeviceHelper ssOnePixel];
        self.button.layer.masksToBounds = YES;
        [self.button addTarget:self action:@selector(clickAction) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.button];
        
        self.bgbutton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.bgbutton setBackgroundColor:[UIColor clearColor]];
        [self.bgbutton addTarget:self action:@selector(clickAction) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.bgbutton];
    }
    return self;
}

- (void)setEntity:(TTVPlayerTipRelatedEntity *)entity
{
    [super setEntity:entity];
    [_iconImageView sda_setImageWithURL:[NSURL URLWithString:entity.video.cover_image_url]];
    _titleLabel.text = entity.title;
    NSString *downloadText = entity.download_text;
    if (isEmptyString(downloadText)) {
        downloadText = @"查看更多";
    }
    [self.button setTitle:downloadText forState:UIControlStateNormal];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.bgbutton.frame = self.bounds;
    NSInteger iconImageViewHeight = 40;
    _iconImageView.frame = CGRectMake(TTVPlayerTipRelatedImageIconLeftSpace, (self.height - iconImageViewHeight) / 2.0, 72, iconImageViewHeight);
    _playIcon.frame = CGRectMake(0, 0, 25, 25);
    _playIcon.center = CGPointMake(_iconImageView.width / 2.0, _iconImageView.height / 2.0);
    int moreWidth = 72;
    int moreHeight = 28;
    [self.button sizeToFit];
    moreWidth = MAX(moreWidth, self.button.width);
    moreHeight = MAX(moreHeight, self.button.height);
    _button.frame = CGRectMake(self.width - moreWidth - 16, (self.height - moreHeight) / 2.0, moreWidth, moreHeight);
    _titleLabel.frame = CGRectMake(_iconImageView.right + 8, _iconImageView.top, _button.left - _iconImageView.right - 8 - 12, 34);
}

- (void)clickAction
{
    if ([self.delegate respondsToSelector:@selector(relatedItemClicked:)]) {
        [self.delegate relatedItemClicked:self];
    }
}
@end

@interface TTVPlayerTipRelatedAppIconItem : TTVPlayerTipRelatedIconItem
@property (nonatomic ,strong)UIButton *button;
@property (nonatomic ,strong)UIImageView *appIcon;
@property (nonatomic ,strong)UILabel *titleLabel;
@property (nonatomic ,strong)UIImageView *arrowImageView;
@end

@implementation TTVPlayerTipRelatedAppIconItem
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _appIcon = [[UIImageView alloc] init];
        _appIcon.layer.cornerRadius = 5;
        _appIcon.layer.masksToBounds = YES;
        _appIcon.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground3];
        _appIcon.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_appIcon];

        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:[TTDeviceUIUtils tt_fontSize:15]] ? : [UIFont boldSystemFontOfSize:[TTDeviceUIUtils tt_fontSize:15]];
        _titleLabel.numberOfLines = 1;
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self addSubview:_titleLabel];
        
        _arrowImageView = [[UIImageView alloc] init];
        _arrowImageView.image = [UIImage imageNamed:@"video_tip_related_arrow.png"];
        _arrowImageView.backgroundColor = [UIColor clearColor];
        [_arrowImageView sizeToFit];
        [self addSubview:_arrowImageView];
        
        self.button = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.button addTarget:self action:@selector(clickAction) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.button];
    }
    return self;
}


- (void)setEntity:(TTVPlayerTipRelatedEntity *)entity
{
    [super setEntity:entity];
    [_appIcon sda_setImageWithURL:[NSURL URLWithString:entity.feed_icon_url]];
    _titleLabel.text = entity.title;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat top = 0;
    _appIcon.frame = CGRectMake(16, top, 24, 24);
    _arrowImageView.frame = CGRectMake(self.width - _arrowImageView.width, top, _arrowImageView.width, _arrowImageView.height);
    _titleLabel.frame = CGRectMake(_appIcon.right + 8, top, _arrowImageView.left - _appIcon.right - 8 - 53, _appIcon.height);
    self.button.frame = self.bounds;
}

- (void)clickAction
{
    if ([self.delegate respondsToSelector:@selector(relatedItemClicked:)]) {
        [self.delegate relatedItemClicked:self];
    }
}

@end

@interface TTVPlayerTipRelatedSimpleItem : TTVPlayerTipRelatedIconItem
@property (nonatomic ,strong)UIButton *button;
@property (nonatomic ,strong)UILabel *titleLabel;
@property (nonatomic ,strong)UIImageView *arrowImageView;
@property (nonatomic ,strong)NSTimer *timer;
@end

@implementation TTVPlayerTipRelatedSimpleItem
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.button = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.button addTarget:self action:@selector(clickAction) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.button];
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:[TTDeviceUIUtils tt_fontSize:13]] ? : [UIFont boldSystemFontOfSize:[TTDeviceUIUtils tt_fontSize:13]];
        _titleLabel.numberOfLines = 1;
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self addSubview:_titleLabel];
        
        _arrowImageView = [[UIImageView alloc] init];
        _arrowImageView.image = [UIImage imageNamed:@"video_tip_related_arrow.png"];
        _arrowImageView.backgroundColor = [UIColor clearColor];
        [_arrowImageView sizeToFit];
        [self addSubview:_arrowImageView];
    }
    return self;
}


- (void)setEntity:(TTVPlayerTipRelatedEntity *)entity
{
    [super setEntity:entity];
    _titleLabel.text = [NSString stringWithFormat:@"%@ | %@",isEmptyString(entity.download_text) ? @"查看更多" : entity.download_text ,entity.title];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat height = 18;
    CGFloat top = (self.height - height) / 2.0;
    _arrowImageView.frame = CGRectMake(self.width - _arrowImageView.width - 3, (self.height - _arrowImageView.height) / 2.0, _arrowImageView.width, _arrowImageView.height);
    [_titleLabel sizeToFit];
    _titleLabel.frame = CGRectMake(15, top, _arrowImageView.left - 41, height);
    self.button.frame = self.bounds;
}

- (void)clickAction
{
    if ([self.delegate respondsToSelector:@selector(relatedItemClicked:)]) {
        [self.delegate relatedItemClicked:self];
    }
}

@end

@interface TTVPlayerTipRelatedImageIcon()<TTVSwipeViewDelegate ,TTVSwipeViewDataSource ,TTVPlayerTipRelatedIconItemDelegate>
@property (nonatomic ,strong)NSArray *items;
@property (nonatomic ,strong)NSTimer *timer;
@property (nonatomic ,strong)TTVSwipeView *swipeView;
@property (nonatomic ,strong)StyledPageControl *pageControl;
@end

@implementation TTVPlayerTipRelatedImageIcon
- (void)dealloc
{
    [self.timer invalidate];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _swipeView = [[TTVSwipeView alloc] initWithFrame:self.bounds];
        _swipeView.dataSource = self;
        _swipeView.pagingEnabled = YES;
        _swipeView.delegate = self;
        _swipeView.bounces = NO;
        _swipeView.wrapEnabled = YES;
        [self addSubview:_swipeView];
        
        UIView *dotNormal = [[UIView alloc] init];
        dotNormal.backgroundColor = [UIColor colorWithWhite:1 alpha:0.7];
        dotNormal.width = 6;
        dotNormal.height = 2;

        UIGraphicsBeginImageContextWithOptions(dotNormal.bounds.size, dotNormal.opaque, 0.0);
        [[UIBezierPath bezierPathWithRoundedRect:dotNormal.bounds
                                    cornerRadius:100] addClip];
        [dotNormal.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage * imgSelected = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        dotNormal.backgroundColor = [UIColor colorWithWhite:1 alpha:0.3];

        UIGraphicsBeginImageContextWithOptions(dotNormal.bounds.size, dotNormal.opaque, 0.0);
        [[UIBezierPath bezierPathWithRoundedRect:dotNormal.bounds
                                    cornerRadius:100] addClip];
        [dotNormal.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage * imgNormal = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        self.pageControl = [[StyledPageControl alloc] initWithFrame:CGRectZero];
        self.pageControl.hidesForSinglePage = YES;
        self.pageControl.pageControlStyle = PageControlStyleThumb;
        self.pageControl.gapWidth = 2;
        self.pageControl.thumbImage = imgNormal;
        self.pageControl.selectedThumbImage = imgSelected;
        [self addSubview:self.pageControl];
    }
    return self;
}

- (void)startTimer
{
    [self performSelector:@selector(sendRelatedViewShowTrackAtIndex:) withObject:@(0) afterDelay:0];
    [self.timer invalidate];
    self.timer = [NSTimer scheduledNoRetainTimerWithTimeInterval:kAutoChangeTime target:self selector:@selector(timeChange) userInfo:nil repeats:YES];

}

- (void)pauseTimer
{
    __unused __strong typeof(self) strongSelf = self;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(sendRelatedViewShowTrackAtIndex:) object:@(0)];
    [self.timer invalidate];
    self.timer = nil;
}

- (void)timeChange
{
    NSInteger nextPage = self.swipeView.currentPage + 1;
    if (nextPage >= self.entitys.count) {
        nextPage = 0;
    }
    [self.swipeView scrollToPage:nextPage duration:0.3];
}

- (void)setEntitys:(NSMutableArray<TTVPlayerTipRelatedEntity *> *)entitys
{
    [super setEntitys:entitys];
    self.pageControl.numberOfPages = self.entitys.count;
    [_swipeView reloadData];
}

- (void)sendRelatedViewShowTrackAtIndex:(NSNumber *)index
{
    if (index.integerValue < self.entitys.count) {
        TTVPlayerTipRelatedEntity *entity = [self.entitys objectAtIndex:index.integerValue];
        if (!entity.hasSendShowTrack.boolValue) {
            if ([self.delegate respondsToSelector:@selector(relatedViewSendShowTrack:)]) {
                [self.delegate relatedViewSendShowTrack:entity];
                entity.hasSendShowTrack = [NSNumber numberWithBool:YES];
            }
        }
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if ([ttvs_playerFinishedRelatedType() isEqualToString:@"with_icon"]) {
        self.pageControl.frame = CGRectMake(0, self.height - 8, self.width, 4);
    }else if ([ttvs_playerFinishedRelatedType() isEqualToString:@"with_picture"]){
        self.pageControl.frame = CGRectMake(0, self.height - 15, self.width, 4);
    }else if ([ttvs_playerFinishedRelatedType() isEqualToString:@"only_title"]){
        self.pageControl.frame = CGRectMake(0, self.height - 8, self.width, 4);
    }
    [self.pageControl setNeedsDisplay];
    self.swipeView.frame = self.bounds;
}

- (NSInteger)numberOfItemsInSwipeView:(TTVSwipeView *)swipeView
{
    return self.entitys.count;
}

- (CGSize)swipeViewItemSize:(TTVSwipeView *)swipeView
{
    return self.bounds.size;
}

- (UIView *)swipeView:(TTVSwipeView *)swipeView viewForItemAtIndex:(NSInteger)index reusingView:(TTVPlayerTipRelatedIconItem *)view
{
    if (!view) {
        if ([ttvs_playerFinishedRelatedType() isEqualToString:@"with_icon"]) {
            view = [[TTVPlayerTipRelatedAppIconItem alloc] init];
        }else if ([ttvs_playerFinishedRelatedType() isEqualToString:@"with_picture"]){
            view = [[TTVPlayerTipRelatedImageIconItem alloc] init];
        }else if ([ttvs_playerFinishedRelatedType() isEqualToString:@"only_title"]){
            view = [[TTVPlayerTipRelatedSimpleItem alloc] init];
        }
        
        view.delegate = self;
    }
    if ([view isKindOfClass:[TTVPlayerTipRelatedIconItem class]]) {
        if (index <= self.entitys.count - 1) {
            view.entity = [self.entitys objectAtIndex:index];
        }
    }
    return view;
}

- (void)swipeViewCurrentItemIndexDidChange:(TTVSwipeView *)swipeView
{
    if (self.swipeView.currentPage >= 0 && self.swipeView.currentPage <= self.entitys.count - 1) {
        NSInteger index = self.swipeView.currentPage;
        if (index < self.entitys.count) {
            TTVPlayerTipRelatedEntity *entity = [self.entitys objectAtIndex:index];
            if (!entity.hasSendShowTrack.boolValue) {
                if ([self.delegate respondsToSelector:@selector(relatedViewSendShowTrack:)]) {
                    [self.delegate relatedViewSendShowTrack:entity];
                    entity.hasSendShowTrack = [NSNumber numberWithBool:YES];
                }
            }
        }
    }
    self.pageControl.currentPage = self.swipeView.currentPage;
}

- (void)swipeView:(TTVSwipeView *)swipeView didSelectItemAtIndex:(NSInteger)index
{
    if (self.entitys.count > index) {

    }
}

- (void)relatedItemClicked:(TTVPlayerTipRelatedIconItem *)item
{
    [self openDownloadUrl:item.entity];
}
@end

