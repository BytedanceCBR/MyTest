//
//  TTArticleStoryToolView.m
//  Article
//
//  Created by 冯靖君 on 16/7/12.
//
//  文章详情页连载小说工具栏

#import "TTArticleStoryToolView.h"
#import "TTRoute.h"
#import "UIButton+TTAdditions.h"
#import "TTDeviceHelper.h"

#define kToolViewHoriPadding    15.f
#define kToolViewVertiPadding   12.f
#define kToolViewHeight         40.f
#define kToolItemFontSize       16.f
#define kToolItemColor          kColorText5
#define kToolItemDisableColor   kColorText9

typedef NS_ENUM(NSInteger, ToolItemType)
{
    ToolItemTypePre,
    ToolItemTypeNext,
    ToolItemTypeCatalog
};

@interface TTArticleStoryToolView ()
{
    BOOL _animating;
}

@property(nonatomic, strong) SSThemedButton *previousChapterButton;
@property(nonatomic, strong) SSThemedButton *nextChapterButton;
@property(nonatomic, strong) SSThemedButton *catalogButton;
@property(nonatomic, strong) CALayer *bottomLine;
@property(nonatomic, strong) Article *article;
@property(nonatomic, strong) NSDictionary *novelData;

@end

@implementation TTArticleStoryToolView

- (instancetype)initWithWidth:(CGFloat)width article:(Article *)article {
    self = [super initWithFrame:CGRectMake(0, 0, width, kToolViewHeight)];
    if (self) {
        _article = article;
        _novelData = article.novelData;
        [self.previousChapterButton addTarget:self action:@selector(toolItemFired:) forControlEvents:UIControlEventTouchUpInside];
        [self.nextChapterButton addTarget:self action:@selector(toolItemFired:) forControlEvents:UIControlEventTouchUpInside];
        [self.catalogButton addTarget:self action:@selector(toolItemFired:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.previousChapterButton];
        [self addSubview:self.nextChapterButton];
        [self addSubview:self.catalogButton];
        self.bottomLine = [[CALayer alloc] init];
        [self.layer addSublayer:self.bottomLine];
        
        self.hidden = YES;
        [self reloadThemeUI];
        [self layout];
    }
    return self;
}

- (void)layout
{
    CGFloat itemSpacing = (self.width - kToolViewHoriPadding * 2 - self.previousChapterButton.width - self.catalogButton.width - self.nextChapterButton.width) / 2;
    self.previousChapterButton.left = kToolViewHoriPadding;
    self.previousChapterButton.centerY = kToolViewHeight/2;
    self.catalogButton.left = self.previousChapterButton.right + itemSpacing;
    self.catalogButton.centerY = self.previousChapterButton.centerY;
    self.nextChapterButton.left = self.catalogButton.right + itemSpacing;
    self.nextChapterButton.centerY = self.previousChapterButton.centerY;
    self.bottomLine.frame = CGRectMake(0, self.height - [TTDeviceHelper ssOnePixel], self.width, [TTDeviceHelper ssOnePixel]);
}

- (void)showInView:(UIView *)parentView animated:(BOOL)animated
{
    if (!self.hidden || _animating) {
        return;
    }
    //默认吸顶。后续有需求可以再调整为位置参数可控
    if (self.superview != parentView) {
        [parentView addSubview:self];
    }
    
    self.hidden = NO;
    if (animated) {
        _animating = YES;
        self.origin = CGPointMake(0, -self.height);
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.top = 0;
        } completion:^(BOOL finished) {
            _animating = NO;
        }];
    }
    else {
        self.origin = CGPointZero;
    }
}

- (void)hideWithAnimated:(BOOL)animated
{
    if (self.hidden || _animating) {
        return;
    }
    if (animated) {
        _animating = YES;
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.top = -self.height;
        } completion:^(BOOL finished) {
            self.hidden = YES;
            _animating = NO;
        }];
    }
    else {
        self.hidden = YES;
    }
}

- (void)themeChanged:(NSNotification *)notification
{
    self.backgroundColor = SSGetThemedColorWithKey(kColorBackground14);
    self.bottomLine.backgroundColor = [SSGetThemedColorWithKey(kColorLine1) CGColor];
}

- (SSThemedButton *)previousChapterButton
{
    if (!_previousChapterButton) {
        _previousChapterButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        _previousChapterButton.backgroundColor = [UIColor clearColor];
        _previousChapterButton.titleLabel.font = [UIFont systemFontOfSize:kToolItemFontSize];
        _previousChapterButton.titleColorThemeKey = kToolItemColor;
        _previousChapterButton.disabledTitleColorThemeKey = kToolItemDisableColor;
        _previousChapterButton.enabled = !isEmptyString([self _jumpSchemaWithToolItemType:ToolItemTypePre]);
        [_previousChapterButton setTitle:@"上一章" forState:UIControlStateNormal];
        [_previousChapterButton sizeToFit];
        _previousChapterButton.hitTestEdgeInsets = UIEdgeInsetsMake(-8, -8, -8, -8);
    }
    return _previousChapterButton;
}

