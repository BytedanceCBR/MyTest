//
//  ExploreDetailNatantForumEnterView.m
//  Article
//
//  Created by Zhang Leonardo on 15-2-2.
//
//

#import "ExploreDetailNatantForumEnterView.h"
#import "SSAppPageManager.h"
#import "TTDeviceHelper.h"
#import "UIColor+TTThemeExtension.h"
#import "TTStringHelper.h"
#import "TTThemeConst.h"

#define kHeight 75

@interface ExploreDetailNatantForumEnterView()
@property(nonatomic, assign)BOOL hasSendShowTracker;
@property(nonatomic, strong)NSDictionary * forumJson;
@property(nonatomic, retain)UIButton * button;
@property(nonatomic, retain)NSString * urlStr;
@property(nonatomic, retain)UIView * bgView;
@end

@implementation ExploreDetailNatantForumEnterView

- (id)initWithWidth:(CGFloat)width
{
    self = [super initWithWidth:width];
    if (self) {
        CGRect frame = self.frame;
        frame.size.height = kHeight;
        self.frame = frame;
        
        float padding = 12;
        
        self.bgView = [[UIView alloc] initWithFrame:CGRectMake(padding, 30, width - padding * 2, 34)];
        _bgView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:_bgView];
        
        self.button = [UIButton buttonWithType:UIButtonTypeCustom];
        _button.frame = _bgView.bounds;
        _button.backgroundColor = [UIColor clearColor];
        _button.titleLabel.font = [UIFont systemFontOfSize:15];
        [_button addTarget:self action:@selector(buttonClick) forControlEvents:UIControlEventTouchUpInside];
        _button.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _button.layer.cornerRadius = 2;
        _button.layer.borderWidth = [TTDeviceHelper ssOnePixel];
        [_bgView addSubview:_button];
        
        [self reloadThemeUI];
    }
    return self;
}

- (void)themeChanged:(NSNotification *)notification
{
    [super themeChanged:notification];
    [_button setTitleColor:[UIColor tt_themedColorForKey:kColorText5] forState:UIControlStateNormal];
    _button.layer.borderColor = [UIColor tt_themedColorForKey:kColorText5].CGColor;
}

- (void)refreshWithWidth:(CGFloat)width
{
    [super refreshWithWidth:width];
}


- (void)refreshWithJson:(NSDictionary *)jsonDict
{
    self.forumJson = jsonDict;
    self.urlStr = [jsonDict objectForKey:@"url"];
    NSString * title = [jsonDict objectForKey:@"text"];
    [_button setTitle:title forState:UIControlStateNormal];
}

- (void)buttonClick
{
    if (!isEmptyString(_urlStr)) {
        // 如果url中含有enter_from参数，则在目标viewController中解析并发送umeng统计
        if ([_urlStr rangeOfString:@"enter_from"].length == 0) {
            ssTrackEvent(@"topic_tab", @"enter_detail");
        }
        
        // 传入group_id
        NSDictionary *dict = nil;
        if (_groupId && [_urlStr rangeOfString:@"group_id"].length == 0) {
            dict = @{@"group_id":_groupId};
        }
        [[SSAppPageManager sharedManager] openURL:[TTStringHelper URLWithURLString:_urlStr] baseCondition:dict];
    }
}

- (void)sendShowTracker
{
    if (_hasSendShowTracker) {
        return;
    }
    _hasSendShowTracker = YES;
    
    NSDictionary * dict = [_forumJson objectForKey:@"show_log"];
    
    NSString * category = [dict objectForKey:@"category"];
    if (isEmptyString(category)) {
        category = @"umeng";
    }
    NSString * tag = [dict objectForKey:@"tag"];
    if (isEmptyString(tag)) {
        return;
    }
    NSString * label = [dict objectForKey:@"label"];
    if (isEmptyString(label)) {
        return;
    }
    NSDictionary * extra = [dict objectForKey:@"extra"];
    if (![extra isKindOfClass:[NSDictionary class]] || [extra count] == 0) {
        extra = nil;
    }
    NSMutableDictionary * fixedDict = [NSMutableDictionary dictionaryWithCapacity:10];
    for (NSString * key in [extra allKeys]) {
        if (isEmptyString(key)) {
            continue;
        }
        NSString * value = [extra objectForKey:key];
        if (value == nil || !([value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSNumber class]])) {
            continue;
        }
        [fixedDict setValue:value forKey:key];
    }
    
    NSMutableDictionary * sendDicts = [NSMutableDictionary dictionaryWithCapacity:10];
    [sendDicts setDictionary:fixedDict];
    [sendDicts setValue:category forKey:@"category"];
    [sendDicts setValue:label forKey:@"label"];
    [sendDicts setValue:tag forKey:@"tag"];
    [sendDicts setValue:_groupId forKey:@"ext_value"];
    [SSTracker eventData:sendDicts];
    
    
}

@end
