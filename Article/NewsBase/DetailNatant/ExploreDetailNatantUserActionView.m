//
//  ExploreDetailNatantUserActionView.m
//  Article
//
//  Created by Zhang Leonardo on 14-10-23.
//
//

#import "ExploreDetailNatantUserActionView.h"
#import "ExploreDetailnatantActionButton.h"
#import "UIColor+TTThemeExtension.h"

#define kTopPadding 14
#define kButtonWidth 93
#define kButtonHeight 36
#define kBottomPadding 8

@interface ExploreDetailNatantUserActionView()

@property(nonatomic, retain, readwrite)ExploreDetailnatantActionButton * digButton;
@property(nonatomic, retain, readwrite)ExploreDetailnatantActionButton * buryButton;


@end

@implementation ExploreDetailNatantUserActionView


- (id)initWithWidth:(CGFloat)width
{
    self = [super initWithWidth:width];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        self.frame = CGRectMake(0, 0, width, kTopPadding + kButtonHeight + kBottomPadding);
        // buttons
        self.digButton = [[ExploreDetailnatantActionButton alloc] initIsDigButton:YES];
        _digButton.frame = [self frameForButtonIsDig:YES];
        [self addSubview:_digButton];
        
        self.buryButton = [[ExploreDetailnatantActionButton alloc] initIsDigButton:NO];
        _buryButton.frame = [self frameForButtonIsDig:NO];
        [self addSubview:_buryButton];

        [self reloadThemeUI];
    }
    return self;
}

- (CGRect)frameForButtonIsDig:(BOOL)isDigButton
{
    CGRect rect = CGRectMake(0, (self.bounds.size.height- kButtonHeight)/2, kButtonWidth , kButtonHeight);
    float padding = (self.width - 2 * kButtonWidth) / 3;
    if (isDigButton) {
        rect.origin.x = padding;
    }
    else {
        rect.origin.x = self.width - rect.size.width - padding;
    }
    return rect;
}

- (void)themeChanged:(NSNotification *)notification
{
    [super themeChanged:notification];
    self.backgroundColor = [UIColor colorWithDayColorName:@"f8f8f8" nightColorName:@"252525"];
    [_digButton refresh];
    [_buryButton refresh];
}

- (void)refreshWithWidth:(CGFloat)width
{
    self.frame = CGRectMake(0, 0, width, kTopPadding + kButtonHeight + kBottomPadding);
    [self refreshUI];
}

- (void)refreshUI
{
    _digButton.frame = [self frameForButtonIsDig:YES];
    _buryButton.frame = [self frameForButtonIsDig:NO];
}

+ (CGFloat)heightForView
{
    return kTopPadding + kButtonHeight + kBottomPadding;
}
/*
- (void)applicationStatusBarOrientationDidChanged {
    [self refreshUI];
}*/

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self refreshUI];
}

@end
