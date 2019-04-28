//
//  TTLiveRemindView.h
//  Article
//
//  Created by 杨心雨 on 2016/10/17.
//
//

#import "SSThemed.h"

@class TTLabel, TTLiveMessage;

@interface TTLiveRemindView : SSThemedButton

@property (nonatomic) CGFloat maxWidth;
@property (nonatomic, strong) TTLabel * _Nonnull messageView;
@property (nonatomic, strong) SSThemedImageView * _Nonnull scollDownView;
@property (nonatomic, copy)TTLiveMessage * _Nullable message;

- (void)updateWithMessage:(TTLiveMessage * _Nonnull)message;

@end
