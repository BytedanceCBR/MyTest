//
//  TTVVideoDetailCommodityViewController.m
//  Article
//
//  Created by panxiang on 2017/10/26.
//

#import "TTVVideoDetailCommodityViewController.h"
#import "KVOController.h"
#import "TTURLUtils.h"
#import "TTRoute.h"
#import "TTVCommodityEntity.h"
#import "TTDeviceHelper.h"
#import "TTVDetailPlayControl.h"
#import "TTVPlayVideo.h"
#import "TTVVideoPlayerStateStore.h"
#import "TTArticleCellHelper.h"
#import "TTSettingsManager.h"
#import "UIImage+YYWebImage.h"
#import <BDWebImage/SDWebImageAdapter.h>
#import "ReactiveObjC.h"
#import "UIView+CustomTimingFunction.h"

@protocol TTVVideoDetailCommodityItemDelegate <NSObject>
- (void)ttv_didOpenCommodityByWeb:(BOOL)isWeb;
@end

@interface TTVVideoDetailCommodityItem : UIView
@property (nonatomic ,strong)TTVCommodityEntity *entity;
@property (nonatomic ,assign)BOOL isFullScreen;
@property (nonatomic ,weak)NSObject <TTVVideoDetailCommodityItemDelegate> *delegate;

@property (nonatomic ,strong)UIButton *background;
@property (nonatomic ,strong)UIImageView *imageView;
@property (nonatomic ,strong)UIView *imageViewBorder;
@property (nonatomic ,strong)UIImageView *recommandIcon;
@property (nonatomic ,strong)UILabel *titleLabel;
@property (nonatomic ,strong)UILabel *priceLabel;
@property (nonatomic ,strong)UILabel *couponLabel;
@property (nonatomic ,strong)UIImageView *redDot;
@property (nonatomic ,assign)BOOL hasShowed;
@property (nonatomic, strong) TTVVideoPlayerStateStore *playerStateStore;
@end

@implementation TTVVideoDetailCommodityItem

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        _background = [UIButton buttonWithType:UIButtonTypeCustom];
        _background.frame = self.bounds;
        _background.backgroundColor = [UIColor clearColor];
        [self addSubview:_background];
        self.backgroundColor = _background.backgroundColor;
        [_background addTarget:self action:@selector(openCommodity) forControlEvents:UIControlEventTouchUpInside];
        
        _redDot = [[UIImageView alloc] init];
        _redDot.frame = CGRectMake(0, 0, 4, 4);
        _redDot.layer.cornerRadius = _redDot.width / 2;
        _redDot.layer.masksToBounds = YES;
        _redDot.backgroundColor = [UIColor colorWithRed:248.0f/255.0f green:89.0f/255.0f blue:89.0f/255.0f alpha:1];
        _redDot.hidden = YES;
        [self addSubview:_redDot];
        
        _imageViewBorder = [[UIView alloc] init];
        _imageViewBorder.backgroundColor = [UIColor whiteColor];
        [_background addSubview:_imageViewBorder];
        
        _imageView = [[UIImageView alloc] init];
        _imageView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground5];
        _imageView.userInteractionEnabled = NO;
        [_background addSubview:_imageView];
        
        NSDictionary *dic = [[TTSettingsManager sharedManager] settingForKey:@"tt_video_commodity" defaultValue:@{} freeze:NO];
        BOOL isVideoCommodityRecommandClose = [[dic valueForKey:@"video_commodity_author_recommand_icon_hidden"] boolValue];
        if (!isVideoCommodityRecommandClose) {
            _recommandIcon = [[UIImageView alloc] init];
            _recommandIcon.backgroundColor = [UIColor clearColor];

            NSString *imageUrl = [dic valueForKey:@"author_recommend_icon"];
            if (!isEmptyString(imageUrl)) {
                [_recommandIcon sda_setImageWithURL:[NSURL URLWithString:imageUrl]];
            }else{
                _recommandIcon.image = [UIImage imageNamed:@"video_commodity_recommand.png"];
            }
            [_imageView addSubview:_recommandIcon];
        }
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = [UIFont tt_fontOfSize:[TTDeviceUIUtils tt_newFontSize:[TTDeviceUIUtils tt_newFontSize:14]]];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.numberOfLines = 1;
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [_background addSubview:_titleLabel];
        
        _priceLabel = [[UILabel alloc] init];
        _priceLabel.backgroundColor = [UIColor clearColor];
        _priceLabel.font = [UIFont tt_fontOfSize:[TTDeviceUIUtils tt_newFontSize:[TTDeviceUIUtils tt_newFontSize:16]]];
        _priceLabel.textColor = [UIColor colorWithHexString:@"f85959"];
        _priceLabel.textAlignment = NSTextAlignmentLeft;
        _priceLabel.numberOfLines = 1;
        [_background addSubview:_priceLabel];
        
        _couponLabel = [[UILabel alloc] init];
        _couponLabel.backgroundColor = [UIColor clearColor];
        _couponLabel.font = [UIFont tt_fontOfSize:[TTDeviceUIUtils tt_newFontSize:10]];
        _couponLabel.textColor = [UIColor colorWithHexString:@"f85959"];
        _couponLabel.textAlignment = NSTextAlignmentLeft;
        _couponLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _couponLabel.numberOfLines = 2;
        [_background addSubview:_couponLabel];
        @weakify(self);
        [self.KVOController observe:self.redDot keyPath:@keypath(self.redDot,hidden) options:NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
            @strongify(self);
            [UIView animateWithDuration:0.25 animations:^{
                if (self.redDot.hidden) {
                    _imageViewBorder.alpha = 0;
                }else{
                    _imageViewBorder.alpha = 1;
                }
            }];
        }];
    }
    return self;
}

