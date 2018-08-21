//
//  FRIconView.m
//  Article
//
//  Created by 王霖 on 5/26/16.
//
//

#import "FRIconView.h"
#import "TTImageInfosModel.h"
#import "TTRoute.h"
#import "TTImageView.h"
#import "UIViewAdditions.h"
#import "TTThemeImageView.h"
static const CGFloat kIconPadding = 8.f;


@interface FRIconView ()

@property (nonatomic, strong) NSArray <TTImageInfosModel *> * iconModels;
@property (nonatomic, strong) NSMutableArray <TTThemeImageView *> * reuseQueueIconImageViews;
@property (nonatomic, strong) NSMutableArray <TTThemeImageView *> * usingIconImageViews;

@end

@implementation FRIconView

#pragma mark - Life cycle

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self createComponent];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self createComponent];
    }
    return  self;
}

- (void)createComponent {
    self.iconLimitHeight = 1;
    self.iconPadding = kIconPadding;
    self.reuseQueueIconImageViews = [NSMutableArray arrayWithCapacity:6];
    self.usingIconImageViews = [NSMutableArray arrayWithCapacity:6];
}

- (TTThemeImageView *)generateIconImageView {
    TTThemeImageView *iconImageView = [[TTThemeImageView alloc] init];
    iconImageView.hidden = YES;
    iconImageView.imageContentMode = TTImageViewContentModeScaleAspectFill;
    iconImageView.enableNightCover = NO;
    iconImageView.enableAlphaNightCover = NO;
    iconImageView.enableNightView = YES;
    iconImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *logoTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(iconTap:)];
    [iconImageView addGestureRecognizer:logoTap];
    return iconImageView;
}

#pragma mark - Action & Selector

- (void)iconTap:(UITapGestureRecognizer *)tapGestrueRecognizer {
    TTImageView * iconImageView = (TTImageView *)tapGestrueRecognizer.view;
    if ([iconImageView isKindOfClass:[TTImageView class]] && !isEmptyString(iconImageView.model.openURL)) {
        if ([[TTRoute sharedRoute] canOpenURL:[NSURL URLWithString:iconImageView.model.openURL]]) {
            [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:iconImageView.model.openURL]];
        }
    }
}

#pragma mark - Public

- (void)setIconLimitHeight:(CGFloat)iconLimitHeight {
    if (iconLimitHeight <= 0) {
        iconLimitHeight = 1;
    }
    _iconLimitHeight = iconLimitHeight;
}

- (void)refreshWithIconModels:(NSArray <TTImageInfosModel *> *)iconModels {
    self.iconModels = iconModels.copy;
    CGFloat maxHeight = [self getMaxIconHeightOfIconModels:self.iconModels];
    if (maxHeight > self.iconLimitHeight) {
        maxHeight = self.iconLimitHeight;
    }
    
    [self.usingIconImageViews enumerateObjectsUsingBlock:^(TTImageView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.hidden = YES;
    }];
    [self.reuseQueueIconImageViews addObjectsFromArray:self.usingIconImageViews];
    [self.usingIconImageViews removeAllObjects];
    
    [self.iconModels enumerateObjectsUsingBlock:^(TTImageInfosModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (maxHeight == 0) {
            obj.width = 0;
            obj.height = 0;
        }else if (obj.height > maxHeight) {
            obj.width = ceil(obj.width * maxHeight / obj.height);
            obj.height = ceil(maxHeight);
        }
        if (idx < self.reuseQueueIconImageViews.count) {
            TTThemeImageView * iconImageView = self.reuseQueueIconImageViews.firstObject;
            [self.usingIconImageViews addObject:iconImageView];
            [self.reuseQueueIconImageViews removeObjectAtIndex:0];
            [iconImageView setImageWithModel:obj];
        }else {
            TTThemeImageView * iconImageView = [self generateIconImageView];
            [self.usingIconImageViews addObject:iconImageView];
            [iconImageView setImageWithModel:obj];
            [self addSubview:iconImageView];
        }
    }];
    [self invalidateIntrinsicContentSize];
    [self setNeedsLayout];
}

#pragma mark - UI layout

- (void)layoutSubviews {
    [super layoutSubviews];
    __block CGFloat x = 0;
    [self.usingIconImageViews enumerateObjectsUsingBlock:^(TTImageView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (x + obj.model.width <= round(self.width*[UIScreen mainScreen].scale)/[UIScreen mainScreen].scale) {
            obj.size = CGSizeMake(obj.model.width, obj.model.height);
            obj.left = x;
            obj.centerY = self.height/2;
            x += obj.model.width + self.iconPadding;
            obj.hidden = NO;
        }else {
            *stop = YES;
        }
    }];
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGSize resultSize = CGSizeZero;
    CGFloat height = [self getMaxIconHeightOfIconModels:self.iconModels];
    if (height > self.iconLimitHeight) {
        height = self.iconLimitHeight;
    }
    resultSize.height = ceil(height);
    __block CGFloat width = 0;
    [self.iconModels enumerateObjectsUsingBlock:^(TTImageInfosModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        width += (obj.width > 0?obj.width:0);
    }];
    if (self.iconModels.count > 0) {
        width += (self.iconModels.count - 1)*self.iconPadding;
    }
    resultSize.width = ceil(width);
    return resultSize;
}

- (CGSize)intrinsicContentSize {
    CGSize resultSize = [super intrinsicContentSize];
    CGFloat height = [self getMaxIconHeightOfIconModels:self.iconModels];
    if (height > self.iconLimitHeight) {
        height = self.iconLimitHeight;
    }
    resultSize.height = ceil(height > 0?height:resultSize.height);
    __block CGFloat width = 0;
    [self.iconModels enumerateObjectsUsingBlock:^(TTImageInfosModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        width += (obj.width > 0?obj.width:0);
    }];
    if (self.iconModels.count > 0) {
        width += (self.iconModels.count - 1)*self.iconPadding;
    }
    resultSize.width = ceil(width > 0?width:resultSize.width);
    return resultSize;
}

#pragma mark - Utils

- (CGFloat)getMaxIconHeightOfIconModels:(NSArray <TTImageInfosModel *> *)iconModels {
    __block CGFloat maxHeight = 0;
    [iconModels enumerateObjectsUsingBlock:^(TTImageInfosModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.height > maxHeight) {
            maxHeight = obj.height;
        }
    }];
    return maxHeight;
}


@end
