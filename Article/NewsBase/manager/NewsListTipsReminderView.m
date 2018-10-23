//
//  NewsListTipsReminderView.m
//  Article
//
//  Created by chenren on 10/07/2017.
//
//

#import "NewsListTipsReminderView.h"
#import "NewsListLogicManager.h"
#import "SSThemed.h"
#import "TTTrackerWrapper.h"

@interface NewsListTipsReminderView()

@property (nonatomic, assign) NewsListTipsReminderViewType type;
@property (nonatomic, assign) NewsListTipsReminderViewColor color;
@property (nonatomic, assign) BOOL isShowing;
@property (nonatomic, assign) BOOL hasShown;
@property (nonatomic, assign) BOOL reseted;
@property (nonatomic, assign) BOOL refreshed;
@property (nonatomic, assign) BOOL canShow;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) SSThemedImageView *refreshIcon;

@property (nonatomic, assign) NSUInteger showtimes;
@property (nonatomic, strong) NSMutableDictionary *cIDInfoDict;
@property (nonatomic, strong) NSMutableDictionary *cIDBlockDict;

@end

@implementation NewsListTipsReminderView

- (instancetype)initWithFrame:(CGRect)frame andType:(NewsListTipsReminderViewType)type andColor:(NewsListTipsReminderViewColor)color
{
    self = [super initWithFrame:frame];
    if (self) {
        self.type = type;
        self.color = color;
        [self setupViews];
        self.reseted = YES;
        self.refreshed = YES;
        self.showtimes = 0;
        self.cIDInfoDict = [[NSMutableDictionary alloc] init];
        self.cIDBlockDict = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (instancetype)initWithSize:(CGSize)size andType:(NewsListTipsReminderViewType)type andColor:(NewsListTipsReminderViewColor)color
{
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat x = (screenWidth - size.width) / 2.;
    self = [self initWithFrame:CGRectMake(x, -size.height, size.width, size.height) andType:type andColor:color];
    
    return self;
}

- (SSThemedImageView *)refreshIcon
{
    if (!_refreshIcon) {
        _refreshIcon = [[SSThemedImageView alloc] initWithFrame:CGRectZero];
        _refreshIcon.imageName = @"refresh_lasttime_textpage_white";
        [self addSubview:_refreshIcon];
    }
    
    return _refreshIcon;
}

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor whiteColor];
        [self addSubview:_titleLabel];
    }
    
    return _titleLabel;
}

- (void)setupViews
{
    self.titleLabel.text = @"";
    self.titleLabel.frame = CGRectMake(0, 0, self.width, self.height);
    self.titleLabel.font = [UIFont systemFontOfSize:14];
    self.refreshIcon.frame = CGRectMake(150, 9, 14, 14);
    
    BOOL isDay = [[[TTThemeManager sharedInstance_tt] currentThemeName] isEqualToString:@"night"]? NO : YES;
    if (isDay) {
        if (self.color == NewsListTipsReminderViewTypeBlue) {
            self.backgroundColor = [UIColor colorWithHexString:@"2A90D7F4"];
        } else {
            self.backgroundColor = [UIColor colorWithHexString:@"000000CC"];
        }
        self.alpha = 1.0;
        self.titleLabel.textColor = [UIColor colorWithHexString:@"FFFFFF"];
        self.titleLabel.alpha = 1.0;
        _refreshIcon.imageName = @"refresh_lasttime_textpage_white";
    } else {
        self.backgroundColor = [UIColor colorWithHexString:@"67778BE6"];
        self.alpha = 1.0;
        self.titleLabel.textColor = [UIColor colorWithHexString:@"CACACA"];
        self.titleLabel.alpha = 1.0;
        _refreshIcon.imageName = @"refresh_lasttime_textpage_white_night";
    }
    
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(self.bounds.size.height / 2, self.bounds.size.height / 2)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.bounds;
    maskLayer.path = maskPath.CGPath;
    self.layer.mask = maskLayer;
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchAction)];
    [self addGestureRecognizer:tapGestureRecognizer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveShowRemoteReloadTipNotification:) name:kNewsListFetchedRemoteReloadTipNotification object:nil];
    
    [self hide];
}

