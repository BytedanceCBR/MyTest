//
//  ExploreSearchHotView.m
//  Article
//
//  Created by SunJiangting on 15-1-20.
//
//

#import "ExploreSearchHotView.h"
#import "TTDeviceHelper.h"

@interface ExploreSearchHotButton : SSThemedButton


@end

@implementation ExploreSearchHotButton

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.imageView sizeToFit];
    [self.titleLabel sizeToFit];
    self.imageView.origin = CGPointMake((self.width - self.imageView.width) / 2, 0);
    self.titleLabel.origin = CGPointMake((self.width - self.titleLabel.width) / 2, self.imageView.bottom + 7);
}

@end

@interface ExploreSearchHotView ()

@property (nonatomic, strong) SSThemedLabel *titleLabel;
@property (nonatomic, strong) NSMutableArray *buttonArray;
@property (nonatomic, strong) SSThemedView *separatorView;

@end

@implementation ExploreSearchHotView

- (instancetype)initWithFrame:(CGRect)frame {
    UIWindow *window = SSGetMainWindow();
    CGFloat separatorWidth = CGRectGetWidth(window.bounds) * 0.593;
    if (frame.size.width < separatorWidth) {
        frame.size.width = separatorWidth;
    }
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat topPadding,titleLabelFontSize,gapBelowTitleLabel,gapBelowSeparatorView,marginWidth;
        gapBelowTitleLabel = 15;
        gapBelowSeparatorView = 18;
        if ([TTDeviceHelper is736Screen] || [TTDeviceHelper isPadDevice]) {
            topPadding = 90;
            titleLabelFontSize = 22;
            marginWidth = 60;
        }
        else if ([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]){
            topPadding = 70;
            titleLabelFontSize = 20;
            marginWidth = 50;
        }
        else{
            topPadding = 45;
            titleLabelFontSize = 19;
            marginWidth = 40;
        }
        self.backgroundColorThemeKey = kColorBackground4;
        SSThemedView *containerView = [[SSThemedView alloc] initWithFrame:CGRectMake(0, 0, self.width, 120)];
        [self addSubview:containerView];
        
        self.titleLabel = ({
            SSThemedLabel *titleLabel = [[SSThemedLabel alloc] initWithFrame:CGRectMake(0, topPadding, containerView.width, 24)];
            titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth |UIViewAutoresizingFlexibleHeight;
            titleLabel.textColorThemeKey = kColorText2;
            titleLabel.textAlignment = NSTextAlignmentCenter;
            titleLabel.font = [UIFont systemFontOfSize:titleLabelFontSize];
            titleLabel.backgroundColor = [UIColor clearColor];
            [containerView addSubview:titleLabel];
            titleLabel;
        });
        
        self.titleLabel.text = NSLocalizedString(@"搜索感兴趣的内容", nil);

        self.separatorView = [[SSThemedView alloc] initWithFrame:CGRectMake(marginWidth, self.titleLabel.bottom + gapBelowTitleLabel, self.width - 2*marginWidth, [TTDeviceHelper ssOnePixel])];
        self.separatorView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        self.separatorView.backgroundColorThemeKey = kColorLine7;
        [containerView addSubview:self.separatorView];
        
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat topPadding,titleLabelFontSize,gapBelowTitleLabel,gapBelowSeparatorView,marginWidth;
    
    gapBelowTitleLabel = 15;
    gapBelowSeparatorView = 18;
    
    if ([TTDeviceHelper is736Screen]) {
        topPadding = 90;
        titleLabelFontSize = 22;
        marginWidth = 60;
    }
    else if ([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]) {
        topPadding = 70;
        titleLabelFontSize = 20;
        marginWidth = 50;
    }
    else{
        topPadding = 45;
        titleLabelFontSize = 19;
        marginWidth = 40;
    }
    
    self.titleLabel.centerX = self.centerX;
    
    self.separatorView.frame = CGRectMake(marginWidth, self.titleLabel.bottom + gapBelowTitleLabel, self.width - 2*marginWidth, [TTDeviceHelper ssOnePixel]);
}

@end