- (void)reSetPriceLabelIfNeed
{
    if (self.entity.coupon_type && self.entity.coupon_num) {
        self.couponLabel.text = @"券后价¥ ";
        [self.couponLabel sizeToFit];
        if (self.entity.coupon_type == 1) {
            _priceLabel.text = [NSString stringWithFormat:@"%.2f",(self.entity.price - self.entity.coupon_num) / 100.f];
        }else if (self.entity.coupon_type == 2){
            _priceLabel.text = [NSString stringWithFormat:@"%.2f",self.entity.price * self.entity.coupon_num / 1000.f];
        }
    }
}

- (void)setEntity:(TTVCommodityEntity *)entity
{
    _entity = entity;
    _priceLabel.text = [NSString stringWithFormat:@"¥ %.2f",entity.price / 100.f];
    _titleLabel.text = [NSString stringWithFormat:@"%@",entity.title];
    [self reSetPriceLabelIfNeed];

    self.hidden = NO;
    if (!isEmptyString(entity.image_url)) {
        [_imageView sda_setImageWithURL:[NSURL URLWithString:entity.image_url]];
    }else{
        _imageView.image = nil;
    }
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _background.frame = CGRectMake(15, 0, self.width - 15, self.height);
    _redDot.frame = CGRectMake(6, (self.height - _redDot.height) / 2.0, _redDot.width, _redDot.height);
    _imageViewBorder.frame = CGRectMake(-2, -2, self.height + 4, self.height + 4);
    _imageView.frame = CGRectMake(0, 0, self.height, self.height);
    _recommandIcon.frame =_imageView.bounds;
    [_titleLabel sizeToFit];
    _titleLabel.frame = CGRectMake(_imageView.right + [TTDeviceUIUtils tt_newPadding:8], [TTDeviceUIUtils tt_newPadding:1], self.width - _imageView.right - [TTDeviceUIUtils tt_newPadding:8] - 70, _titleLabel.height);
    if (self.entity.coupon_type && self.entity.coupon_num) {
        NSInteger height = 12;
        self.couponLabel.frame = CGRectMake(_titleLabel.origin.x, self.height - _titleLabel.top - height, _couponLabel.width, height);
        [_priceLabel sizeToFit];
        height = 14;
        _priceLabel.frame = CGRectMake(self.couponLabel.right + [TTDeviceUIUtils tt_newPadding:2], self.height - _titleLabel.top - 14, _background.width - _imageView.right - [TTDeviceUIUtils tt_newPadding:5 * 2] - self.couponLabel.width, height);
    }else{
        [_priceLabel sizeToFit];
        _priceLabel.frame = CGRectMake(_titleLabel.origin.x, _titleLabel.bottom + 2, _background.width - _imageView.right - [TTDeviceUIUtils tt_newPadding:4 * 2], _priceLabel.height);
    }
}

