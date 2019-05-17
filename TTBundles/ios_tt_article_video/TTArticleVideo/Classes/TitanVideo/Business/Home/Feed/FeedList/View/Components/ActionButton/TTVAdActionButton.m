//
//  TTVAdActionButton.m
//  Article
//
//  Created by pei yun on 2017/3/31.
//
//

#import "TTVAdActionButton.h"

@interface TTVAdActionButton ()

@property (nonatomic, strong) TTTouchContext *lastTouchContext;

@end

@implementation TTVAdActionButton

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
//        self.backgroundColorThemeKey = kColorBackground4;
        self.titleColorThemeKey = kColorText6;
        self.borderColorThemeKey = kColorText6;
        
        self.titleLabel.font = [UIFont systemFontOfSize:12.0f];
        self.titleLabel.textColor = [UIColor tt_themedColorForKey:kColorText6];
        self.layer.cornerRadius = 6;
        self.layer.masksToBounds = YES;
        self.layer.borderWidth = 0;
        
        self.backgroundColorThemeKey = nil;
        self.backgroundColors = nil;
        
        self.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        
        self.imageEdgeInsets = UIEdgeInsetsZero;
        self.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);
    }
    return self;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = event.allTouches.anyObject;
    CGPoint point =  [touch locationInView:touch.view];
    TTTouchContext *context = [TTTouchContext new];
    context.targetView = self;
    context.touchPoint = point;
//    context.canvasSize = self.bounds.size;
    self.lastTouchContext = context;
    [super touchesEnded:touches withEvent:event];
}

- (void)sendClickActionShowAlert:(BOOL)showAlert
{
    //    [ExploreMovieView stopAllExploreMovieView];
}

- (void)setIconImageNamed:(NSString *)imageName {
    if (imageName) {
        self.imageName = imageName;
        self.imageEdgeInsets = UIEdgeInsetsMake(0, -5, 0, 0);
        self.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);
    } else {
        self.imageName = nil;
        [self setImage:nil forState:UIControlStateNormal];
        self.titleEdgeInsets = UIEdgeInsetsZero;
    }
}

- (void)refreshCreativeIcon {
    if (self.showIcon) {//[self.adModel showActionButtonIcon]
        [self setIconImageNamed:self.imageName];
    } else {
        [self setIconImageNamed:nil];
    }
}

- (void)refreshForceCreativeIcon {
    [self setIconImageNameForVideoAdCell:self.imageName];
}

- (void)setIconImageNameForVideoAdCell:(NSString *)imageName {
    if (imageName) {
        self.imageName = imageName;
        self.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        self.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);
    } else {
        self.imageName = nil;
        [self setImage:nil forState:UIControlStateNormal];
        self.titleEdgeInsets = UIEdgeInsetsZero;
    }
}

@end

@implementation TTVAdActionTypeAppButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.imageName = @"download_ad_feed";
    }
    return self;
}
@end

@implementation TTVAdActionTypeWebButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.imageName = @"view detail_ad_feed";
    }
    return self;
}

@end

@implementation TTVAdActionTypePhoneButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.imageName = @"cellphone_ad_feed";
    }
    return self;
}
@end

@implementation TTVAdActionTypeFormButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.imageName = @"view detail_ad_feed";
    }
    return self;
}

@end


@implementation TTVAdActionTypeCounselButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.imageName = @"counsel_ad_feed";
    }
    return self;
}

@end

@implementation TTVAdActionTypeNormalButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.imageName = @"view detail_ad_feed";
    }
    return self;
}

@end
