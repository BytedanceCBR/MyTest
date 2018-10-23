//
//  TTAvatarDecoratorView.h
//  TTAvatar
//
//  Created by lipeilun on 2018/1/4.
//

#import "SSThemed.h"

#define kDecoratorOriginFactor -0.1
#define kDecoratorSizeFactor 1.2

@interface TTAvatarDecoratorView : SSThemedImageView
@property (nonatomic, copy) NSString *decoratorInfoString;//字典的字符串，省去各个地方的解包操作
@property (nonatomic, copy) NSString *userID;
@property (nonatomic, assign) BOOL disableNightCover;

- (void)showAvatarDecorator;

- (void)hideAvatarDecorator;

- (void)refreshDecoratorFrame:(CGRect)frame;

@end