- (void)themeChanged:(NSNotification *)notification
{
    [super themeChanged:notification];
    BOOL isDay = [[[TTThemeManager sharedInstance_tt] currentThemeName] isEqualToString:@"night"]? NO : YES;
    if (isDay) {
        if (self.color == NewsListTipsReminderViewTypeBlue) {
            self.backgroundColor = [UIColor colorWithHexString:@"2A90D7F4"];
        } else {
            self.backgroundColor = [UIColor colorWithHexString:@"000000CC"];
        }
        self.alpha = 1.0;
        self.titleLabel.textColor = [UIColor colorWithHexString:@"FFFFFF"];
        self.titleLabel.alpha = 1.0;
        _refreshIcon.imageName = @"refresh_lasttime_textpage_white";
    } else {
        self.backgroundColor = [UIColor colorWithHexString:@"67778BE6"];
        self.alpha = 1.0;
        self.titleLabel.textColor = [UIColor colorWithHexString:@"CACACA"];
        self.titleLabel.alpha = 1.0;
        _refreshIcon.imageName = @"refresh_lasttime_textpage_white_night";
    }
}

- (void)setText:(NSString *)text
{
    _text = text;
    self.titleLabel.text = text;
    
    CGSize size=[text sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14]}];
    self.width = 16 + 7 + size.width + 4 + 14 + 7 + 16;
    CGRect originRect = self.frame;
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat x = (screenWidth - self.width) / 2.;
    CGFloat y = originRect.origin.y;
    CGRect rect = CGRectMake(x, y, self.width, originRect.size.height);
    self.frame = rect;
    
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(self.bounds.size.height / 2, self.bounds.size.height / 2)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.bounds;
    maskLayer.path = maskPath.CGPath;
    self.layer.mask = maskLayer;
    
    self.titleLabel.frame = CGRectMake(16 + 7, 0, size.width, self.height);
    self.refreshIcon.frame = CGRectMake(self.titleLabel.frame.origin.x + size.width + 4, 9, 14, 14);
}

- (void)touchAction
{
    [self hide];
    self.refreshed = YES;
    self.canShow = NO;
    [self.cIDInfoDict setValue:nil forKey:_categoryID];
    if (self.delegate && [self.delegate respondsToSelector:@selector(pullAndRefresh)]) {
        [self.delegate pullAndRefresh];
        
    }

    NewsListTipsReminderViewType type = [SSCommonLogic feedTipsShowStrategyType];
    NewsListTipsReminderViewColor color = [SSCommonLogic feedTipsShowStrategyColor];
    NSString *cID = self.categoryID;
    [TTTrackerWrapper eventV3:@"new_style_tips_click" params:@{@"strategy":@(type), @"color":@(color), @"categoryID":cID}];
}

- (void)refreshAndHide
{
    [self hide];
    self.refreshed = YES;
    self.canShow = NO;
    [self.cIDInfoDict setValue:nil forKey:_categoryID];
}

- (void)setCategoryID:(NSString *)categoryID
{
    if (![_categoryID isEqualToString:categoryID] && self.disappearActionBlock) {
        [self.cIDBlockDict setValue:self.disappearActionBlock forKey:_categoryID];
    }
    _categoryID = categoryID;
    if (categoryID.length > 0) {
        NSDictionary *infoDict = [self.cIDInfoDict valueForKey:categoryID];
        if (infoDict) {
            NSUInteger count = [[infoDict objectForKey:@"count"] integerValue];
            NSString *infoStr = [infoDict objectForKey:@"tip"];
            if (!self.isShowing && infoStr.length > 0 && count > 0) {
                self.text = infoStr;
                self.canShow = YES;
                self.hasShown = NO;
                self.refreshed = NO;
                if (self.type == NewsListTipsReminderViewTypeShowOnce || self.type == NewsListTipsReminderViewTypeAuto) {
                    self.reseted = YES;
                }
            } else {
                self.canShow = NO;
            }
        } else {
            self.canShow = NO;
        }
        
        id disappearActionBlock = [self.cIDBlockDict valueForKey:categoryID];
        if (disappearActionBlock) {
            self.disappearActionBlock = disappearActionBlock;
        }
    }
}

- (void)receiveShowRemoteReloadTipNotification:(NSNotification *)notification
{
    NSString * cID = [[notification userInfo] objectForKey:@"categoryID"];
    if (cID && [notification userInfo]) {
        [self.cIDInfoDict setValue:[notification userInfo] forKey:cID];
    }
    
    if (self.enabled && [self.categoryID isEqualToString:cID]) {
        NSUInteger count = [[[notification userInfo] objectForKey:@"count"] integerValue];
        NSString *infoStr = [[notification userInfo] objectForKey:@"tip"];
        
        if (!self.isShowing && infoStr.length > 0 && count > 0) {
            self.text = infoStr;
            self.canShow = YES;
            self.hasShown = NO;
            self.refreshed = NO;
            if (self.type == NewsListTipsReminderViewTypeShowOnce || self.type == NewsListTipsReminderViewTypeAuto) {
                self.reseted = YES;
            }
            
            if (!self.isInBackground) {
                [self show:YES];
                
                NewsListTipsReminderViewType type = [SSCommonLogic feedTipsShowStrategyType];
                NewsListTipsReminderViewColor color = [SSCommonLogic feedTipsShowStrategyColor];
                NSString *cID = self.categoryID;
                [TTTrackerWrapper eventV3:@"new_style_tips_show" params:@{@"strategy":@(type), @"color":@(color), @"categoryID":cID}];
            }
        }
    }
}