- (NSMutableDictionary *)commonDic
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:@"detail_bar" forKey:@"section"];
    [dic setValue:@"detail" forKey:@"position"];
    [dic setValue:self.playerStateStore.state.isFullScreen ? @"fullscreen" : @"nofullscreen" forKey:@"fullscreen"];
    if (self.playerStateStore.state.playerModel.itemID) {
        [dic setValue:self.playerStateStore.state.playerModel.itemID forKey:@"item_id"];
    }
    if (self.playerStateStore.state.playerModel.groupID) {
        [dic setValue:self.playerStateStore.state.playerModel.groupID forKey:@"group_id"];
    }
    [dic setValue:@"TEMAI" forKey:@"EVENT_ORIGIN_FEATURE"];
    
    NSMutableDictionary *commodity_attr = [NSMutableDictionary dictionary];
    [commodity_attr setValue:@([self.playerStateStore.state.commodityEngitys indexOfObject:self.entity] + 1) forKey:@"commodity_no"];
    [commodity_attr setValue:@(self.playerStateStore.state.commodityEngitys.count) forKey:@"commodity_num"];
    [commodity_attr setValue:self.entity.commodity_id forKey:@"commodity_id"];
    [dic setValue:commodity_attr forKey:@"commodity_attr"];
    
    return dic;
}

- (void)ttv_clickCommodityTrack
{
    [TTTrackerWrapper eventV3:@"commodity_click" params:[self commonDic]];
}

- (void)ttv_showCommodityTrack
{
    [TTTrackerWrapper eventV3:@"commodity_show" params:[self commonDic]];
}

- (void)show
{
    if (!self.hasShowed) {
        [self ttv_showCommodityTrack];
        self.hasShowed = YES;
    }
}

- (void)openCommodity
{
    BOOL isHandled = NO;
    BOOL isWeb = NO;
    if (!isHandled && !isEmptyString(self.entity.charge_url)) { // SDK 不能处理的，使用内置浏览器打开
        NSURL *url = [TTURLUtils URLWithString:@"sslocal://webview" queryItems:@{@"url" : self.entity.charge_url}];
        if ([[TTRoute sharedRoute] canOpenURL:url]) {
            [[TTRoute sharedRoute] openURLByPushViewController:url];
            isHandled = YES;
            isWeb = YES;
        }
    }
    if (isHandled) {
        if ([self.delegate respondsToSelector:@selector(ttv_didOpenCommodityByWeb:)]) {
            [self.delegate ttv_didOpenCommodityByWeb:isWeb];
            [self ttv_clickCommodityTrack];
        }
    }
}

@end

@interface TTVVideoDetailArrowButton : UIView
@property (nonatomic ,strong)UILabel *numberLabel;
@property (nonatomic ,strong)UIButton *button;
@property (nonatomic ,strong)UIImage *arrowImage;
@property (nonatomic ,strong)UIImage *downArrowImage;
@property (nonatomic ,strong)UIImageView *arrow;
@end;

