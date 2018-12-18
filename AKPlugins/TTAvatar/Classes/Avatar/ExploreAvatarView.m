//
//  ExploreAvatarView.m
//  Article
//
//  Created by SunJiangting on 14-9-11.
//
//

#import "ExploreAvatarView.h"

// TTBaseLib
#import "UIImageAdditions.h"

// TTThemed
#import "UIImage+TTThemeExtension.h"
#import "TTThemeManager.h"

@interface ExploreAvatarView ()

@property (nonatomic, strong) UITapGestureRecognizer * tapGestureRecognizer;
@property (nonatomic, strong) UIImage *placeholderImage;

@end
@implementation ExploreAvatarView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.imageView = [[TTImageView alloc] initWithFrame:self.bounds];
        self.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:self.imageView];
        
        self.highlightedMaskView = [[SSThemedView alloc] initWithFrame:self.bounds];
        self.highlightedMaskView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.highlightedMaskView.userInteractionEnabled = NO;
        self.highlightedMaskView.backgroundColor = [UIColor colorWithWhite:0x0 alpha:0.3];
        [self addSubview:self.highlightedMaskView];
        self.highlightedMaskView.hidden = YES;
        
        self.blackMaskView = [[SSThemedView alloc] initWithFrame:self.bounds];
        self.blackMaskView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.blackMaskView.userInteractionEnabled = NO;
        self.blackMaskView.backgroundColor = [UIColor colorWithWhite:0 alpha:.05];
        [self addSubview:self.blackMaskView];
        self.blackMaskView.hidden = YES;
        
        UITapGestureRecognizer * tapGestureRecognizer = [[UITapGestureRecognizer alloc] init];
        [self addGestureRecognizer:tapGestureRecognizer];
        self.tapGestureRecognizer = tapGestureRecognizer;
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.enableRoundedCorner) {
        self.imageView.layer.cornerRadius = self.imageView.bounds.size.width / 2;
        self.imageView.layer.masksToBounds = YES;
    } else {
        self.imageView.layer.cornerRadius = 0;
        self.imageView.layer.masksToBounds = NO;
    }
    self.blackMaskView.hidden = !self.enableBlackMaskView || [TTThemeManager sharedInstance_tt].currentThemeMode == TTThemeModeNight;
    if (self.enableBlackMaskView){
        self.blackMaskView.layer.cornerRadius = self.imageView.layer.cornerRadius;
        self.blackMaskView.layer.masksToBounds = self.imageView.layer.masksToBounds;
    }
}

- (void)themeChanged:(NSNotification*)notification {
    [super themeChanged:notification];
    self.placeholder = _placeholder;
    self.blackMaskView.hidden = !_enableBlackMaskView || [TTThemeManager sharedInstance_tt].currentThemeMode == TTThemeModeNight;
}

- (void)setPlaceholder:(NSString *)placeholder {
    _placeholder = [placeholder copy];
    if (_placeholder.length > 0) {
        self.placeholderImage = [UIImage themedImageNamed:_placeholder];
    } else {
        self.placeholderImage = nil;
    }
}

-(void)setDisableNightMode:(BOOL)disableNightMode
{
    _disableNightMode = disableNightMode;
    self.imageView.enableNightCover = !disableNightMode;
}

- (void)setEnableBlackMaskView:(BOOL)enableBlackMaskView
{
    _enableBlackMaskView = enableBlackMaskView;
    [self setNeedsLayout];
}

- (void)setImageWithURLString:(NSString *)URLString {
    //FIX:similar to XWTT-2885, avatar should not use originImage
    if ([URLString rangeOfString:@"/origin/"].location != NSNotFound) {
        URLString = [URLString stringByReplacingOccurrencesOfString:@"/origin/" withString:@"/thumb/"];
    }
    
    [self.imageView setImageWithURLString:URLString placeholderImage:self.placeholderImage];
}

- (void)addTouchTarget:(id) target action:(SEL)action {
    [self.tapGestureRecognizer addTarget:target action:action];
}

- (void)removeTouchTarget:(id) target action:(SEL)action {
    [self.tapGestureRecognizer removeTarget:target action:action];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    self.highlightedMaskView.hidden = NO;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    self.highlightedMaskView.hidden = YES;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    self.highlightedMaskView.hidden = YES;
}

@end
