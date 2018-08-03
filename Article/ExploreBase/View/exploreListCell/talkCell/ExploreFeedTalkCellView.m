//
//  ExploreFeedTalkCellView.m
//  Article
//
//  Created by Chen Hong on 15/1/15.
//
//

#import "ExploreFeedTalkCellView.h"
#import "ExploreEmbedListTalkModel.h"
#import "SSImageView.h"
#import "ExploreArticleCellViewConsts.h"
#import "ExploreEmbedListMomentModel.h"
#import "SSAppPageManager.h"
#import "SSAvatarView.h"
#import "TTAlphaThemedButton.h"
#import "TTNetworkManager.h"
#import "NetworkUtilities.h"
#import "TTIndicatorView.h"
#import "TTArticleTabBarController.h"
#import "ExploreCategoryDefine.h"
#import "FRArchitectureManager.h"
#import "TTLogManager.h"
#import "TTUISettingHelper.h"
#import "TTDeviceHelper.h"
#import "TTStringHelper.h"
#import "UIImage+TTThemeExtension.h"

//#define kAvatarViewLeft        kCellLeftPadding
#define kAvatarViewTop         18
#define kAvatarViewBottom      15
#define kAvatarViewW           36
//#define kAvatarViewRightPad    13
//#define kAvatarViewCornerRadius 4
//#define kNameTop               26.0f
#define kTextTopPad            2.0f
#define kNameLeft              8.0f

#define kRelationButtonWidth ([TTDeviceHelper isScreenWidthLarge320] ? 72 : 62)
#define kRelationButtonHeight ([TTDeviceHelper isScreenWidthLarge320] ? 28 : 26)
#define kRelationButtonTitleFontSize 14
#define kRelationButtonCornerRadius 6

extern NSString *const kForumLikeStatusChangeNotification;
extern NSString *const kForumLikeStatusChangeForumIDKey;
extern NSString *const kForumLikeStatusChangeForumLikeKey;
//
//static NSString *const kForumLikeStatusChangeNotification = @"kForumLikeStatusChangeNotification";
//static NSString *const kForumLikeStatusChangeForumIDKey   = @"kForumLikeStatusChangeForumIDKey";
//static NSString *const kForumLikeStatusChangeForumLikeKey = @"kForumLikeStatusChangeForumLikeKey";

@interface ExploreFeedTalkCellView ()
@property (nonatomic, strong) SSThemedLabel             *nameLabel;
@property (nonatomic, strong) UILabel                   *descLabel;
@property (nonatomic, strong) SSImageView               *avatarView;
@property (nonatomic, strong) ExploreEmbedListTalkModel *talkModel;
@property (nonatomic, strong) SSThemedView              *bottomLineView;

@property (nonatomic, strong) TTAlphaThemedButton       *relationButton; //关注
@property (nonatomic, strong) TTAlphaThemedButton       *enterButton; //进入话题
@property (nonatomic, strong) SSThemedImageView         *iconView; //动画icon
@end

@implementation ExploreFeedTalkCellView

+ (CGFloat)heightForData:(id)data cellWidth:(CGFloat)width listType:(ExploreOrderedDataListType)listType
{
    if ([data isKindOfClass:[ExploreEmbedListTalkModel class]]) {
        ExploreEmbedListTalkModel *talkModel = (ExploreEmbedListTalkModel *)data;
        if (talkModel) {
            CGFloat height = kAvatarViewW + kAvatarViewTop + kAvatarViewBottom;
            return height;
        }
    }
    
    return 0.f;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kForumLikeStatusChangeNotification object:nil];
}

- (CGFloat)nameLabelFontSize {
    if ([TTDeviceHelper isScreenWidthLarge320]) {
        return 19.0;
    } else {
        return 15.0;
    }
}

- (CGFloat)descLabelFontSize {
    if ([TTDeviceHelper isScreenWidthLarge320]) {
        return 14.0;
    } else {
        return 12.0;
    }
}

