//
//  TTRelationFooterView.m
//  Article
//
//  Created by liuzuopeng on 9/5/16.
//
//

#import "TTRelationFooterView.h"
#import "TTProfileThemeConstants.h"



@interface TTRelationFooterView ()
@property (nonatomic, strong) SSThemedLabel *contentLabel;
@end

@implementation TTRelationFooterView

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.contentView.backgroundColorThemeKey = kColorBackground4;
        [self.contentView addSubview:self.contentLabel];
        [_contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).with.offset([TTDeviceUIUtils tt_padding:kTTProfileInsetLeft]);
            make.right.equalTo(self.contentView).with.offset(-[TTDeviceUIUtils tt_padding:kTTProfileInsetLeft]);
            make.top.bottom.equalTo(self.contentView);
            make.center.equalTo(self.contentView);
        }];
    }
    return self;
}

- (instancetype)init {
    if ((self = [self initWithFrame:CGRectZero])) {
    }
    return self;
}

- (void)reloadLabelText:(NSString *)text {
    if (!isEmptyString(text)) {
        _contentLabel.text = text;
    }
}

#pragma mark - loazied of properties

- (SSThemedLabel *)contentLabel {
    if (!_contentLabel) {
        _contentLabel = [[SSThemedLabel alloc] init];
        _contentLabel.textAlignment = NSTextAlignmentLeft;
        _contentLabel.backgroundColor = [UIColor clearColor];
        _contentLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _contentLabel.textColorThemeKey = kColorText1;
        _contentLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:34.f/2]];
    }
    return _contentLabel;
}

+ (CGFloat)height {
    return [TTDeviceUIUtils tt_padding:132.f/2];
}
@end
