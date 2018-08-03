//
//  TTFeedGuideView.m
//  Article
//
//  Created by Chen Hong on 2017/7/18.
//
//

#import "TTFeedGuideView.h"
#import "TTUIResponderHelper.h"
#import "UIColor+TTThemeExtension.h"
//#import "TTContactsGuideViewHelper.h"
#import "TTArticleTabBarController.h"
//#import "TTContactsRedPacketGuideViewHelper.h"

@import ObjectiveC;

static NSString * const kFeedGuideConfigTypeKey = @"kFeedGuideConfigTypeKey";
static NSString * const kFeedGuideSearchTextKey = @"kFeedGuideSearchTextKey";
static NSString * const kFeedGuideDislikeTextKey = @"kFeedGuideDislikeTextKey";

@implementation TTFeedGuideTipModel
@end

@implementation TTFeedGuideView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5f];
    }
    return self;
}

- (void)addGuideItem:(TTFeedGuideTipModel *)item {
    CGRect subRect = item.targetRect;
    
    if (item.radius > 0) {
        CGRect ovalRect = CGRectMake(CGRectGetMidX(subRect) - item.radius, CGRectGetMidY(subRect) - item.radius, item.radius * 2, item.radius * 2);

        //镂空subRect区域
        CAShapeLayer *subRectMask = [CAShapeLayer layer];
        [subRectMask setFillColor:[UIColor blackColor].CGColor];
        UIBezierPath *path = [UIBezierPath bezierPathWithRect:self.bounds];
        UIBezierPath *ovalRectPath = [UIBezierPath bezierPathWithOvalInRect:ovalRect];
        [path appendPath:ovalRectPath];
        subRectMask.fillRule = kCAFillRuleEvenOdd;
        subRectMask.path = path.CGPath;
        [self.layer setMask:subRectMask];
        
        CAShapeLayer *borderLayer = [CAShapeLayer layer];
        borderLayer.fillColor = nil;
        borderLayer.path = [UIBezierPath bezierPathWithOvalInRect:CGRectInset(ovalRect, -1, -1)].CGPath;
        borderLayer.strokeColor = [self strokeColor].CGColor;
        borderLayer.lineWidth = 0.f;
        [self.layer addSublayer:borderLayer];
        
        [self addAnimationForBorder:borderLayer];
    } else {
        //镂空subRect区域
        CAShapeLayer *subRectMask = [CAShapeLayer layer];
        [subRectMask setFillColor:[UIColor blackColor].CGColor];
        UIBezierPath *path = [UIBezierPath bezierPathWithRect:self.bounds];
        UIBezierPath *rectPath = item.targetRectCornerRadius > 0 ? [UIBezierPath bezierPathWithRoundedRect:subRect cornerRadius:item.targetRectCornerRadius] : [UIBezierPath bezierPathWithRect:subRect];
        [path appendPath:rectPath];
        subRectMask.fillRule = kCAFillRuleEvenOdd;
        subRectMask.path = path.CGPath;
        [self.layer setMask:subRectMask];
        
        //镂空区域加边框
        CAShapeLayer *borderLayer = [CAShapeLayer layer];
        borderLayer.fillColor = nil;
        borderLayer.path = item.targetRectCornerRadius > 0 ? [UIBezierPath bezierPathWithRoundedRect:CGRectInset(subRect, -1, -1) cornerRadius:item.targetRectCornerRadius].CGPath : [UIBezierPath bezierPathWithRect:CGRectInset(subRect, -1, -1)].CGPath;
        borderLayer.strokeColor = [self strokeColor].CGColor;
        borderLayer.lineWidth = 2.f;
        [self.layer addSublayer:borderLayer];
        
        [self addAnimationForBorder:borderLayer];
    }
    
    CGPoint pt = CGPointMake(subRect.origin.x + item.arrowPoint.x, subRect.origin.y + item.arrowPoint.y);
    
    TTBubbleView *bubbleView = [[TTBubbleView alloc] initWithAnchorPoint:pt tipText:item.tip arrowDirection:item.arrowDirection fontSize:[self bubbleFontSize] containerViewHeight:44.f paddingH:20.f];
    [self addSubview:bubbleView];

    WeakSelf;
    [bubbleView showTipWithAnimation:YES automaticHide:NO animationCompleteHandle:nil tapHandle:^{
        StrongSelf;
        [[TTGuideDispatchManager sharedInstance_tt] removeGuideViewItem:self];
        [self removeFromSuperview];
    }];
}

- (CGFloat)bubbleFontSize {
    if([TTDeviceHelper is568Screen] || [TTDeviceHelper is480Screen]){//4/4s/5/s
        return 15.f;
    } else {
        return 17.f;
    }
}

