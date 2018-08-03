//
//  TTRedPacketViewWrapper.m
//  Article
//
//  Created by lipeilun on 2017/7/11.
//
//

#import "TTRedPacketViewWrapper.h"
#import "TTRedPacketViewController.h"
#import "TTNavigationController.h"
#import <ExploreAvatarView.h>
#import <ExploreAvatarView+VerifyIcon.h>
#import "FRApiModel.h"
#import "TTIndicatorView.h"
#import <TTAccountManager.h>
#import "TTRedPacketManager.h"
#import <TTThemeManager.h>

@interface TTRedPacketViewWrapper ()
@property (nonatomic, assign) TTRedPacketViewStyle style;
//@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, strong) CAShapeLayer *redPacketHeader;
@property (nonatomic, strong) CAGradientLayer *gradientHeader;
@property (nonatomic, strong) CAShapeLayer *redPacketBottom;
@property (nonatomic, strong) CAShapeLayer *shadowLayer;
@property (nonatomic, strong, readwrite) SSThemedButton *openButton;
@property (nonatomic, strong) ExploreAvatarView *avatarImageView;
@property (nonatomic, strong) SSThemedImageView *coinsImageView;
@property (nonatomic, strong) SSThemedLabel *nameLabel;
@property (nonatomic, strong) SSThemedLabel *descriptionLabel;
@property (nonatomic, strong) SSThemedLabel *followMeLabel;
@property (nonatomic, strong) FRRedpackStructModel *redpacket;
@property (nonatomic, strong) SSThemedButton *redPacketRuleButton;
@property (nonatomic, strong) SSThemedImageView *arrowImageView;
@property (nonatomic, strong) TTRedPacketTrackModel *trackModel;
@property (nonatomic, copy) NSString *source;
@property (nonatomic, strong) SSThemedButton *closeRedPacketButton;
@property (nonatomic, strong) NSString *ruleScheme;
@property (nonatomic, assign) CGRect redPacketFrame;
@end

@implementation TTRedPacketViewWrapper

- (instancetype)initWithFrame:(CGRect)frame
                        style:(TTRedPacketViewStyle)style
                    redpacket:(FRRedpackStructModel *)redpacket {
    if (self = [super initWithFrame:frame]) {
        self.redpacket = redpacket;
        self.style = style;
        [self setupComponents];
    }
    return self;
}

#pragma mark - UIsetup


- (void)setupComponents {
    [self setupBackgroundView];
    [self setupRedPacket];
    [self setupOpenButton];
    [self setupAvatarImageView];
    [self setupRedPacketTextViews];
}


- (void)setupBackgroundView {
    self.backgroundView = [[SSThemedView alloc] initWithFrame:self.bounds];
    if (self.style == TTRedPacketViewStyleOpening) {
        self.backgroundView.backgroundColor = [UIColor clearColor];
        self.backgroundView.alpha = 1;
    } else {
        self.backgroundView.backgroundColor = [UIColor blackColor];
        self.backgroundView.alpha = 0.4;
    }
    [self addSubview:self.backgroundView];
    
    self.containerView = [[SSThemedView alloc] initWithFrame:self.bounds];
    self.containerView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.containerView];
}


- (void)setupRedPacket {
    //注意4s适配
    CGFloat verticalPadding = ([[UIScreen mainScreen] bounds].size.height - [TTDeviceUIUtils tt_newPadding:410]) / 2;
    CGFloat horizonalPadding = ([[UIScreen mainScreen] bounds].size.width - [TTDeviceUIUtils tt_newPadding:300]) / 2;
    self.redPacketFrame = CGRectMake(horizonalPadding, verticalPadding, [TTDeviceUIUtils tt_newPadding:300], [TTDeviceUIUtils tt_newPadding:410]);
    [self drawRedPacket];
}

