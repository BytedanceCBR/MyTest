//
//  TTVideoFloatAvatar.h
//  Article
//
//  Created by panxiang on 16/7/11.
//
//

#import "SSThemed.h"
#import "ExploreAvatarView+VerifyIcon.h"

@interface TTVideoFloatAvatar : SSThemedView
@property (nonatomic, strong, nullable, readonly) ExploreAvatarView *icon;

- (void)addTarget:(nullable id)target action:(_Nonnull SEL)action forControlEvents:(UIControlEvents)controlEvents;
@end