- (CGFloat)butttonFontSize {
    if ([TTDeviceHelper isScreenWidthLarge320]) {
        return 14.0;
    } else {
        return 15.0;
    }
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.avatarView = [[SSImageView alloc] initWithFrame:CGRectMake(self.width - kCellRightPadding - kAvatarViewW, kAvatarViewTop, kAvatarViewW, kAvatarViewW)];
        _avatarView.backgroundColorThemeKey = kColorBackground2;
        _avatarView.userInteractionEnabled = NO;
        [self addSubview:_avatarView];
        
        self.nameLabel             = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _nameLabel.font            = [UIFont systemFontOfSize:[self nameLabelFontSize]];
        _nameLabel.backgroundColor = [UIColor clearColor];
        _nameLabel.textColorThemeKey = kColorText1;
        [self addSubview:_nameLabel];
        
        self.descLabel             = [[UILabel alloc] initWithFrame:CGRectZero];
        _descLabel.font            = [UIFont systemFontOfSize:[self descLabelFontSize]];
        _descLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_descLabel];
        
        self.relationButton = [TTAlphaThemedButton buttonWithType:UIButtonTypeCustom];
        [_relationButton setTitle:NSLocalizedString(@"关注", nil) forState:UIControlStateNormal];
        _relationButton.frame = CGRectMake(0, 0, kRelationButtonWidth, kRelationButtonHeight);
        [_relationButton.titleLabel setFont:[UIFont systemFontOfSize:self.butttonFontSize]];
        _relationButton.layer.cornerRadius = kRelationButtonCornerRadius;
        _relationButton.layer.borderWidth = 1;//[TTDeviceHelper ssOnePixel];
//        _relationButton.imageName = @"b_newtopic_tabbar";
        _relationButton.borderColorThemeKey = kColorLine3;
//        _relationButton.highlightedBorderColorThemeKey = kColorLine3Highlighted;
        _relationButton.titleColorThemeKey = kColorText6;
//        _relationButton.highlightedTitleColorThemeKey = kColorText6Highlighted;
//        _relationButton.imageEdgeInsets = UIEdgeInsetsMake(0, -6, 0, 0);
//        _relationButton.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);
        [_relationButton addTarget:self action:@selector(relationButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_relationButton];
        
        self.enterButton = [TTAlphaThemedButton buttonWithType:UIButtonTypeCustom];
        [_enterButton setTitle:NSLocalizedString(@"进入话题 >", nil) forState:UIControlStateNormal];
        _enterButton.frame = CGRectMake(0, 0, kRelationButtonWidth, kRelationButtonHeight);
        [_enterButton.titleLabel setFont:[UIFont systemFontOfSize:self.butttonFontSize]];
        _enterButton.titleColorThemeKey = kColorText6;
//        _enterButton.imageEdgeInsets = UIEdgeInsetsMake(0, -6, 0, 0);
//        _enterButton.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);
        [_enterButton addTarget:self action:@selector(enterButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_enterButton sizeToFit];
        [self addSubview:_enterButton];
        _enterButton.hidden = YES;
        
        self.bottomLineView = [[SSThemedView alloc] initWithFrame:CGRectZero];
        _bottomLineView.backgroundColorThemeKey = kColorLine1;
        [self addSubview:_bottomLineView];
        _bottomLineView.hidden = self.hideBottomLine;
        [self reloadThemeUI];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(forumLikeStatusChangedNotification:) name:kForumLikeStatusChangeNotification object:nil];
    }
    return self;
}

- (void)themeChanged:(NSNotification *)notification
{
    [super themeChanged:notification];
    self.backgroundColor = [TTUISettingHelper cellViewBackgroundColor];

    if (self.talkModel) {
        [self refreshTextLabels];
        //[_avatarView setImageWithURLString:_talkModel.avatarUrl placeholderImage:nil];
    }
}

- (void)refreshUI {
    [_nameLabel sizeToFit];
    [_descLabel sizeToFit];

    CGFloat x = kCellLeftPadding;
    
    self.avatarView.frame = CGRectMake(x, kAvatarViewTop, kAvatarViewW, kAvatarViewW);

    CGFloat maxW = self.width - kAvatarViewW - kCellLeftPadding*2 - kRelationButtonWidth - kNameLeft*2;
    
    if (_descLabel.width > maxW) {
        _descLabel.width = maxW;
    }
    
    CGFloat textH = _nameLabel.height + _descLabel.height + kTextTopPad;
    CGFloat y = (self.height - textH) / 2;
    
    CGFloat nameLeft = x + kAvatarViewW + kNameLeft;
    _nameLabel.origin = CGPointMake(nameLeft, y);
    _descLabel.origin = CGPointMake(nameLeft, _nameLabel.bottom + kTextTopPad);
    
    _relationButton.centerY = _avatarView.centerY;
    _relationButton.right = self.width - kCellRightPadding;
    
    _enterButton.center = _relationButton.center;
    
    _bottomLineView.frame = CGRectMake(kCellLeftPadding, self.height - [TTDeviceHelper ssOnePixel], self.width - kCellLeftPadding * 2, [TTDeviceHelper ssOnePixel]);
}

