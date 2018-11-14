//
//  ExploreMixedListSuggestionWordsView.m
//  Article
//
//  Created by chenren on 01/11/2017.
//

#import "ExploreMixedListSuggestionWordsView.h"
#import "ExploreSearchViewController.h"
#import "UIView+CustomTimingFunction.h"
#import "TTSubEntranceBar.h"
#import "TTSubEntranceObj.h"
#import "TTRoute.h"
#import "TTUISettingHelper.h"

@interface ExploreMixedListSuggestionWordsView ()

@property(nonatomic, strong) NSMutableArray *words;
@property(nonatomic, strong) NSMutableArray *oldWords;
@property(nonatomic, strong) NSMutableArray *showWords;
@property(nonatomic, strong) NSMutableArray *oldButtons;
@property(nonatomic, strong) NSMutableArray *showButtons;
@property(nonatomic, strong) NSMutableArray *dataList;

@end

@implementation ExploreMixedListSuggestionWordsView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    
        self.hidden = YES;
        
//        _words = [[NSMutableArray alloc] init];
//        _oldWords = [[NSMutableArray alloc] init];
//        _showWords = [[NSMutableArray alloc] init];
//        _oldButtons = [[NSMutableArray alloc] init];
//        _showButtons = [[NSMutableArray alloc] init];
//        _dataList = [[NSMutableArray alloc] init];
//        [self loadData];
    }
    return self;
}

- (void)loadData
{
    
    return;
    
    _oldWords = [NSMutableArray arrayWithObjects:@"", @"", @"", @"", nil];
    _showWords = [NSMutableArray arrayWithObjects:@"", @"", @"", @"", nil];
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    SSThemedView *bottomLineView = [[SSThemedView alloc] initWithFrame:CGRectMake(0, 43, width, [TTDeviceHelper ssOnePixel])];;
    bottomLineView.backgroundColorThemeKey = kColorLine1;
    [self addSubview:bottomLineView];
    
    __block CGFloat front = 15;
    CGFloat gap = 8;
    CGFloat buttonWidth = (width - 2 * front - 2 * gap) / 3.0;
    CGFloat yPos = self.height / 2 - 14;
    
    for (int i = 0; i < 3; i ++) {
        SSThemedButton *btn = [[SSThemedButton alloc] initWithFrame:CGRectMake(front, yPos, buttonWidth, 28)];
        [btn.titleLabel setFont:[UIFont systemFontOfSize:14]];
        btn.layer.borderWidth = [TTDeviceHelper ssOnePixel];
        btn.layer.cornerRadius = 4;
        btn.titleColorThemeKey = kColorText1;
        btn.highlightedTitleColorThemeKey = kColorText1Highlighted;
        btn.borderColorThemeKey = kColorLine1;
        btn.highlightedBorderColorThemeKey = kColorLine1Highlighted;
        btn.backgroundColorThemeKey = kColorBackground3;
        btn.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 6.0f, 0, 6.0f)];
        
        [btn setTitle:@"" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(didClick:) forControlEvents:UIControlEventTouchUpInside];

        btn.alpha = 0;
        btn.transform = CGAffineTransformMakeScale(0.9, 0.9);
        
        [self addSubview:btn];
        
        front += (buttonWidth + gap);
        [_showButtons addObject:btn];
    }
    
    front = 15;
    for (int i = 0; i < 3; i ++) {
        SSThemedButton *btn = [[SSThemedButton alloc] initWithFrame:CGRectMake(front, yPos, buttonWidth, 28)];
        [btn.titleLabel setFont:[UIFont systemFontOfSize:14]];
        btn.layer.borderWidth = [TTDeviceHelper ssOnePixel];
        btn.layer.cornerRadius = 4;
        btn.titleColorThemeKey = kColorText1;
        btn.highlightedTitleColorThemeKey = kColorText1Highlighted;
        btn.borderColorThemeKey = kColorLine1;
        btn.highlightedBorderColorThemeKey = kColorLine1Highlighted;
        btn.backgroundColorThemeKey = kColorBackground3;
        btn.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 6.0f, 0, 6.0f)];
        
        [btn setTitle:@"" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(didClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:btn];
        
        front += (buttonWidth + gap);
        [_oldButtons addObject:btn];
    }
}

