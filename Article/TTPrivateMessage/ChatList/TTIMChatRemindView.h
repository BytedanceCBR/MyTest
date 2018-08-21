//
//  TTIMChatRemindView.h
//  Article
//
//  Created by 杨心雨 on 2017/3/20.
//
//

#import "SSThemed.h"

@class TTLabel;

@interface TTIMChatRemindView : SSThemedButton

@property (nonatomic) CGFloat maxWidth;
@property (nonatomic, strong) TTLabel * _Nonnull messageView;
@property (nonatomic, strong) SSThemedImageView * _Nonnull scollDownView;

@end