- (void)refreshWithData:(id)data {
    if ([data isKindOfClass:[ExploreEmbedListTalkModel class]]) {
        self.talkModel = data;
    } else {
        self.talkModel = nil;
    }
    
    [_avatarView setImageWithURLString:_talkModel.avatarUrl placeholderImage:nil];
//  [_avatarView showAvatarByURL:_talkModel.avatarUrl];
    
    if (self.talkModel) {
        _nameLabel.text = _talkModel.name;
        [self refreshTextLabels];
    } else {
        _nameLabel.text = nil;
        _descLabel.text = nil;
    }
    
    [self refreshButton];
}

- (void)refreshButton
{
    if (self.talkModel.isFollow) {
        _relationButton.hidden = YES;
        
        if (!isEmptyString(self.talkModel.openUrl)) {
            _enterButton.hidden = NO;
        } else {
            _enterButton.hidden = YES;
        }
    } else {
        _relationButton.hidden = NO;
        _relationButton.enableHighlightAnim = YES;

        _enterButton.hidden = YES;
    }
}

- (void)showAnimation {
    
    BOOL hasIconViewAnim = ![TTDeviceHelper isPadDevice] && ![[FRArchitectureManager sharedInstance_tt] isConcernType];
    
    // 1. 点击关心后，关注button缩小消失
    if (hasIconViewAnim) {
        if (!_iconView) {
            self.iconView = [[SSThemedImageView alloc] initWithImage:[UIImage imageNamed:@"topic_tabbar_press"]];
            _iconView.imageName = @"topic_tabbar_press";
            _iconView.center = _relationButton.center;
            [self addSubview:_iconView];
        }
    } else {
        [_iconView removeFromSuperview];
        _iconView = nil;
    }

    _iconView.hidden = NO;
    _iconView.transform = CGAffineTransformMakeScale(0, 0);
    _iconView.alpha = 0;

    _relationButton.enableHighlightAnim = NO;
    
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        _relationButton.transform = CGAffineTransformMakeScale(0.5, 0.5);
        _relationButton.alpha = 0;
        
        // 2. 同时心形icon放大显示
        _iconView.transform = CGAffineTransformIdentity;
        _iconView.alpha = 1;
    } completion:^(BOOL finished) {
        _relationButton.hidden = YES;
        _relationButton.transform = CGAffineTransformIdentity;
        _relationButton.alpha = 1;
        
        // 3. 心形icon出现后，停留0.2秒，进入话题button出现
        _enterButton.transform = CGAffineTransformMakeScale(0.5, 0.5);
        _enterButton.hidden = NO;
        _enterButton.alpha = 0;
        
        [UIView animateWithDuration:0.2 delay:0.2 options:UIViewAnimationOptionCurveEaseOut animations:^{
            _enterButton.transform = CGAffineTransformMakeScale(1, 1);
            _enterButton.alpha = 1;
        } completion:nil];
        
        // 4. 心形icon出现后，停留0.2秒，掉落至底tab上
        if (_iconView) {
            TTArticleTabBarController * rootTabController = (TTArticleTabBarController *)self.window.rootViewController;
            if ([rootTabController isKindOfClass:[TTArticleTabBarController class]]) {
                UIViewController *forumVC = [rootTabController forumViewController];
                UITabBarItem *tabbarItem = forumVC.tabBarItem;
                UIView *barItemView = [tabbarItem valueForKey:@"view"];
                
                UIWindow * applicationWindow = [[[UIApplication sharedApplication] delegate] window];
                _iconView.center = [applicationWindow convertPoint:_iconView.center fromView:self];
                [applicationWindow addSubview:_iconView];
                
                CGPoint dest = [applicationWindow convertPoint:barItemView.center fromView:barItemView.superview];
                dest.y -= 5;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self makeCurvePathAnimWithView:_iconView fromPoint:_iconView.center toPoint:dest duration:0.6];
                });
            }
        } else {
            [self notifyForumLikeStatusChange];
        }
    }];
}

