//
//  TTLiveStatusView.m
//  Article
//
//  Created by 杨心雨 on 16/8/17.
//
//

#import "TTLiveStatusView.h"
#import "TTDeviceHelper.h"
#import "TTArticleCellHelper.h"
#import "TTIconFontChatroomDefine.h"
#import "LiveMatch.h"

@interface TTLiveStatusView ()

@property (nonatomic, strong) SSThemedLabel *icon;
@property (nonatomic, strong) SSThemedLabel *status;

@end

@implementation TTLiveStatusView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.cornerRadius = 4;
    }
    return self;
}

- (SSThemedLabel *)icon {
    if (_icon == nil) {
        _icon = [[SSThemedLabel alloc] init];
        _icon.font = [UIFont fontWithName:kIconFontChatroomFontFamily size:12];
        _icon.textAlignment = NSTextAlignmentLeft;
        [self addSubview:_icon];
    }
    return _icon;
}

- (SSThemedLabel *)status {
    if (_status == nil) {
        _status = [[SSThemedLabel alloc] init];
        _status.font = [UIFont tt_fontOfSize:12];
        _status.textAlignment = NSTextAlignmentLeft;
        [self addSubview:_status];
    }
    return _status;
}

- (void)updateStatus:(Live *)live status:(NSInteger)status {
    self.height = 20;

    if (live.statusDisplay) {
        NSString *statusText = live.statusDisplay;
        if (live.video != nil || (live.match != nil && [live.match.videoFlag boolValue])) {
            self.icon.text = kIconFontChatroomVideo;
        } else {
            self.icon.text = kIconFontChatroomPicture;
        }
        if (status == 1) {
            self.backgroundColorThemeKey = kColorBackground8;
            self.icon.textColorThemeKey = kColorText12;
            self.status.textColorThemeKey = kColorText12;
        } else if (status == 2) {
            self.backgroundColorThemeKey = kColorBackground7;
            self.icon.textColorThemeKey = kColorText12;
            self.status.textColorThemeKey = kColorText12;
        } else if (status == 3) {
            self.backgroundColorThemeKey = kColorBackground2;
            self.icon.textColorThemeKey = kColorText3;
            self.status.textColorThemeKey = kColorText3;
        } else {
            NSLog(@"status error");
        }
        self.status.text = statusText;
        [self.status sizeToFit];
        [self.icon sizeToFit];
        self.status.frame = CGRectIntegral(self.status.frame);
        self.icon.frame = CGRectIntegral(self.icon.frame);
    }
    
    self.icon.left = 5;
    self.icon.centerY = self.height / 2;
    
    self.status.left = self.icon.right + 4;
    self.status.centerY = self.icon.centerY;
    
    self.width = self.status.right + 5;
}

@end
