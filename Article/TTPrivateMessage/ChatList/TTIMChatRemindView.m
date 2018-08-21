//
//  TTIMChatRemindView.m
//  Article
//
//  Created by 杨心雨 on 2017/3/20.
//
//

#import "TTIMChatRemindView.h"
#import "TTLabel.h"

@implementation TTIMChatRemindView

- (instancetype)initWithFrame:(CGRect)frame {
    frame.size = CGSizeMake(84, 32);
    self = [super initWithFrame:frame];
    if (self) {
        self.messageView = [[TTLabel alloc] init];
        _messageView.font = [UIFont systemFontOfSize:13];
        _messageView.textColorKey = kColorText12;
        _messageView.lineBreakMode = NSLineBreakByTruncatingTail;
        _messageView.numberOfLines = 1;
        _messageView.text = @"有新消息";
        [_messageView sizeToFit:(self.width - 13)];
        [self addSubview:_messageView];
        
        self.scollDownView = [[SSThemedImageView alloc] initWithFrame:CGRectMake(0, 0, 9, 11)];
        _scollDownView.imageName = @"im_icon_arrow";
        [self addSubview:_scollDownView];
    }
    return self;
}

- (void)layoutSubviews {
    self.messageView.centerY = self.height / 2;
    self.scollDownView.centerY = self.height / 2;
    
    self.messageView.left = (self.width - self.messageView.width - 2 - self.scollDownView.width) / 2;
    self.scollDownView.left = self.messageView.right + 1;
}

- (void)setHidden:(BOOL)hidden {
    if (self.hidden != hidden) {
        if (hidden) {
            [UIView animateWithDuration:0.2 animations:^{
                self.alpha = 0;
            } completion:^(BOOL finished) {
                [super setHidden:hidden];
                self.alpha = 1;
            }];
        } else {
            [super setHidden:hidden];
            self.alpha = 0;
            [UIView animateWithDuration:0.2 animations:^{
                self.alpha = 1;
            } completion:^(BOOL finished) {
            }];
        }
    }
}

@end