- (void)makeCurvePathAnimWithView:(UIView *)view fromPoint:(CGPoint)from toPoint:(CGPoint)dest duration:(CGFloat)dur {
    if (!view) {
        return;
    }
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:from];
    
    CGPoint ct = CGPointMake(dest.x, from.y + (dest.y - from.y)/3);
    [path addQuadCurveToPoint:dest controlPoint:ct];
    
    CAKeyframeAnimation *moveAnim = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    moveAnim.path = path.CGPath;
    moveAnim.duration = dur;
    moveAnim.delegate = self;
    moveAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    view.layer.position = dest;
    [view.layer addAnimation:moveAnim forKey:@"moveAnim"];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    // 放大消失
    [UIView animateWithDuration:0.2 animations:^{
        _iconView.transform = CGAffineTransformMakeScale(1.8f, 1.8f);
        _iconView.alpha = 0.f;
    } completion:^(BOOL finished) {
        [_iconView removeFromSuperview];
        _iconView = nil;
        [self notifyForumLikeStatusChange];
    }];
}

// 12345 -> 1.2万
- (NSString *)digitalStr:(int)num {
    NSString *result = nil;
    if (num < 10000) {
        result = [NSString stringWithFormat:@"%d", num];
    } else {
        int r = (num%10000)/1000;
        if (r > 0) {
            result = [NSString stringWithFormat:@"%d.%d%@", num/10000, r, NSLocalizedString(@"万", nil)];
        } else {
            result = [NSString stringWithFormat:@"%d%@", num/10000, NSLocalizedString(@"万", nil)];
        }
    }
    return result;
}

- (void)refreshTextLabels {
    NSString *desc = _talkModel.desc;
    
    NSString *pattern = @"\\{([^}]+)\\}";
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
    
    NSArray *matches = [expression matchesInString:desc options:0 range:NSMakeRange(0, desc.length)];
    
    NSMutableString *content = [NSMutableString string];
    NSMutableArray *replacedRanges = [NSMutableArray array];
    
    NSUInteger location = 0;
    NSString *digitalStr = nil;
    
    for (NSTextCheckingResult *result in matches) {
        if (result.range.location != NSNotFound) {
            NSString *matchStr = [desc substringWithRange:result.range];
            //NSLog(@"%@", matchStr);
            if ([matchStr isEqualToString:@"{participant_count}"]) {
                digitalStr = [self digitalStr:[_talkModel.participantCount intValue]];
            }
            else if ([matchStr isEqualToString:@"{talk_count}"]) {
                digitalStr = [self digitalStr:[_talkModel.talkCount intValue]];
            }
            else {
                digitalStr = [matchStr substringWithRange:NSMakeRange(1, matchStr.length-2)];
            }
            
            [content appendString:[desc substringWithRange:NSMakeRange(location, result.range.location - location)]];
            
            [replacedRanges addObject:[NSValue valueWithRange:NSMakeRange(content.length, digitalStr.length)]];
            
            location = result.range.location + result.range.length;
            
            [content appendString:digitalStr];
        }
    }
    
    if (location < desc.length) {
        [content appendString:[desc substringFromIndex:location]];
    }
    

    UIColor *digitalColor = [UIColor tt_themedColorForKey:kColorText5];
    
    UIColor *txtColor = [UIColor tt_themedColorForKey:kColorText3];
    _descLabel.textColor = txtColor;
    
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:content];

    for (NSValue* rangeValue in replacedRanges) {
        NSRange range = rangeValue.rangeValue;
        [attributeString setAttributes:@{NSForegroundColorAttributeName : digitalColor} range:range];
    }
    
    NSMutableParagraphStyle *pStyle = [[NSMutableParagraphStyle alloc] init];
    pStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    [attributeString addAttribute:NSParagraphStyleAttributeName value:pStyle range:NSMakeRange(0, attributeString.length)];
    
    _descLabel.attributedText = attributeString;
}

- (id)cellData {
    return self.talkModel;
}

