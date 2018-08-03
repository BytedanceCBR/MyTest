//
//  TTPGCUserFooterView.m
//  Article
//
//  Created by it-test on 8/4/16.
//
//

#import "TTPGCUserFooterView.h"
#import "TTSettingConstants.h"


@interface TTPGCUserFooterView () {
    NSString *_content;
}
@property (nonatomic, strong) SSThemedImageView *imageView;
@property (nonatomic, strong) SSThemedLabel     *contentLabel;
@end


@implementation TTPGCUserFooterView
- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.backgroundColor = [UIColor clearColor];
        
        [self addSubview:self.imageView];
        [self addSubview:self.contentLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self relayoutIfNeeded];
}

- (void)relayoutIfNeeded {
    CGFloat offsetTop  = [TTDeviceUIUtils tt_padding:36.f/2];
    CGFloat leftWidth  = [TTDeviceUIUtils tt_padding:kTTSettingInsetLeft];
    CGFloat rightWidth = [TTDeviceUIUtils tt_padding:kTTSettingInsetRight];
    CGSize  imageSize  = self.imageView.image.size;
    CGFloat offsetX    = leftWidth + imageSize.width + [TTDeviceUIUtils tt_padding:12.f/2];
    CGFloat maxWidth   = self.width - offsetX - rightWidth;
    NSString *text = self.contentLabel.text;
    CGSize    contentSize = [text boundingRectWithSize:CGSizeMake(maxWidth, 0) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : self.contentLabel.font}  context:nil].size;
    
    
    self.height = offsetTop * 2 + contentSize.height;
    self.imageView.frame = CGRectIntegral(CGRectMake(leftWidth, (self.height - imageSize.height) / 2, imageSize.width, imageSize.height));
    self.contentLabel.frame = CGRectMake(offsetX, offsetTop, contentSize.width, contentSize.height);
}

- (void)setContent:(NSString *)content {
    if (!content || _content == content) return;
    
    _content = content;
    self.contentLabel.text = content;
    
    [self relayoutIfNeeded];
}

- (NSString *)content {
    return _content ? : @"个人资料每月只能修改一次，且需要经过审核";
}

- (SSThemedLabel *)contentLabel {
    if (!_contentLabel) {
        _contentLabel = [[SSThemedLabel alloc] init];
        _contentLabel.numberOfLines = 0;
        _contentLabel.backgroundColor = [UIColor clearColor];
        _contentLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        _contentLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:kTTEditProfileHintFontSize]];
        _contentLabel.textColorThemeKey = kTTEditProfileHintColorKey;
        _contentLabel.text = self.content;
    }
    return _contentLabel;
}


- (SSThemedImageView *)imageView {
    if (!_imageView) {
        _imageView = [SSThemedImageView new];
        _imageView.clipsToBounds = YES;
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.imageName = kTTEditProfileHintImageName;
    }
    return _imageView;
}
@end