- (void)refreshWithData:(NSArray *)array animated:(BOOL)animated superviewIsShowing:(BOOL)superviewIsShowing
{
    return;
    
    BOOL hidden = NO;
    if (!array || (([array isKindOfClass:[NSArray class]] && array.count == 0))) {
        hidden = YES;
    }
    
    for (SSThemedButton *btn in _oldButtons) {
        btn.hidden = hidden;
    }
    for (SSThemedButton *btn in _showButtons) {
        btn.hidden = hidden;
    }
    
    if ([array isKindOfClass:[NSArray class]] && array.count > 0) {
        NSMutableArray *dataList = [NSMutableArray arrayWithCapacity:array.count];
        for (NSDictionary *dict in array) {
            if ([dict isKindOfClass:[NSDictionary class]]) {
                TTSubEntranceObj *obj = [[TTSubEntranceObj alloc] initWithDictionary:dict];
                [dataList addObject:obj];
            }
        }
        self.dataList = dataList;
        
        if (!animated && superviewIsShowing) {
            NSMutableDictionary *paras  = [NSMutableDictionary dictionary];
            [paras setValue:@"feed_channel_search" forKey:@"tag"];
            [paras setValue:@"show" forKey:@"label"];
            if (self.categoryID) {
                [paras setValue:self.categoryID forKey:@"pindao"];
            }
            [TTTrackerWrapper eventV3:@"search_tab" params:paras];
        }
    } else {
        self.dataList = [NSMutableArray array];
    }
    
    if (self.dataList.count < 3 && _oldButtons.count == 3 && _showButtons.count == 3) {
        for (NSUInteger index = self.dataList.count; index < 3; index++) {
            SSThemedButton *btn1 = _oldButtons[index];
            SSThemedButton *btn2 = _showButtons[index];
            btn1.hidden = YES;
            btn2.hidden = YES;
        }
    }
    
    self.backgroundColors = [TTUISettingHelper cellViewBackgroundColors];

    [self.dataList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        TTSubEntranceObj *entryObj = (TTSubEntranceObj *)obj;
        SSThemedButton *btn = [_showButtons objectAtIndex:idx];
        [btn setTitle:entryObj.name forState:UIControlStateNormal];
        // [btn setTitle:_showWords[idx] forState:UIControlStateNormal];
        if (idx > 1) {
            *stop = YES;
        }
    }];
    
    if (!animated) {
        for (UIButton *btn in _oldButtons) {
            btn.alpha = 0;
            btn.transform = CGAffineTransformMakeScale(0.9, 0.9);
        }
        for (UIButton *btn in _showButtons) {
            btn.alpha = 1;
            btn.transform = CGAffineTransformMakeScale(1, 1);
        }
        NSMutableArray *oldArray = [_oldButtons mutableCopy];
        _oldButtons = _showButtons;
        _showButtons = oldArray;
        
        NSMutableArray *oldWords = [_oldWords mutableCopy];
        _oldWords = _showWords;
        _showWords = oldWords;
        
    } else {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            for (UIButton *btn in _showButtons) {
                [self bringSubviewToFront:btn];
            }
            
            NSTimeInterval delay1 = 0.;
            NSTimeInterval delay2 = 0.;
            for (UIButton *btn in _oldButtons) {
                [UIView animateWithDuration:0.5 customTimingFunction:CustomTimingFunctionExpoOut delay:delay1 options:0 animation:^{
                    btn.alpha = 0;
                    btn.transform = CGAffineTransformMakeScale(0.9, 0.9);
                } completion:^(BOOL finished) {
                }];
                delay1 += 0.06;
            }
            
            for (UIButton *btn in _showButtons) {
                [UIView animateWithDuration:0.5 customTimingFunction:CustomTimingFunctionExpoOut delay:delay2 options:0 animation:^{
                    btn.alpha = 1;
                    btn.transform = CGAffineTransformMakeScale(1, 1);
                } completion:^(BOOL finished) {
                }];
                
                delay2 += 0.06;
            }
            
            NSMutableArray *oldArray = [_oldButtons mutableCopy];
            _oldButtons = _showButtons;
            _showButtons = oldArray;
            
            NSMutableArray *oldWords = [_oldWords mutableCopy];
            _oldWords = _showWords;
            _showWords = oldWords;
        });
    }
}

- (void)didClick:(UIButton *)button
{
    return;
    
    NSMutableDictionary *paras  = [NSMutableDictionary dictionary];
    [paras setValue:@"feed_channel_search" forKey:@"tag"];
    [paras setValue:@"click" forKey:@"label"];
    if (self.categoryID) {
        [paras setValue:self.categoryID forKey:@"pindao"];
    }
    [TTTrackerWrapper eventV3:@"search_tab" params:paras];
    
    NSInteger index = [_oldButtons indexOfObject:button];
    if (index >= 0 && index < 3 && index < self.dataList.count) {
        TTSubEntranceObj *entryObj = [self.dataList objectAtIndex:index];
        NSString *url = entryObj.openUrl;
        [[TTRoute sharedRoute] openURLByPushViewController:[TTStringHelper URLWithURLString:url]];
    }
}

@end