- (SSThemedButton *)nextChapterButton
{
    if (!_nextChapterButton) {
        _nextChapterButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        _nextChapterButton.backgroundColor = [UIColor clearColor];
        _nextChapterButton.titleLabel.font = [UIFont systemFontOfSize:kToolItemFontSize];
        _nextChapterButton.titleColorThemeKey = kToolItemColor;
        _nextChapterButton.disabledTitleColorThemeKey = kToolItemDisableColor;
        _nextChapterButton.enabled = !isEmptyString([self _jumpSchemaWithToolItemType:ToolItemTypeNext]);
        [_nextChapterButton setTitle:@"下一章" forState:UIControlStateNormal];
        [_nextChapterButton sizeToFit];
        _nextChapterButton.hitTestEdgeInsets = UIEdgeInsetsMake(-8, -8, -8, -8);
    }
    return _nextChapterButton;
}

- (SSThemedButton *)catalogButton
{
    if (!_catalogButton) {
        _catalogButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        _catalogButton.backgroundColor = [UIColor clearColor];
        _catalogButton.titleLabel.font = [UIFont systemFontOfSize:kToolItemFontSize];
        _catalogButton.titleColorThemeKey = kToolItemColor;
        _catalogButton.disabledTitleColorThemeKey = kToolItemDisableColor;
        _catalogButton.enabled = !isEmptyString([self _jumpSchemaWithToolItemType:ToolItemTypeCatalog]);
        int serialCount = [_novelData intValueForKey:@"serial_count" defaultValue:0];
        NSString *title = [NSString stringWithFormat:@"目录（共%d章）", serialCount];
        [_catalogButton setTitle:title forState:UIControlStateNormal];
        [_catalogButton sizeToFit];
        _catalogButton.hitTestEdgeInsets = UIEdgeInsetsMake(-8, -8, -8, -8);
    }
    return _catalogButton;
}

- (void)toolItemFired:(id)sender
{
    NSString *jumpSchema = nil;
    NSString *label = nil;
    if (sender == self.previousChapterButton) {
        jumpSchema = [self _jumpSchemaWithToolItemType:ToolItemTypePre];
        label = @"click_pre_group";
    }
    else if (sender == self.catalogButton) {
        jumpSchema = [self _jumpSchemaWithToolItemType:ToolItemTypeCatalog];
        label = @"click_catalog";
    }
    else {
        jumpSchema = [self _jumpSchemaWithToolItemType:ToolItemTypeNext];
        label = @"click_next_group";
    }
    NSURL *jumpUrl = [NSURL URLWithString:jumpSchema];
    if ([[TTRoute sharedRoute] canOpenURL:jumpUrl]) {
        [[TTRoute sharedRoute] openURLByPushViewController:jumpUrl];
    }
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:_article.groupModel.itemID forKey:@"item_id"];
    wrapperTrackEventWithCustomKeys(@"detail", label, _article.groupModel.groupID, nil, dict);
}

- (NSString *)_jumpSchemaWithToolItemType:(ToolItemType)type
{
    NSString *jumpSchema = nil;
    if (type == ToolItemTypePre) {
        jumpSchema = [self.novelData stringValueForKey:@"pre_group_url" defaultValue:nil];
        if (isEmptyString(jumpSchema) &&
            !isEmptyString([_novelData stringValueForKey:@"pre_group_id" defaultValue:nil]) &&
            !isEmptyString([_novelData stringValueForKey:@"pre_item_id" defaultValue:nil])) {
            jumpSchema = [NSString stringWithFormat:@"sslocal://detail?groupid=%@item_id=%@", [_novelData stringValueForKey:@"pre_group_id" defaultValue:nil], [_novelData stringValueForKey:@"pre_item_id" defaultValue:nil]];
        }
    }
    else if (type == ToolItemTypeNext) {
        jumpSchema = [self.novelData stringValueForKey:@"next_group_url" defaultValue:nil];
        if (isEmptyString(jumpSchema) &&
            !isEmptyString([_novelData stringValueForKey:@"next_group_id" defaultValue:nil]) &&
            !isEmptyString([_novelData stringValueForKey:@"next_item_id" defaultValue:nil])) {
            jumpSchema = [NSString stringWithFormat:@"sslocal://detail?groupid=%@item_id=%@", [_novelData stringValueForKey:@"next_group_id" defaultValue:nil], [_novelData stringValueForKey:@"next_item_id" defaultValue:nil]];
        }
    }
    else {
        jumpSchema = [self.novelData stringValueForKey:@"url" defaultValue:nil];
    }
    return jumpSchema;
}

@end
