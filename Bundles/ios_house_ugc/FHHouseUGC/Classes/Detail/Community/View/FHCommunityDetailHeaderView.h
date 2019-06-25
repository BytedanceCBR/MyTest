//
// Created by zhulijun on 2019-06-12.
//

#import <Foundation/Foundation.h>

@class FHUGCFollowButton;


@interface FHCommunityDetailHeaderView : UIView
@property(nonatomic, strong) UIImageView *topBack;
@property(nonatomic, strong) UIImageView *avatar;
@property(nonatomic, strong) UIView *labelContainer;
@property(nonatomic, strong) UILabel *nameLabel;
@property(nonatomic, strong) UILabel *subtitleLabel;
@property(nonatomic, strong) FHUGCFollowButton *followButton;
@property(nonatomic, strong) UIView *publicationsContainer;
@property(nonatomic, strong) UILabel *publicationsLabel;
@property(nonatomic, strong) UILabel *publicationsContentLabel;
@property(nonatomic) CGFloat headerBackHeight;

- (void)resize;

-(void)updateWithJoinStatus:(BOOL)join;
@end