- (void)show:(BOOL)isFirstTime
{
    if (!self.canShow) {
        return;
    }
    
    self.showtimes += 1;
    
    NSTimeInterval duration = 0.25;
    if (isFirstTime) {
        duration = 0.65;
    }
    
    if (YES) {
        if (self.type == NewsListTipsReminderViewTypeAuto) {
            if (self.refreshed) {
                return;
            }
            
            [UIView animateWithDuration:duration
                                  delay:0
                 usingSpringWithDamping:0.65
                  initialSpringVelocity:0
                                options:0
                             animations:^{
                                 self.centerY = self.size.height / 2 + 12;
                             }
                             completion:^(BOOL finished) {
                                 if (self.appearActionBlock) {
                                     self.appearActionBlock(YES);
                                 }
                                 self.isShowing = YES;
                             }
             ];
            
            NSUInteger showtimes = self.showtimes;
            
            if (self.reseted) {
                self.reseted = NO;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    if (self.isShowing && showtimes == self.showtimes) {
                        [UIView animateWithDuration: 0.25 animations: ^{
                            self.centerY = -(self.size.height / 2 + 5);
                        } completion:^(BOOL finished) {
                            self.isShowing = NO;
                        }];
                    } else {
                    }
                });
            }
        } else if (self.type == NewsListTipsReminderViewTypeShowOnce) {
            if (!self.hasShown) {
                
                [UIView animateWithDuration:duration
                                      delay:0
                     usingSpringWithDamping:0.65
                      initialSpringVelocity:0
                                    options:0
                                 animations:^{
                                     self.centerY = self.size.height / 2 + 12;
                                 }
                                 completion:^(BOOL finished) {
                                     if (self.appearActionBlock) {
                                         self.appearActionBlock(YES);
                                     }
                                     self.isShowing = YES;
                                 }
                 ];
                
                self.hasShown = YES;
                
                NSUInteger showtimes = self.showtimes;
                
                if (self.reseted) {
                    self.reseted = NO;
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        if (self.isShowing && (showtimes == self.showtimes)) {
                            [UIView animateWithDuration: 0.25 animations: ^{
                                self.centerY = -(self.size.height / 2 + 5);
                            } completion:^(BOOL finished) {
                                if (self.disappearActionBlock) {
                                    self.disappearActionBlock(YES);
                                }
                                self.isShowing = NO;
                            }];
                        } else {
                        }
                    });
                }
            } else {
                if (self.disappearActionBlock) {
                    self.disappearActionBlock(YES);
                }
                self.isShowing = NO;
            }
            
        } else if (self.type == NewsListTipsReminderViewTypeStick) {
            
            [UIView animateWithDuration:duration
                                  delay:0
                 usingSpringWithDamping:0.65
                  initialSpringVelocity:0
                                options:0
                             animations:^{
                                 self.centerY = self.size.height / 2 + 12;
                             }
                             completion:^(BOOL finished) {
                                 if (self.appearActionBlock) {
                                     self.appearActionBlock(YES);
                                 }
                                 self.isShowing = YES;
                             }
             ];
        } else {
        }
    }
}

- (void)disappear
{
    if (self.type == NewsListTipsReminderViewTypeAuto || self.type == NewsListTipsReminderViewTypeShowOnce) {
        if (YES) {
            [UIView animateWithDuration: 0.25 animations: ^{
                self.centerY = -(self.size.height / 2 + 5);
            } completion:^(BOOL finished) {
                if (self.disappearActionBlock) {
                    self.disappearActionBlock(YES);
                }
                self.isShowing = NO;
            }];
        }
    } else if (self.type == NewsListTipsReminderViewTypeStick) {
    } else {
    }
}

- (void)hide
{
    self.isShowing = NO;
    self.centerY = -self.size.height;
    self.reseted = YES;
    self.hasShown = NO;
}

- (void)removeNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dealloc
{
    [self removeNotification];
}

@end
