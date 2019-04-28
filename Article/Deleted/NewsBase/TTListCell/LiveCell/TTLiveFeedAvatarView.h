//
//  TTLiveFeedAvatarView.h
//  Article
//
//  Created by 杨心雨 on 16/8/19.
//
//

#import <UIKit/UIKit.h>
#import "SSThemed.h"
#import "LiveStar.h"
#import "LiveTeam.h"

@interface TTLiveFeedAvatarView : SSThemedView

- (void)updateAvatarViewWithStar:(LiveStar *)star;
- (void)updateAvatarViewWithTeam:(LiveTeam *)team;

@end