@implementation TTVVideoDetailArrowButton
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:_button];
        
        _numberLabel = [[UILabel alloc] init];
        _numberLabel.numberOfLines = 1;
        _numberLabel.font = [UIFont tt_fontOfSize:14];
        _numberLabel.backgroundColor = [UIColor clearColor];
        _numberLabel.textColor = [UIColor whiteColor];
        [self addSubview:_numberLabel];
        self.arrowImage = [UIImage imageNamed:@"video_commodity_triangle.png"];
        self.downArrowImage = [self.arrowImage yy_imageByRotate180];
        _arrow = [[UIImageView alloc] init];
        _arrow.image = self.downArrowImage;
        _arrow.contentMode = UIViewContentModeCenter;
        _arrow.backgroundColor = [UIColor clearColor];
        [_arrow sizeToFit];
        [self addSubview:_arrow];
        
    }
    return self;
}

- (UIImage *)downArrow
{
    UIGraphicsBeginImageContextWithOptions(self.arrowImage.size, NO, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect area = CGRectMake(0, 0, self.arrowImage.size.width, self.arrowImage.size.height);
    CGContextRotateCTM(context, M_PI);
    CGContextTranslateCTM(context, -self.arrowImage.size.width, -self.arrowImage.size.height);
    CGContextDrawImage(context, area, self.arrowImage.CGImage);
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (void)setTitle:(NSString *)title
{
    if (!isEmptyString(title)) {
        self.numberLabel.text = title;
        [self setNeedsLayout];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.button.frame = self.bounds;
    self.arrow.frame = CGRectMake(self.width - self.arrow.width, (self.height - self.arrow.height) / 2.0, self.arrow.width, self.arrow.height);
    [self.numberLabel sizeToFit];
    self.numberLabel.frame = CGRectMake(self.arrow.left - self.numberLabel.width - 7, (self.height - self.numberLabel.height) / 2.0, self.numberLabel.width, self.numberLabel.height);

}

- (void)setIsFlod:(BOOL)isFlod
{
    if (isFlod) {
        [_arrow setImage:self.downArrowImage];
    }else{
        [_arrow setImage:self.arrowImage];
    }
}
@end


@interface TTVVideoDetailCommodityViewController ()<TTVVideoDetailCommodityItemDelegate>
@property (nonatomic ,strong)NSMutableArray *itemViews;
@property (nonatomic ,strong)TTVVideoDetailArrowButton *arrowButton;
@property (nonatomic ,assign)BOOL isFlod;
@property (nonatomic ,strong)TTVCommodityEntity *currentCommodityEntity;
@property (nonatomic ,strong)TTVDetailPlayControl *playControl;
@property (nonatomic ,strong)UIView *contentView;
@property (nonatomic ,assign)NSInteger itemViewHeight;
@property (nonatomic ,assign)NSInteger itemViewTopSpace;
@property (nonatomic ,assign)BOOL isChangingAnimation;//flod下正在动画切换下一个
@property (nonatomic ,assign)BOOL isFlodAnimation;//展开动画

@end

@implementation TTVVideoDetailCommodityViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.itemViewTopSpace = 10;
        self.itemViewHeight = 38 * ([UIScreen mainScreen].bounds.size.width / 320.0);
        _itemViews = [NSMutableArray array];
    }
    return self;
}

- (void)setPgcHeight:(CGFloat)pgcHeight
{
    _pgcHeight = pgcHeight;
    [self layoutSubviews];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _contentView = [[UIView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_contentView];
    self.view.clipsToBounds = YES;
    self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.87];
    [self ttv_kvo];
    _arrowButton = [[TTVVideoDetailArrowButton alloc] init];
    [_arrowButton.button addTarget:self action:@selector(unflodAction) forControlEvents:UIControlEventTouchUpInside];
    self.isFlod = YES;
    [self.arrowButton setIsFlod:self.isFlod];
    // Do any additional setup after loading the view.
}

- (void)unflodAction
{
    if (self.isChangingAnimation) {
        self.isFlodAnimation = YES;
    }else{
        [self doneUnflodAction];
    }
}

- (void)doneUnflodAction
{
    self.isFlod = !self.isFlod;
    [self.arrowButton setIsFlod:self.isFlod];
    NSInteger topSpace = self.itemViewTopSpace;
    if (!self.isFlod) {
        for (TTVVideoDetailCommodityItem *item in self.itemViews) {
            [item show];
        }
    }
    [UIView animateWithDuration:0.26 customTimingFunction:CustomTimingFunctionCubicOut animation:^{
        if (self.isFlod) {
            TTVVideoDetailCommodityItem *firstItemView = self.itemViews.firstObject;
            self.view.frame = CGRectMake(0, 0, self.view.superview.width, firstItemView.bottom + topSpace + self.pgcHeight);
        }else{
            NSInteger index = 0;
            for (TTVVideoDetailCommodityItem *itemView in self.itemViews) {
                if (index == self.itemViews.count - 1) {
                    self.view.frame = CGRectMake(0, 0, self.view.superview.width, itemView.bottom + 2 * topSpace + self.pgcHeight);
                }
                index++;
            }
        }
    }];
//    [self layoutSubviews];
    self.isFlodAnimation = NO;
}

- (void)setWhiteboard:(TTVWhiteBoard *)whiteboard
{
    self.playControl = [whiteboard valueForKey:@"playControl"];
    [self.playControl.movieView.player registerPart:self];
}


- (void)dealloc
{
    [self.playerStateStore unregisterForActionClass:[TTVPlayerStateAction class] observer:self];
}

- (void)setPlayerStateStore:(TTVVideoPlayerStateStore *)playerStateStore
{
    if (_playerStateStore != playerStateStore) {
        [self.playerStateStore unregisterForActionClass:[TTVPlayerStateAction class] observer:self];
        [self.KVOController unobserve:self.playerStateStore.state];
        _playerStateStore = playerStateStore;
        [self ttv_kvo];
        [self.playerStateStore registerForActionClass:[TTVPlayerStateAction class] observer:self];
        [self refreshView];
    }
}

- (void)actionChangeCallbackWithAction:(TTVPlayerStateAction *)action state:(TTVPlayerStateModel *)state
{
    if ([action isKindOfClass:[TTVPlayerStateAction class]] && ([state isKindOfClass:[TTVPlayerStateModel class]] || state == nil)) {
        switch (action.actionType) {
            case TTVPlayerEventTypePlayerStop:
                break;
            default:
                break;
        }
    }
}

- (void)ttv_kvo
{
    @weakify(self);
    [self.KVOController observe:self.playerStateStore.state keyPath:@keypath(self.playerStateStore.state,currentPlaybackTime) options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        @strongify(self);
        if (!self.currentCommodityEntity) {
            self.currentCommodityEntity = self.playerStateStore.state.commodityEngitys.firstObject;
        }
        NSInteger index = -1;
        for (NSNumber *number in self.playerStateStore.state.insertTimes) {
            if (self.playerStateStore.state.currentPlaybackTime > number.floatValue) {
                index++;
            }
        }
        if (index <= 0) {
            index = 0;
        }
        if (index >= 0 && index <= self.playerStateStore.state.insertTimes.count - 1) {
            TTVCommodityEntity *entity = [self.playerStateStore.state.commodityEngitys objectAtIndex:index];
            if (self.currentCommodityEntity != entity) {
                self.currentCommodityEntity = entity;
                
                if (self.isFlod && !self.isFlodAnimation) {
                    CGRect frame = self.view.bounds;
                    self.isChangingAnimation = YES;
                    
                    [self.arrowButton setTitle:[NSString stringWithFormat:@"%ld/%ld", index+1, self.playerStateStore.state.commodityEngitys.count]];
                    [UIView animateWithDuration:0.5 customTimingFunction:CustomTimingFunctionExpoOut animation:^{
                        self.contentView.frame = CGRectOffset(frame, 0, - index * (self.itemViewTopSpace * 2 + self.itemViewHeight));
                    } completion:^(BOOL finished) {
                        if (self.isFlodAnimation) {
                            [self doneUnflodAction];
                        }
                        if (!self.isFlod) {
                            self.contentView.frame = frame;
                        }
                        self.isChangingAnimation = NO;
                    }];
                }else{
                    [self layoutSubviews];
                }

            }
            
        }
    }];
    
    [self.KVOController observe:self.playerStateStore.state keyPath:@keypath(self.playerStateStore.state,commodityEngitys) options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        @strongify(self);
        self.currentCommodityEntity = self.playerStateStore.state.commodityEngitys.firstObject;
        [self refreshView];
    }];
    
}

