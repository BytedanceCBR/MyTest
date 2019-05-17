//
//  TTSegmentedControl.m
//  Article
//
//  Created by yuxin on 11/26/15.
//
//

#import "TTSegmentedControl.h"
#import "TTBadgeNumberView.h"
#import "UIColor+TTThemeExtension.h"
#import "TTThemeManager.h"


@implementation TTSegmentedControl

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(themeChanged:) name:TTThemeManagerThemeModeChangedNotification object:nil];

    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(themeChanged:) name:TTThemeManagerThemeModeChangedNotification object:nil];

    }
    return self;

}

- (instancetype)initWithItems:(NSArray *)items {
    self = [super initWithItems:items];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(themeChanged:) name:TTThemeManagerThemeModeChangedNotification object:nil];

        self.badgeViews = [NSMutableArray array];
        for (NSInteger i = 0; i<items.count; i++) {
            TTBadgeNumberView * badgeView = [[TTBadgeNumberView alloc] init];
            badgeView.badgeNumber = TTBadgeNumberHidden;
            badgeView.badgeViewStyle = TTBadgeNumberViewStyleDefault;
            [self addSubview:badgeView];
            [self.badgeViews addObject:badgeView];

        }
        

    }
    return self;
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    NSInteger index = 0;
    for (TTBadgeNumberView * badgeView in self.badgeViews) {
        
        badgeView.center = CGPointMake(self.frame.size.width/3 + self.frame.size.width/3*index, 0);
        index++;
        [self bringSubviewToFront:badgeView];
    }

}

- (void)willMoveToWindow:(UIWindow *)newWindow {

    [super willMoveToWindow:newWindow];
    self.tintColor = [UIColor tt_themedColorForKey:self.backgroundColorThemeKey];

}

- (void)themeChanged:(NSNotification*)noti {
 
    self.tintColor = [UIColor tt_themedColorForKey:self.backgroundColorThemeKey];

}

//override this method for click twice
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    NSInteger previousSelectedSegmentIndex = self.selectedSegmentIndex;
    [super touchesEnded:touches withEvent:event];
     // on iOS7 the segment is selected in touchesEnded
    if (previousSelectedSegmentIndex == self.selectedSegmentIndex) {
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
    
}
 
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
