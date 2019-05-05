//
//  TTLiveRemindView.m
//  Article
//
//  Created by 杨心雨 on 2016/10/17.
//
//

#import "TTLiveRemindView.h"
#import "TTLabel.h"
#import "TTLiveMessage.h"

@implementation TTLiveRemindView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.messageView = [[TTLabel alloc] init];
        _messageView.font = [UIFont systemFontOfSize:14];
        _messageView.textColorKey = kColorText12;
        _messageView.lineBreakMode = NSLineBreakByTruncatingTail;
        _messageView.numberOfLines = 1;
        [self addSubview:_messageView];
        
        self.scollDownView = [[SSThemedImageView alloc] initWithFrame:CGRectMake(0, 0, 12, 12)];
        _scollDownView.imageName = @"chatroom_icon_add_more";
        [self addSubview:_scollDownView];
    }
    return self;
}

- (void)updateWithMessage:(TTLiveMessage *)message {
    self.message = message;
    NSString *text = nil;
    if (message.msgType == TTLiveMessageTypeText) {
        text = message.msgText;
    } else {
        if ([message.userDisplayName length] > 5) {
            text = [NSString stringWithFormat:@"%@...:", [message.userDisplayName substringToIndex:4]];
        } else {
            text = [NSString stringWithFormat:@"%@:", message.userDisplayName];
        }
        switch (message.msgType) {
            case TTLiveMessageTypeText:
                // NSLog(@"judge type error");
                break;
            case TTLiveMessageTypeAudio:
                text = [text stringByAppendingString:@"语音消息"];
                break;
            case TTLiveMessageTypeImage:
                text = [text stringByAppendingString:@"图片消息"];
                break;
            case TTLiveMessageTypeVideo:
                text = [text stringByAppendingString:@"视频消息"];
                break;
            case TTLiveMessageTypeMediaCard:
            case TTLiveMessageTypeProfileCard:
                text = [text stringByAppendingString:@"名片消息"];
                break;
            case TTLiveMessageTypeArticleCard:
                text = [text stringByAppendingString:@"文章消息"];
                break;
        }

    }
    self.messageView.text = text;
    [self layoutViews];
}

- (void)layoutViews {
    [self.messageView sizeToFit:(self.maxWidth - 30 - 5 - 12)];
    self.messageView.centerY = self.height / 2;
    self.scollDownView.centerY = self.height / 2;
    
    if (self.hidden) {
        self.hidden = NO;
        CGFloat centerX = self.centerX;
        self.width = self.messageView.width + 30 + 5 + 12;
        self.top = self.top + 35;
        self.centerX = centerX;
        self.messageView.left = 15;
        self.scollDownView.left = self.messageView.right + 5;
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{} completion:^(BOOL finished) {
            self.top = self.top - 35;
            [self.superview bringSubviewToFront:self];
        }];
    } else {
        CGFloat centerX = self.centerX;
        if (self.messageView.width + 30 + 5 + 12 >= self.width) {
            self.messageView.right = self.scollDownView.left - 5;
        } else {
            self.messageView.centerX = (self.width - 30 - 5 - 12) / 2 + 15;
        }
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{} completion:^(BOOL finished) {
            self.width = self.messageView.width + 30 + 5 + 12;
            self.centerX = centerX;
            self.messageView.left = 15;
            self.scollDownView.left = self.messageView.right + 5;
        }];
    }
}

- (void)setHidden:(BOOL)hidden {
    if (hidden) {
        [UIView animateWithDuration:0.2 animations:^{
            self.alpha = 0;
        } completion:^(BOOL finished) {
            [super setHidden:hidden];
            self.alpha = 1;
        }];
    } else {
        [super setHidden:hidden];
    }
}

@end
