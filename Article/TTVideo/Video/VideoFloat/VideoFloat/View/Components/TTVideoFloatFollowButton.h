//
//  TTVideoFloatFollowButton.h
//  Article
//
//  Created by panxiang on 16/7/11.
//
//

#import "SSThemed.h"
#import "TTVideoFloatProtocol.h"

@interface TTVideoFloatFollowButton : SSThemedView<TTStatusButtonDelegate>
- (void)addTarget:(nullable id)target action:(_Nonnull SEL)action forControlEvents:(UIControlEvents)controlEvents;
@property (nonatomic, assign) BOOL isSubscribed;
@end