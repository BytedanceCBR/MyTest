//
//  TTVideoDurationView.m
//  Article
//
//  Created by xuzichao on 2016/12/20.
//
//

#import "TTVideoDurationView.h"
#import "SSThemed.h"
#import "TTDeviceUIUtils.h"
#import "UIViewAdditions.h"

#define TTVideoDurationViewWidthMargin  5
#define TTVideoDurationViewHeightMargin 3
#define TTVideoDurationViewPadding 2

@interface TTVideoDurationView ()

@property (nonatomic, strong) SSThemedLabel *videoDurationLabel;
@property (nonatomic, strong) SSThemedImageView *iconView;
@property (nonatomic, strong) SSThemedView *backView;

@end

@implementation TTVideoDurationView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backView = [[SSThemedView alloc] init];
        self.backView.backgroundColor = [UIColor blackColor];
        self.backView.layer.opacity = 0.3;
        self.backView.frame = self.bounds;
        [self addSubview:self.backView];
        
        self.iconView = [[SSThemedImageView alloc] init];
        self.iconView.imageName = @"palyicon_video_textpage";
        [self addSubview:self.iconView];
        
        self.videoDurationLabel = [[SSThemedLabel alloc] init];
        self.videoDurationLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:10]];
        self.videoDurationLabel.textColorThemeKey = kColorText12;
        self.videoDurationLabel.layer.masksToBounds = YES;
        self.videoDurationLabel.textAlignment = NSTextAlignmentCenter;
        [self.videoDurationLabel setText:@"视频"];
        [self addSubview:self.videoDurationLabel];
    }
    
    return self;
}

- (void)showLeftImage:(BOOL)show
{
    self.iconView.hidden = !show;
    [self refreshSubviews];
}

- (void)setLeftImage:(NSString *)imageName
{
    self.iconView.imageName = imageName;
    [self refreshSubviews];
}

- (void)setDurationText:(NSString *)text
{
    self.videoDurationLabel.text = text;
    [self refreshSubviews];
}

- (void)refreshSubviews
{
    [self.videoDurationLabel sizeToFit];
    CGSize textSize = self.videoDurationLabel.size;
    CGSize iconSize = self.iconView.image.size;
    
    if (self.iconView.hidden) {
        if (self.isLightStyle) {
            self.width = textSize.width + 2*6;
        } else {
           self.width = 44;
        }
        self.height = 20;
        
        self.videoDurationLabel.centerY = self.height/2;
        self.videoDurationLabel.centerX = self.width/2;
    }
    else {
        self.width = textSize.width + iconSize.width + 2*TTVideoDurationViewWidthMargin + TTVideoDurationViewPadding;
        self.height = textSize.height + 2*TTVideoDurationViewHeightMargin;
        
        self.iconView.width = iconSize.width;
        self.iconView.height = iconSize.height;
        self.iconView.centerY = self.height/2;
        self.iconView.left = TTVideoDurationViewWidthMargin;
        
        self.videoDurationLabel.centerY = self.height/2;
        self.videoDurationLabel.right = self.width - TTVideoDurationViewWidthMargin;
    }
    
    self.backView.frame = self.bounds;
    self.backView.layer.cornerRadius = self.height/2;
    
}

@end