- (void)viewDidTapped {
    if (self.isCardSubCellView) {
        NSDictionary *extra = @{@"category_name": [NSString stringWithFormat:@"%@", self.talkModel.categoryID]};
        ssTrackEventWithCustomKeys(@"card", [NSString stringWithFormat:@"click_cell_%ld",self.cardSubCellIndex], [NSString stringWithFormat:@"%@", self.cardId], nil, extra);
//        ssTrackEvent(@"card", [NSString stringWithFormat:@"click_topic_%ld", (long)self.cardSubCellIndex]);
        [TTLogManager logEvent:@"click_cell" context:@{@"cell_type":@"card" , @"card_id":self.cardId , @"card_position":[NSString stringWithFormat:@"%ld", self.cardSubCellIndex]} screenName:self.talkModel.categoryID];
    }
    

    if (!isEmptyString(self.talkModel.openUrl)) {
        // 卡片统计
        NSMutableDictionary *conditionDict = nil;
        
        if (self.isCardSubCellView) {
            NSString *eventLabel;
            
            if (!isEmptyString(self.talkModel.categoryID) ) {
                if ([self.talkModel.categoryID isEqualToString:kMainCategoryID]) {
                    eventLabel = @"click_headline";
                }
                else {
                    eventLabel = [NSString stringWithFormat:@"click_%@", self.talkModel.categoryID];
                }
            }
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:10];
            [dict setValue:@"umeng" forKey:@"category"];
            [dict setValue:@"forum_detail" forKey:@"tag"];
            [dict setValue:eventLabel forKey:@"label"];
            [dict setValue:self.talkModel.uniqueID forKey:@"value"];
            [dict setValue:self.cardId forKey:@"card_id"];
            [dict setValue:@(self.cardSubCellIndex) forKey:@"card_position"];
//            [SSTracker eventData:dict];
            conditionDict = dict;//[NSMutableDictionary dictionary];
//            [conditionDict setValue:dict forKey:@"forum_umeng"];
        }
        
        NSURL *openURL = [TTStringHelper URLWithURLString:self.talkModel.openUrl];
        [[SSAppPageManager sharedManager] openURL:openURL baseCondition:conditionDict];
    }
}

- (void)relationButtonClicked:(id)sender
{
    if (!SSNetworkConnected()) {
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"网络不给力，请稍后重试" indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage"] autoDismiss:YES dismissHandler:nil];
        return;
    }
    
    self.talkModel.isFollow = YES;
    //[self refreshButton];
    [self showAnimation];

    NSString *url = [[self class] followURLString];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:self.talkModel.uniqueID forKey:@"forum_id"];
    
    [[TTNetworkManager shareInstance] requestForJSONWithURL:url params:params method:@"POST" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        if (error) {
            self.talkModel.isFollow = NO;
            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"关注失败" indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage"] autoDismiss:YES dismissHandler:nil];
        }
    }];
    
    // 卡片统计
    if (self.isCardSubCellView) {
        NSString *categoryName = self.talkModel.categoryID;
        if ([categoryName isEqualToString:kMainCategoryID]) {
            categoryName = @"headline";
        }

        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:10];
        [dict setValue:@"umeng" forKey:@"category"];
        [dict setValue:@"forum_detail" forKey:@"tag"];
        [dict setValue:@"follow" forKey:@"label"];
        [dict setValue:self.talkModel.uniqueID forKey:@"value"];
        [dict setValue:self.cardId forKey:@"card_id"];
        [dict setValue:@(self.cardSubCellIndex) forKey:@"card_position"];
        [dict setValue:categoryName forKey:@"category_name"];
        [SSTracker eventData:dict];
    }
}

- (void)notifyForumLikeStatusChange {
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    [userInfo setValue:self.talkModel.uniqueID forKey:kForumLikeStatusChangeForumIDKey];
    [userInfo setValue:@(YES) forKey:kForumLikeStatusChangeForumLikeKey];
    [[NSNotificationCenter defaultCenter] postNotificationName:kForumLikeStatusChangeNotification object:self userInfo:userInfo];
}

+ (NSString*)followURLString
{
    return [NSString stringWithFormat:@"%@/ttdiscuss/v1/commit/followforum/", [CommonURLSetting baseURL]];
}

- (void)enterButtonClicked:(id)sender
{
    [self viewDidTapped];
}

- (void)forumLikeStatusChangedNotification:(NSNotification*)notification
{
    NSString *forumID = [notification.userInfo objectForKey:kForumLikeStatusChangeForumIDKey];
    NSNumber *liked = [notification.userInfo objectForKey:kForumLikeStatusChangeForumLikeKey];
    
    if ([self.talkModel.uniqueID integerValue] == [forumID integerValue]) {
        self.talkModel.isFollow = [liked intValue];
        [self refreshButton];
    }
}

@end