- (void)setCurrentCommodityEntity:(TTVCommodityEntity *)currentCommodityEntity
{
    if (currentCommodityEntity != _currentCommodityEntity) {
        _currentCommodityEntity = currentCommodityEntity;
        for (TTVVideoDetailCommodityItem *item in self.itemViews) {
            if (item.entity == currentCommodityEntity) {
                [item show];
            }
        }
    }
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self layoutSubviews];
}

- (void)layoutSubviews
{
    NSInteger index = 0;
    NSInteger height = self.itemViewHeight;
    NSInteger topSpace = self.itemViewTopSpace;

    for (TTVVideoDetailCommodityItem *itemView in self.itemViews) {
        itemView.frame = CGRectMake(0, index * itemView.height + index * 2 * topSpace + topSpace, self.view.width - 20, height);
        if (self.isFlod) {
            itemView.redDot.hidden = YES;
            if (index == 0) {
                itemView.hidden = NO;
                TTVVideoDetailCommodityItem *firstItemView = itemView;
                self.view.frame = CGRectMake(0, 0, self.view.superview.width, firstItemView.bottom + topSpace + self.pgcHeight);
            }
        }else{
            itemView.hidden = NO;
            itemView.redDot.hidden = index != [self.playerStateStore.state.commodityEngitys indexOfObject:self.currentCommodityEntity];
            if (index == self.itemViews.count - 1) {
                TTVVideoDetailCommodityItem *lastItemView = itemView;
                self.view.frame = CGRectMake(0, 0, self.view.superview.width, lastItemView.bottom + 2 * topSpace + self.pgcHeight);
            }
        }
        index++;
    }
    _arrowButton.hidden = self.playerStateStore.state.commodityEngitys.count <= 1;
    [_arrowButton setTitle:[NSString stringWithFormat:@"%ld/%ld",[self.playerStateStore.state.commodityEngitys indexOfObject:self.currentCommodityEntity] + 1,self.playerStateStore.state.commodityEngitys.count]];
    TTVVideoDetailCommodityItem *firstItemView = [self.itemViews firstObject];
    _arrowButton.frame = CGRectMake(self.view.width - 80, (firstItemView.height - 40) / 2.0 + firstItemView.top, 60, 40);
    if (self.isFlod) {
        CGRect frame = self.view.bounds;
        NSInteger currentIndex = 0;
        if (self.currentCommodityEntity) {
            currentIndex = [self.playerStateStore.state.commodityEngitys indexOfObject:self.currentCommodityEntity];
        }
        self.contentView.frame = CGRectOffset(frame, 0, - currentIndex * (self.itemViewTopSpace * 2 + self.itemViewHeight));
    }else{
        self.contentView.frame = self.view.bounds;
    }
}

- (void)refreshView
{
    for (UIView *view in self.itemViews) {
        [view removeFromSuperview];
    }
    [self.itemViews removeAllObjects];
    for (TTVCommodityEntity *entity in self.playerStateStore.state.commodityEngitys) {
        TTVVideoDetailCommodityItem *itemView = [[TTVVideoDetailCommodityItem alloc] initWithFrame:CGRectZero];
        itemView.delegate = self;
        itemView.playerStateStore = self.playerStateStore;
        [itemView setEntity:entity];
        [self.itemViews addObject:itemView];
        [self.contentView addSubview:itemView];
    }
    [self.view addSubview:_arrowButton];
    [_arrowButton setTitle:[NSString stringWithFormat:@"%d/%ld",1,self.playerStateStore.state.commodityEngitys.count]];
    self.currentCommodityEntity = self.playerStateStore.state.commodityEngitys.firstObject;
    [self layoutSubviews];
}

- (void)ttv_didOpenCommodityByWeb:(BOOL)isWeb
{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