- (void)drawRedPacket {
    CGFloat frameX = self.redPacketFrame.origin.x;
    CGFloat frameY = self.redPacketFrame.origin.y;
    CGFloat frameWidth = self.redPacketFrame.size.width;
    CGFloat frameHeight = self.redPacketFrame.size.height;
    _redPacketBottom = [CAShapeLayer layer];
    CGFloat headerX = frameX - 0.5;
    CGFloat headerWidth = frameWidth + 1;
    UIBezierPath *pathbottom = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(headerX, frameY + [TTDeviceUIUtils tt_newPadding:270], headerWidth, frameHeight - [TTDeviceUIUtils tt_newPadding:270])
                                                     byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight
                                                           cornerRadii:CGSizeMake(8, 8)];
    [pathbottom moveToPoint:CGPointMake(headerX, frameY + [TTDeviceUIUtils tt_newPadding:270])];
    [pathbottom addQuadCurveToPoint:CGPointMake(headerX + headerWidth, frameY + [TTDeviceUIUtils tt_newPadding:270])
                       controlPoint:CGPointMake(headerX + headerWidth / 2, frameY + [TTDeviceUIUtils tt_newPadding:300])];
    _redPacketBottom.path = pathbottom.CGPath;
    _redPacketBottom.zPosition = 1;
    [_redPacketBottom setFillColor:[UIColor colorWithHexString:@"E13D35"].CGColor];
    if (self.style != TTRedPacketViewStyleOpening) {
        [self.containerView.layer addSublayer:_redPacketBottom];
    }
    
    _redPacketHeader = [CAShapeLayer layer];
    _redPacketHeader.strokeColor = [UIColor redColor].CGColor;
    UIBezierPath *pathheader = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(frameX, frameY, frameWidth, [TTDeviceUIUtils tt_newPadding:272])
                                                     byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight
                                                           cornerRadii:CGSizeMake(8, 8)];
    [pathheader moveToPoint:CGPointMake(frameX, frameY + [TTDeviceUIUtils tt_newPadding:272])];
    [pathheader addQuadCurveToPoint:CGPointMake(frameX + frameWidth, frameY + [TTDeviceUIUtils tt_newPadding:272])
                       controlPoint:CGPointMake(frameX + frameWidth / 2, frameY + [TTDeviceUIUtils tt_newPadding:330])];
    _redPacketHeader.path = pathheader.CGPath;
    if (self.style == TTRedPacketViewStyleOpening) {
        _redPacketHeader.path = [self headerExpandedPath];
    }
    
    _shadowLayer = [CAShapeLayer layer];
    _shadowLayer.backgroundColor = [UIColor clearColor].CGColor;
    _shadowLayer.path = pathheader.CGPath;
    _shadowLayer.zPosition = 2.2;
    _shadowLayer.borderWidth = 0;
    [_shadowLayer setShadowColor:[UIColor blackColor].CGColor];
    [_shadowLayer setShadowOffset:CGSizeMake(0, 1)];
    [_shadowLayer setShadowOpacity:0.07];
    [_shadowLayer setShadowRadius:8];
    
    _gradientHeader = [CAGradientLayer layer];
    [_gradientHeader setColors:@[(id)[UIColor colorWithHexString:@"F88981"].CGColor,
                                 (id)[UIColor colorWithHexString:@"F36962"].CGColor,
                                 (id)[UIColor colorWithHexString:@"EF514A"].CGColor]];
    [_gradientHeader setLocations:@[@(0), @(0.1), @(0.4)]];
    [_gradientHeader setStartPoint:CGPointMake(frameX / [[UIScreen mainScreen] bounds].size.width, frameY / (frameY + [TTDeviceUIUtils tt_newPadding:342]))];
    [_gradientHeader setEndPoint:CGPointMake((frameX + frameWidth) / [[UIScreen mainScreen] bounds].size.width, 1)];
    [_gradientHeader setMask:_redPacketHeader];
    _gradientHeader.frame = CGRectMake(0, 0, self.width, frameY + [TTDeviceUIUtils tt_newPadding:342]);
    _gradientHeader.borderWidth = 0;
    _gradientHeader.zPosition = 2.5;
    [self.containerView.layer addSublayer:_shadowLayer];
    [self.containerView.layer addSublayer:_gradientHeader];
}

