//
//  WDListTagImageView.m
//  TTWenda
//
//  Created by wangqi.kaisa on 2018/1/3.
//

#import "WDListTagImageView.h"
#import <TTBaseLib/TTDeviceHelper.h>
#import <TTBaseLib/UIViewAdditions.h>
#import <TTThemed/UIImage+TTThemeExtension.h>
#import "WDFontDefines.h"

@interface WDListTagImageView ()

@property (nonatomic, strong) SSThemedImageView *tagView; //图标的背景
@property (nonatomic, strong) SSThemedLabel *tagLabel;    //用来显示长图、横图等
@property (nonatomic, strong) SSThemedLabel *extraLabel;  //用来显示额外还有几张图

@end

@implementation WDListTagImageView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.extraLabel];
        [self addSubview:self.tagView];
    }
    return self;
}

- (void)setTagLabelText:(NSString *)text {
    [self setTagLabelText:text position:WDTagImageViewPositionBottom];
}

- (void)setTagLabelText:(NSString *)text position:(WDTagImageViewPosition)position {
    if (!isEmptyString(text)) {
        self.tagView.hidden = NO;
        self.tagLabel.text = text;
        [self.tagLabel sizeToFit];
        
        CGFloat tagWidth = ceilf(self.tagLabel.size.width) + 6 * 2;
        self.tagView.frame = CGRectMake(self.width - tagWidth - 4, self.height - 20 - 4, tagWidth, 20);
        self.tagLabel.center = CGPointMake(self.tagView.width / 2, self.tagView.height / 2);
        if (position != WDTagImageViewPositionBottom) {
            self.tagView.top = 4;
        } else {
            self.tagView.bottom = self.height - 4;
        }
        self.tagView.right = self.width - 4;
    } else {
        self.tagView.hidden = YES;
    }
    self.extraLabel.hidden = YES;
}

- (void)setExtraCount:(NSString *)extraCount {
    if (isEmptyString(extraCount)) {
        self.extraLabel.hidden = YES;
    } else {
        self.extraLabel.hidden = NO;
        self.extraLabel.text = extraCount;
    }
}

+ (CGFloat)extraCountFontSize {
    return [TTDeviceHelper isScreenWidthLarge320] ? 17.f : 15.f;
}

- (SSThemedImageView *)tagView {
    if (!_tagView) {
        _tagView = [[SSThemedImageView alloc] initWithFrame:CGRectMake(self.width - 34 - 4, self.height - 20 - 4, 34, 20)];
        UIImage *image = [UIImage themedImageNamed:@"message_background_view"];
        image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(image.size.height / 2, image.size.width / 2, image.size.height / 2 - 1, image.size.width / 2 - 1) resizingMode:UIImageResizingModeTile];
        _tagView.image = image;
        _tagView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        [_tagView addSubview:self.tagLabel];
        //放在遮罩上面
        _tagView.layer.zPosition = 1;
    }
    
    return _tagView;
}

- (SSThemedLabel *)tagLabel {
    if (!_tagLabel) {
        _tagLabel = [[SSThemedLabel alloc] init];
        _tagLabel.font = [UIFont systemFontOfSize:10];
        _tagLabel.textColor = [UIColor tt_defaultColorForKey:kColorText12];
        _tagLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _tagLabel;
}

- (SSThemedLabel *)extraLabel {
    if (!_extraLabel) {
        _extraLabel = [[SSThemedLabel alloc] initWithFrame:self.bounds];
        _extraLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _extraLabel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
        _extraLabel.font = [UIFont boldSystemFontOfSize:[WDListTagImageView extraCountFontSize]];
        _extraLabel.textAlignment = NSTextAlignmentCenter;
        _extraLabel.textColorThemeKey = kColorText12;
    }
    return _extraLabel;
}

@end
