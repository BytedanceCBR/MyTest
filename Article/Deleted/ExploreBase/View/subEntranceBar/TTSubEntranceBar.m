//
//  TTSubEntranceBar.m
//  Article
//
//  Created by Chen Hong on 15/6/23.
//
//

#import "TTSubEntranceBar.h"
#import "TTSubEntranceObj.h"
#import "SSThemed.h"
#import "TTRoute.h"

#import "ExploreArticleCellViewConsts.h"
#import "NewsUserSettingManager.h"
#import "TTUISettingHelper.h"
#import "TTDeviceHelper.h"
#import "TTStringHelper.h"

#import "TTUserSettings/TTUserSettingsManager+FontSettings.h"

#define kButtonMinW 36
#define kButtonH 28
#define kButtonY 10
#define kButtonGap 6

@interface TTSubEntranceBar ()
@property(nonatomic,strong)NSMutableArray *buttons;
@property(nonatomic,strong)NSArray *dataList;
@property(nonatomic,strong)SSThemedView *bottomLineView;
@end

@implementation TTSubEntranceBar

- (instancetype)initWithFrame:(CGRect)frame {
    frame.size.height = kButtonY*2 + kButtonH;
    self = [super initWithFrame:frame];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fontSizeChanged) name:kSettingFontSizeChangedNotification object:nil];
        self.backgroundColor = [TTUISettingHelper cellViewBackgroundColor];
        self.buttons = [NSMutableArray array];
        CGFloat padding = [self leftPadding];
        self.bottomLineView = [[SSThemedView alloc] initWithFrame:CGRectMake(padding, self.height-[TTDeviceHelper ssOnePixel], self.width-padding*2, [TTDeviceHelper ssOnePixel])];
        self.bottomLineView.backgroundColorThemeKey = kColorLine1;
        [self addSubview:self.bottomLineView];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kSettingFontSizeChangedNotification object:nil];
}

- (void)refreshWithData:(NSArray *)array
{
    if ([array isKindOfClass:[NSArray class]] && array.count > 0) {
        NSMutableArray *dataList = [NSMutableArray arrayWithCapacity:array.count];
        for (NSDictionary *dict in array) {
            if ([dict isKindOfClass:[NSDictionary class]]) {
                TTSubEntranceObj *obj = [[TTSubEntranceObj alloc] initWithDictionary:dict];
                [dataList addObject:obj];
            }
        }
        self.dataList = dataList;
    } else {
        self.dataList = [NSArray array];
    }

    float fontSize = [NewsUserSettingManager fontSizeFromNormalSize:12.0 isWidescreen:[TTDeviceHelper isScreenWidthLarge320]];
    
    [self.dataList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        TTSubEntranceObj *entryObj = (TTSubEntranceObj *)obj;
        SSThemedButton *btn;
        if (idx >= self.buttons.count) {
            btn = [[SSThemedButton alloc] initWithFrame:CGRectZero];
            [btn.titleLabel setFont:[UIFont systemFontOfSize:fontSize]];
            btn.layer.borderWidth = [TTDeviceHelper ssOnePixel];
            btn.layer.cornerRadius = kButtonH/2;
            
            btn.titleColorThemeKey = kColorText2;
            btn.highlightedTitleColorThemeKey = kColorText2Highlighted;
            btn.backgroundColors = [TTUISettingHelper cellViewBackgroundColors];
            btn.highlightedBackgroundColors = [TTUISettingHelper cellViewHighlightedBackgroundColors];
            btn.borderColorThemeKey = kColorLine1;
            btn.highlightedBorderColorThemeKey = kColorLine1Highlighted;
            
            [btn addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:btn];
            btn.tag = idx;
            
            [self.buttons addObject:btn];
        } else {
            btn = [self.buttons objectAtIndex:idx];
        }

        btn.hidden = NO;
        [btn setTitle:entryObj.name forState:UIControlStateNormal];
        
    }];
    
    for (NSUInteger index = self.dataList.count; index < self.buttons.count; ++index) {
        SSThemedButton *btn = self.buttons[index];
        btn.hidden = YES;
    }
    [self setNeedsLayout];
}

- (void)themeChanged:(NSNotification*)notification {
    self.backgroundColor = [TTUISettingHelper cellViewBackgroundColor];
}

- (void)fontSizeChanged {
    float fontSize = [NewsUserSettingManager fontSizeFromNormalSize:12.0 isWidescreen:[TTDeviceHelper isScreenWidthLarge320]];
    for (NSUInteger idx = 0; idx < self.buttons.count; ++idx) {
        SSThemedButton *btn = self.buttons[idx];
        [btn.titleLabel setFont:[UIFont systemFontOfSize:fontSize]];
    }
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat padding = [self leftPadding];
    
    CGFloat x = padding;
    
    NSUInteger idx = 0;
    
    UIButton *lastVisibleButton = nil;
    
    BOOL needCheckMoreButton = NO;
    
    for (; idx < self.dataList.count; ++idx) {
        SSThemedButton *btn = self.buttons[idx];
        
        [btn sizeToFit];

        CGFloat w;
        
        if (btn.width < kButtonMinW) {
            btn.width = kButtonMinW;
        }

        w = btn.width + 16;
        
        btn.frame = CGRectMake(x, kButtonY, w, kButtonH);
        
        if (x + w > self.frame.size.width - padding) {
            btn.hidden = YES;
            needCheckMoreButton = YES;
            break;
        } else {
            btn.hidden = NO;
        }
        
        x += w + 6;
        lastVisibleButton = btn;
    }
    
    for (; idx < self.buttons.count; ++idx) {
        SSThemedButton *btn = self.buttons[idx];
        btn.hidden = YES;
    }
    
    // 将更多按钮提到可见范围内的最后一个
    if (needCheckMoreButton) {
        TTSubEntranceObj *entryObj = self.dataList.lastObject;
        if ([entryObj.name isEqualToString:NSLocalizedString(@"更多", nil)]) {
            if (self.buttons.count >= self.dataList.count) {
                UIButton *moreButton = self.buttons[self.dataList.count - 1];
                [moreButton sizeToFit];
                
                CGFloat w;
                
                if (moreButton.width < kButtonMinW) {
                    moreButton.width = kButtonMinW;
                }
                
                w = moreButton.width + 16;
            
                moreButton.frame = lastVisibleButton.frame;
                moreButton.width = w;
                lastVisibleButton.hidden = YES;
                moreButton.hidden = NO;
            }
        }
    }
    
    self.bottomLineView.frame = CGRectMake(padding, self.height-[TTDeviceHelper ssOnePixel], self.width-padding*2, [TTDeviceHelper ssOnePixel]);
}

- (void)clickButton:(id)sender {
    NSUInteger index = ((UIButton *)sender).tag;
    if (index < self.dataList.count) {
        TTSubEntranceObj *entryObj = self.dataList[index];
        NSString *url = entryObj.openUrl;
        [[TTRoute sharedRoute] openURLByPushViewController:[TTStringHelper URLWithURLString:url]];
    }
}

- (CGFloat)leftPadding {
    if ([TTDeviceHelper isPadDevice]) {
        
        CGFloat padding = [TTUIResponderHelper paddingForViewWidth:0] + kCellLeftPadding;
        return padding;
        
    } else {
        return kCellLeftPadding;
    }
}

@end