- (void)setupOpenButton {
    CGFloat frameX = self.redPacketFrame.origin.x;
    CGFloat frameWidth = self.redPacketFrame.size.width;

    if (_style == TTRedPacketViewStyleOpening) {
        return;
    }
    self.openButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
    self.openButton.frame = CGRectMake(self.redPacketFrame.origin.x + [TTDeviceUIUtils tt_newPadding:100], self.redPacketFrame.origin.y + [TTDeviceUIUtils tt_newPadding:246], [TTDeviceUIUtils tt_newPadding:100], [TTDeviceUIUtils tt_newPadding:100]);
    self.openButton.layer.zPosition = 3;
    self.openButton.layer.cornerRadius = [TTDeviceUIUtils tt_newPadding:50];
    self.openButton.clipsToBounds = YES;
    [self.openButton setImage:[UIImage imageNamed:@"open_redpacket"] forState:UIControlStateNormal];
    [self.openButton setImage:[UIImage imageNamed:@"open_redpacket"] forState:UIControlStateHighlighted];
    [self.openButton addTarget:self action:@selector(openPacketAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.containerView addSubview:self.openButton];
    
    self.coinsImageView = [[SSThemedImageView alloc] initWithFrame:self.openButton.frame];
    self.coinsImageView.layer.cornerRadius = [TTDeviceUIUtils tt_newPadding:50];
    self.coinsImageView.layer.zPosition = 4;
    self.coinsImageView.clipsToBounds = YES;
    self.coinsImageView.hidden = YES;
    NSMutableArray *pics = [NSMutableArray array];
    for (NSInteger count = 0; count <= 20; count++) {
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"coins_fall_%ld", count]];
        [pics addObject:image];
    }
    self.coinsImageView.image = [UIImage imageNamed:@"coins_fall_20"];
    self.coinsImageView.animationImages = [pics copy];
    self.coinsImageView.animationDuration = 0.4;
    [self.containerView addSubview:self.coinsImageView];
    
    
    self.redPacketRuleButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
    self.redPacketRuleButton.hidden = YES;
    self.redPacketRuleButton.titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:12]];
    [self.redPacketRuleButton setTitleColor:[UIColor colorWithHexString:@"#FFF3BC"] forState:UIControlStateNormal];
    self.redPacketRuleButton.frame = CGRectMake((self.width - [TTDeviceUIUtils tt_newPadding:60]) / 2, self.redPacketFrame.size.height + self.redPacketFrame.origin.y - [TTDeviceUIUtils tt_newPadding:27], [TTDeviceUIUtils tt_newPadding:48], [TTDeviceUIUtils tt_newPadding:17]);
    self.redPacketRuleButton.layer.zPosition = 3;
    [self.redPacketRuleButton addTarget:self action:@selector(redPacketRuleAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.containerView addSubview:self.redPacketRuleButton];

    self.arrowImageView = [[SSThemedImageView alloc] initWithFrame:CGRectMake(self.redPacketRuleButton.right + [TTDeviceUIUtils tt_newPadding:4], 0, [TTDeviceUIUtils tt_newPadding:8], [TTDeviceUIUtils tt_newPadding:14])];
    self.arrowImageView.hidden = YES;
    self.arrowImageView.layer.zPosition = 3;
    self.arrowImageView.centerY = self.redPacketRuleButton.centerY;
    self.arrowImageView.imageName = @"ask_arrow_right";
    [self.containerView addSubview:self.arrowImageView];
    
    self.closeRedPacketButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
    self.closeRedPacketButton.frame = CGRectMake(frameX + frameWidth - [TTDeviceUIUtils tt_newPadding:26], self.redPacketFrame.origin.y + [TTDeviceUIUtils tt_newPadding:10], [TTDeviceUIUtils tt_newPadding:16], [TTDeviceUIUtils tt_newPadding:16]);
    self.closeRedPacketButton.hitTestEdgeInsets = UIEdgeInsetsMake(-[TTDeviceUIUtils tt_newPadding:28], -[TTDeviceUIUtils tt_newPadding:28], -[TTDeviceUIUtils tt_newPadding:28], -[TTDeviceUIUtils tt_newPadding:28]);
    self.closeRedPacketButton.layer.zPosition = 3;
    self.closeRedPacketButton.clipsToBounds = YES;
    [self.closeRedPacketButton setImage:[UIImage imageNamed:@"close_redpacket"] forState:UIControlStateNormal];
    [self.closeRedPacketButton setImage:[UIImage imageNamed:@"close_redpacket"] forState:UIControlStateHighlighted];
    [self.closeRedPacketButton addTarget:self action:@selector(closeRedPacketAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.containerView addSubview:self.closeRedPacketButton];
}

- (void)setupAvatarImageView {
    CGRect rect = CGRectMake(self.width / 2 - [TTDeviceUIUtils tt_newPadding:33], self.redPacketFrame.origin.y + [TTDeviceUIUtils tt_newPadding:30], [TTDeviceUIUtils tt_newPadding:66], [TTDeviceUIUtils tt_newPadding:66]);
    if (self.style == TTRedPacketViewStyleOpening) {
        rect.origin.y = [TTDeviceUIUtils tt_newPadding:100];
    }
    self.avatarImageView = [[ExploreAvatarView alloc] initWithFrame:rect];
    self.avatarImageView.enableRoundedCorner = YES;
    self.avatarImageView.highlightedMaskView = nil;
    self.avatarImageView.imageView.layer.borderWidth = 0;
    self.avatarImageView.placeholder = @"default_avatar";
    self.avatarImageView.imageView.imageContentMode = TTImageViewContentModeScaleAspectFill;
    self.avatarImageView.layer.zPosition = 3;
    self.avatarImageView.disableNightMode = YES;
    self.avatarImageView.verifyView.disableNightMode = YES;
    [self.avatarImageView setImageWithURLString:self.redpacket.user_info.avatar_url];
    UIView *coverView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [TTDeviceUIUtils tt_newPadding:66], [TTDeviceUIUtils tt_newPadding:66])];
    coverView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.05];
    coverView.layer.cornerRadius = [TTDeviceUIUtils tt_newPadding:33];
    coverView.layer.masksToBounds = YES;
    coverView.userInteractionEnabled = NO;
    coverView.layer.borderColor = [SSGetThemedColorWithKey(kColorLine1) CGColor];
    [self.avatarImageView addSubview:coverView];
    [self.avatarImageView setupVerifyViewForLength:[TTDeviceUIUtils tt_newPadding:66]
                               adaptationSizeBlock:^CGSize(CGSize standardSize) {
                                   return CGSizeMake(14, 14);
                               }
                             adaptationOffsetBlock:nil];
    [self.avatarImageView showOrHideVerifyViewWithVerifyInfo:self.redpacket.user_info.user_auth_info decoratorInfo:nil sureQueryWithID:YES userID:nil];

    [self.avatarImageView addTouchTarget:self action:@selector(clickHeaderAction)];
    [self.containerView addSubview:self.avatarImageView];
}

