//
//  TSVTagInfoView.m
//  HTSVideoPlay
//
//  Created by 王双华 on 2017/10/13.
//

#import "TSVTagInfoView.h"
#import <TTThemed/SSThemed.h>
#import "TTThemeManager.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import "UIViewAdditions.h"

#define kTagInfoLabelFontSize 12

NS_INLINE CGFloat TSVVideoDetailControlOverlayTagInfoLabelMaxWidth()
{
    static CGFloat maxWidth = 0.f;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *maxStr = @"一二三四五六七";
        CGSize maxSize = [maxStr sizeWithAttributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:kTagInfoLabelFontSize]}];
        maxWidth = ceil(maxSize.width);
    });
    return maxWidth;
}

@interface TSVTagInfoView()

@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) SSThemedImageView *topicImageView;
@property (nonatomic, strong) UILabel *tagInfoLabel;
@property (nonatomic, assign) BOOL nightThemeEnabled;
@property (nonatomic, strong) SSThemedImageView *arrowImageView;

@end

@implementation TSVTagInfoView

+ (CGFloat)maxContainerWidth
{
    return TSVVideoDetailControlOverlayTagInfoLabelMaxWidth() + 12.f;
}

- (instancetype)initWithNightThemeEnabled:(BOOL)enabled
{
    if (self = [super init]) {
        self.layer.cornerRadius = 4;
        
        self.style = TSVTagInfoViewStyleDefault;
        
        self.nightThemeEnabled = enabled;
        
        self.tagInfoLabel = ({
            UILabel *label = [[UILabel alloc] init];
            label.font = [UIFont boldSystemFontOfSize:kTagInfoLabelFontSize];
            label.lineBreakMode = NSLineBreakByTruncatingTail;
            label.textAlignment = NSTextAlignmentCenter;
            [self addSubview:label];
            label;
        });
        
        self.topicImageView = ({
            SSThemedImageView *imageView = [[SSThemedImageView alloc] init];
            [self addSubview:imageView];
            imageView.hidden = YES;
            imageView;
        });
        
        self.arrowImageView = ({
            SSThemedImageView *imageView = [[SSThemedImageView alloc] init];
            [self addSubview:imageView];
            imageView.hidden = YES;
            imageView;
        });
        
        self.button = ({
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [self addSubview:btn];
            btn;
        });
        
        @weakify(self);
        [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:TTThemeManagerThemeModeChangedNotification object:nil]
          takeUntil:self.rac_willDeallocSignal]
         subscribeNext:^(NSNotification * _Nullable x) {
             @strongify(self);
             [self refreshUI];
         }];
        
        [self refreshUI];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [UIView setAnimationsEnabled:NO];
    if (self.style == TSVTagInfoViewStyleActivity) {
        self.topicImageView.imageName = @"tsv_red_jing";
        self.topicImageView.frame = CGRectMake(6, 0, 11, 10);
        self.topicImageView.centerY = self.height / 2;
        self.tagInfoLabel.frame = CGRectMake(19, 0, self.width - 25, self.height);
    } else if (self.style == TSVTagInfoViewStyleChallenge) {
        self.topicImageView.imageName = @"tsv_video_pk";
        self.topicImageView.frame = CGRectMake(6, 0, 16, 11);
        self.topicImageView.centerY = self.height / 2;
        self.tagInfoLabel.frame = CGRectMake(28, 0, self.width - 42, self.height);
        
        self.arrowImageView.imageName = @"tsv_video_more";
        self.arrowImageView.frame = CGRectMake(0, 0, 6, 10);
        self.arrowImageView.centerY = self.height / 2;
        self.arrowImageView.right = self.width - 6;
    } else {
        self.tagInfoLabel.frame = CGRectMake(6, 0, self.width - 12, self.height);
    }
    self.button.frame = self.bounds;
    [self.button setHitTestEdgeInsets:UIEdgeInsetsMake(-12, 0, -12, 0)];//按钮点击区域 高度为44
    [UIView setAnimationsEnabled:YES];
}

- (void)refreshTagWithText:(NSString *)text
{
    self.tagInfoLabel.text = text;
}

- (CGFloat)originalContainerWidth
{
    CGSize labelSize = [self.tagInfoLabel.text sizeWithAttributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:kTagInfoLabelFontSize]}];
    if (self.style == TSVTagInfoViewStyleActivity) {
        //留白 + # + 留白 + 文字 + 留白
        return 6 + 11 + 2 + ceil(labelSize.width) + 6;
    } else if (self.style == TSVTagInfoViewStyleChallenge) {
        //留白 + pk + 留白 + 文字 + 留白 + > + 留白
        return 6 + 16 + 6 + ceil(labelSize.width) + 2 + 6 + 6;
    } else {
        //留白 + 文字 + 留白
        return 6 + ceil(labelSize.width) + 6;
    }
}

- (void)setStyle:(TSVTagInfoViewStyle)style
{
    _style = style;
    
    [self refreshUI];
    [self setNeedsLayout];
}

- (void)refreshUI
{
    switch (self.style) {
        case TSVTagInfoViewStyleNewDetail:
        {
            self.backgroundColor = [UIColor colorWithWhite:1 alpha:0.8];
            self.tagInfoLabel.textColor = [UIColor colorWithRed:34/255.0 green:34/255.0 blue:34/255.0 alpha:1/1.0];
        }
            break;
        case TSVTagInfoViewStyleDefault:
        {
            self.backgroundColor = [UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.35f];
            
            if (self.nightThemeEnabled) {
                self.tagInfoLabel.textColor = SSGetThemedColorWithKey(kColorText10);
            } else {
                self.tagInfoLabel.textColor = [UIColor whiteColor];
            }
        }
            break;
        case TSVTagInfoViewStyleRelationship:
        {
            self.backgroundColor = SSGetThemedColorInArray(@[@"f85959b2", @"935656b2"]);
            self.tagInfoLabel.textColor = SSGetThemedColorWithKey(kColorText12);
        }
            break;
        case TSVTagInfoViewStyleActivity:
        {
            self.backgroundColor = [UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.4f];
            
            if (self.nightThemeEnabled) {
                self.tagInfoLabel.textColor = SSGetThemedColorWithKey(kColorText10);
            } else {
                self.tagInfoLabel.textColor = [UIColor whiteColor];
            }
            self.topicImageView.hidden = NO;
        }
            break;
        case TSVTagInfoViewStyleChallenge:
        {
            self.backgroundColor = [UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.4f];
            
            if (self.nightThemeEnabled) {
                self.tagInfoLabel.textColor = SSGetThemedColorWithKey(kColorText10);
            } else {
                self.tagInfoLabel.textColor = [UIColor whiteColor];
            }
            self.topicImageView.hidden = NO;
            self.arrowImageView.hidden = NO;
        }
            break;
    }
}

- (void)addTarget:(id)target action:(SEL)action
{
    [self.button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
}
@end