- (void)addAnimationForBorder:(CALayer *)borderLayer {
    //边框颜色动画
    CABasicAnimation *strokeColorAnim = [CABasicAnimation animationWithKeyPath:@"strokeColor"];
    strokeColorAnim.fromValue = [borderLayer valueForKey:@"strokeColor"];
    strokeColorAnim.toValue = (id)[UIColor clearColor].CGColor;
    
    //边框宽度动画
    CABasicAnimation *borderAnim = [CABasicAnimation animationWithKeyPath:@"lineWidth"];
    borderAnim.fromValue = @0;
    borderAnim.toValue = @32;
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.duration = 2;
    group.repeatCount = FLT_MAX;
    group.animations = @[strokeColorAnim, borderAnim];
    group.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.32 :0.94 :0.6 :1];
    
    [borderLayer addAnimation:group forKey:@"stroke"];
}

- (UIColor *)strokeColor {
    return [UIColor colorWithDayColorName:@"FFFFFF" nightColorName:@"666666"];
}

+ (void)configFromSettings:(NSDictionary *)setting {
    NSString *kFeedGuideConfigKey = @"tt_feed_guide_config";
    if ([setting objectForKey:kFeedGuideConfigKey]) {
        NSDictionary *config = [setting tt_dictionaryValueForKey:kFeedGuideConfigKey];
        if (config) {
            NSString *type = [config tt_stringValueForKey:@"type"];
            [[NSUserDefaults standardUserDefaults] setValue:type forKey:kFeedGuideConfigTypeKey];
            
            NSString *searchText = [config tt_stringValueForKey:@"search_text"];
            [[NSUserDefaults standardUserDefaults] setValue:searchText forKey:kFeedGuideSearchTextKey];
            
            NSString *dislikeText = [config tt_stringValueForKey:@"dislike_text"];
            [[NSUserDefaults standardUserDefaults] setValue:dislikeText forKey:kFeedGuideDislikeTextKey];
        }
    }
}

+ (NSString *)textForType:(TTFeedGuideType)type {
    NSString *text = nil;
    switch (type) {
        case TTFeedGuideTypeSearch:
            text = [[NSUserDefaults standardUserDefaults] stringForKey:kFeedGuideSearchTextKey];
            if (isEmptyString(text)) {
                text = @"搜索自己感兴趣内容";
            }
            break;
            
        case TTFeedGuideTypeDislike:
            text = [[NSUserDefaults standardUserDefaults] stringForKey:kFeedGuideDislikeTextKey];
            if (isEmptyString(text)) {
                text = @"删除不感兴趣内容，减少推荐";
            }
            break;
            
        default:
            break;
    }
    return text;
}

+ (BOOL)isFeedGuideTypeEnabled:(TTFeedGuideType)type {
    if ([TTDeviceHelper isPadDevice]) return NO;
    
    UIViewController *controller = [[[UIApplication sharedApplication] keyWindow] rootViewController];
    if ([controller isKindOfClass:[TTArticleTabBarController class]]) {
        TTArticleTabBarController *tabBarController = (TTArticleTabBarController *)controller;
        if ([tabBarController isTipsShowing] /*||
            [TTContactsRedPacketGuideViewHelper hasGuideViewDisplayedAfterLaunching] ||
            [TTContactsGuideViewHelper hasGuideViewDisplayedAfterLaunching]*/) {
            return NO;
        }
    }
    
    NSString *typeFromSetting = [[NSUserDefaults standardUserDefaults] stringForKey:kFeedGuideConfigTypeKey];
    if (isEmptyString(typeFromSetting)) {
        return NO;
    }
    
    NSString *typeStr = nil;
    switch (type) {
        case TTFeedGuideTypeSearch:
            typeStr = @"search";
            break;
            
        case TTFeedGuideTypeDislike:
            typeStr = @"dislike";
            break;
            
        default:
            break;
    }
    
    return [typeStr isEqualToString:typeFromSetting];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self dismiss];
}

- (void)dismiss {
    [[TTGuideDispatchManager sharedInstance_tt] removeGuideViewItem:self];
    [self removeFromSuperview];
}

#pragma mark - TTGuideProtocol

- (TTGuidePriority)priority {
    return kTTGuidePriorityLow;
}

- (BOOL)shouldDisplay:(id)context {
    return YES;
}

- (void)showWithContext:(id)context {
    self.frame = [TTUIResponderHelper mainWindow].bounds;
    [[TTUIResponderHelper mainWindow] addSubview:self];
}

- (id)context {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setContext:(id)context {
    objc_setAssociatedObject(self, @selector(context), context, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