- (void)setupRedPacketTextViews {
    if (self.style == TTRedPacketViewStyleOpening) {
        return;
    }
    
    CGFloat frameX = self.redPacketFrame.origin.x;
    CGFloat frameWidth = self.redPacketFrame.size.width;
    self.nameLabel = [[SSThemedLabel alloc] initWithFrame:CGRectMake(frameX + [TTDeviceUIUtils tt_newPadding:50], self.avatarImageView.bottom + [TTDeviceUIUtils tt_newPadding:10], frameWidth - [TTDeviceUIUtils tt_newPadding:100], [TTDeviceUIUtils tt_newPadding:24])];
    self.nameLabel.text = self.redpacket.user_info.name;
    self.nameLabel.textColor = [UIColor colorWithHexString:@"#FFF3BC"];
    self.nameLabel.textAlignment = NSTextAlignmentCenter;
    self.nameLabel.font = [UIFont boldSystemFontOfSize:[TTDeviceUIUtils tt_newFontSize:17]];
    self.nameLabel.layer.zPosition = 3;
    [self.containerView addSubview:self.nameLabel];
    
    self.descriptionLabel = [[SSThemedLabel alloc] initWithFrame:CGRectMake(frameX + [TTDeviceUIUtils tt_newPadding:40], self.nameLabel.bottom + [TTDeviceUIUtils tt_newPadding:4], frameWidth - [TTDeviceUIUtils tt_newPadding:80], [TTDeviceUIUtils tt_newPadding:40])];
    self.descriptionLabel.textColor = [UIColor colorWithHexString:@"#FFF3BC"];
    self.descriptionLabel.numberOfLines = 2;
    self.descriptionLabel.text = self.redpacket.subtitle;
    self.descriptionLabel.textAlignment = NSTextAlignmentCenter;
    self.descriptionLabel.verticalAlignment = ArticleVerticalAlignmentTop;
    self.descriptionLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:14]];
    self.descriptionLabel.layer.zPosition = 3;
    [self.containerView addSubview:self.descriptionLabel];
    
    self.followMeLabel = [[SSThemedLabel alloc] initWithFrame:CGRectMake(frameX + [TTDeviceUIUtils tt_newPadding:40], self.descriptionLabel.bottom + [TTDeviceUIUtils tt_newPadding:10], frameWidth - [TTDeviceUIUtils tt_newPadding:80], [TTDeviceUIUtils tt_newPadding:48])];
    self.followMeLabel.textColor = [UIColor colorWithHexString:@"#FFF3BC"];
    self.followMeLabel.text = self.redpacket.content;
    self.followMeLabel.numberOfLines = 2;
    self.followMeLabel.textAlignment = NSTextAlignmentCenter;
    self.followMeLabel.verticalAlignment = ArticleVerticalAlignmentTop;
    self.followMeLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:17]];
    self.followMeLabel.layer.zPosition = 3;
    [self.containerView addSubview:self.followMeLabel];
}

