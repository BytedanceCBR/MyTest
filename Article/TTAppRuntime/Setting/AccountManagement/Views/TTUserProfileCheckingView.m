//
//  TTUserProfileCheckingView.m
//  Article
//
//  Created by it-test on 8/5/16.
//
//

#import "TTUserProfileCheckingView.h"
#import "TTSettingConstants.h"


#define kTTCheckingColor (@"f85959")


@interface TTUserProfileCheckingView ()
@property (nonatomic, strong) SSThemedLabel *checkinglabel;
@end


@implementation TTUserProfileCheckingView
- (instancetype)initWithText:(NSString *)text {
    if ((self = [self init])) {
        if (text) self.checkinglabel.text = text;
    }
    return self;
}

- (instancetype)init {
    if ((self = [super init])) {
        self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = YES;
        self.layer.borderWidth = [TTDeviceHelper ssOnePixel];
        self.layer.cornerRadius = 3;
        self.layer.borderColor = [[UIColor colorWithHexString:kTTCheckingColor] CGColor];
        
        [self addSubview:self.checkinglabel];
        [self.checkinglabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
            make.size.equalTo(self);
        }];
    }
    return self;
}

- (CGSize)sizeForFit {
    NSString *text = self.checkinglabel.text;
    CGSize fitSize = [text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 0) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : self.checkinglabel.font} context:nil].size;
    CGSize originalSize = CGSizeMake([TTDeviceUIUtils tt_padding:72.f/2], [TTDeviceUIUtils tt_padding:28.f/2]);
    CGFloat width  = MAX(fitSize.width, originalSize.width);
    CGFloat height = MAX(fitSize.height, originalSize.height);
    return CGSizeMake(width, height);
}

- (SSThemedLabel *)checkinglabel {
    if (!_checkinglabel) {
        _checkinglabel = [SSThemedLabel new];
        _checkinglabel.backgroundColor = [UIColor clearColor];
        _checkinglabel.textAlignment = NSTextAlignmentCenter;
        _checkinglabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:kTTEditProfileCheckFontSize]];
        _checkinglabel.textColorThemeKey = kTTEditProfileCheckColorKey;
        _checkinglabel.textColor = [UIColor colorWithHexString:kTTCheckingColor];
        _checkinglabel.text = @"审核中";
    }
    return _checkinglabel;
}
@end