- (void)refreshUIForNight:(BOOL)night {
    NSString *headerColor = night ? @"8A3B37" : @"EF514A";
    self.gradientHeader.colors = @[(id)[UIColor colorWithHexString:headerColor].CGColor,
                                   (id)[UIColor colorWithHexString:headerColor].CGColor,
                                   (id)[UIColor colorWithHexString:headerColor].CGColor];
}

- (CGPathRef)headerExpandedPath {
    CGFloat frameWidth = self.redPacketFrame.size.width;
    CGFloat scale = self.width / frameWidth;
    UIBezierPath *newHeaderPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, [TTDeviceUIUtils tt_newPadding:105] - [TTDeviceUIUtils tt_newPadding:270] * scale, self.width, [TTDeviceUIUtils tt_newPadding:270] * scale) byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake([TTDeviceUIUtils tt_newPadding:8], [TTDeviceUIUtils tt_newPadding:8])];
    [newHeaderPath moveToPoint:CGPointMake(0, [TTDeviceUIUtils tt_newPadding:105])];
    [newHeaderPath addQuadCurveToPoint:CGPointMake(self.width, [TTDeviceUIUtils tt_newPadding:105]) controlPoint:CGPointMake(self.width / 2, [TTDeviceUIUtils tt_newPadding:180])];
    return newHeaderPath.CGPath;
}

- (void)setRedPacketFail {
    self.openButton.hidden = YES;
    self.coinsImageView.hidden = YES;
    self.descriptionLabel.hidden = YES;
    self.followMeLabel.top -= [TTDeviceUIUtils tt_newPadding:24];
    self.redPacketRuleButton.hidden = NO;
    self.arrowImageView.hidden = NO;
}

- (void)redPacketRuleAction:(id)sender {
    //除了领取成功，全都回到红包页
    if (self.delegate && [self.delegate respondsToSelector:@selector(redPacketClickRules)]) {
        [self.delegate redPacketClickRules];
    }
}

- (void)closeRedPacketAction:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(redPacketClickCloseButton)]) {
        [self.delegate redPacketClickCloseButton];
    }
}

- (void)clickHeaderAction {
    if (self.delegate && [self.delegate respondsToSelector:@selector(redPacketClickAvatar)]) {
        [self.delegate redPacketClickAvatar];
    }
}


- (void)showRedPacketFail:(FRRedpacketOpenResultStructModel *)data {
    self.ruleScheme = data.footer.url;
    self.followMeLabel.text = data.reason;
    [self.redPacketRuleButton setTitle:data.footer.text forState:UIControlStateNormal];
    [self.redPacketRuleButton sizeToFit];
    self.redPacketRuleButton.frame = CGRectMake((self.width - self.redPacketRuleButton.width - [TTDeviceUIUtils tt_newPadding:12]) / 2, self.redPacketFrame.size.height + self.redPacketFrame.origin.y - [TTDeviceUIUtils tt_newPadding:27], self.redPacketRuleButton.width, [TTDeviceUIUtils tt_newPadding:17]);
    self.arrowImageView.left = self.redPacketRuleButton.right + [TTDeviceUIUtils tt_newPadding:4];
    [self setRedPacketFail];
}

#pragma mark - public

- (void)resetOpenState {
    self.coinsImageView.hidden = YES;
}

- (void)openPacketAction:(id)sender {
    self.coinsImageView.hidden = NO;
    self.openButton.enabled = NO;
    [self.coinsImageView startAnimating];
    [self performSelector:@selector(coinsFallDone) withObject:nil afterDelay:0.45];
}

- (void)coinsFallDone {
    if (self.delegate && [self.delegate respondsToSelector:@selector(redPacketClickOpenButton)]) {
        [self.delegate redPacketClickOpenButton];
    }
}

- (void)openRedPacketAnimationBegin {
    self.openButton.hidden = YES;
    self.coinsImageView.hidden = YES;
    self.closeRedPacketButton.hidden = YES;
    self.redPacketRuleButton.hidden = YES;
    self.arrowImageView.hidden = YES;
    self.avatarImageView.userInteractionEnabled = NO;
    self.avatarImageView.disableNightMode = NO;
    self.avatarImageView.verifyView.disableNightMode = NO;
    [self.shadowLayer removeFromSuperlayer];
    CGFloat frameWidth = self.redPacketFrame.size.width;
    CGFloat frameHeight = self.redPacketFrame.size.height;
    CGFloat scale = self.width / frameWidth;
    UIBezierPath *newBottomPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, self.height, self.width, (frameHeight - [TTDeviceUIUtils tt_newPadding:270]) * scale)
                                                        byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight
                                                              cornerRadii:CGSizeMake([TTDeviceUIUtils tt_newPadding:8], [TTDeviceUIUtils tt_newPadding:8])];
    [newBottomPath moveToPoint:CGPointMake(0, self.height)];
    [newBottomPath addQuadCurveToPoint:CGPointMake(self.width, self.height) controlPoint:CGPointMake(self.width / 2, (self.height + [TTDeviceUIUtils tt_newPadding:70]) * scale)];
    CABasicAnimation *bottomPathAnimation = [CABasicAnimation animation];
    bottomPathAnimation.keyPath = @"path";
    bottomPathAnimation.fromValue = (__bridge id)_redPacketBottom.path;
    bottomPathAnimation.toValue = (__bridge id)newBottomPath.CGPath;
    bottomPathAnimation.duration = 0.4;
    bottomPathAnimation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.32 :0.94 :0.6 :1];
    bottomPathAnimation.fillMode = kCAFillModeForwards;
    bottomPathAnimation.removedOnCompletion = NO;
    [_redPacketBottom addAnimation:bottomPathAnimation forKey:nil];
    
    CGPathRef newHeaderPath = [self headerExpandedPath];
    CABasicAnimation *headerPathAnimation = [CABasicAnimation animation];
    headerPathAnimation.keyPath = @"path";
    headerPathAnimation.fromValue = (__bridge id)_redPacketHeader.path;
    headerPathAnimation.toValue = (__bridge id)newHeaderPath;
    headerPathAnimation.duration = 0.4;
    headerPathAnimation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.32 :0.94 :0.6 :1];
    headerPathAnimation.fillMode = kCAFillModeForwards;
    headerPathAnimation.removedOnCompletion = NO;
    [_redPacketHeader addAnimation:headerPathAnimation forKey:nil];
    NSString *headerColor = [[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeNight ? @"8A3B37" : @"EF514A";
    [UIView animateWithDuration:0.4 animations:^{
        self.gradientHeader.colors = @[(id)[UIColor colorWithHexString:headerColor].CGColor,
                                       (id)[UIColor colorWithHexString:headerColor].CGColor,
                                       (id)[UIColor colorWithHexString:headerColor].CGColor];
        self.nameLabel.alpha = 0;
        self.nameLabel.bottom = -[TTDeviceUIUtils tt_newPadding:122];
        self.descriptionLabel.alpha = 0;
        self.descriptionLabel.bottom = -[TTDeviceUIUtils tt_newPadding:78];
        self.followMeLabel.alpha = 0;
        self.followMeLabel.bottom = 0;
        self.avatarImageView.top = [TTDeviceUIUtils tt_newPadding:113];
    } completion:^(BOOL finished) {
        self.avatarImageView.userInteractionEnabled = YES;
        [self.nameLabel removeFromSuperview];
        [self.descriptionLabel removeFromSuperview];
        [self.followMeLabel removeFromSuperview];
    }];
}

#pragma mark - action

//产品说点背景收红包容易误操作，先注释掉
//- (void)actionTap:(UITapGestureRecognizer *)recognizer {
//    CGPoint point = [recognizer locationInView:self.containerView];
//    if (CGRectContainsPoint(self.redPacketFrame, point)) {
//        return;
//    }
//    [UIView animateWithDuration:0.5 animations:^{
//        self.alpha = 0;
//    } completion:^(BOOL finished) {
//        [self removeFromSuperview];
//    }];
//}
//
//#pragma mark - GET/SET
//
//- (UITapGestureRecognizer *)tapGestureRecognizer {
//    if (!_tapGestureRecognizer) {
//        _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionTap:)];
//    }
//    return _tapGestureRecognizer;
//}

@end
