//
//  TTCancelFollowButton.h
//  Article
//
//  Created by ranny_90 on 2017/8/8.
//
//

#import <TTThemed/SSThemed.h>

/** 互相关注类型 */
typedef NS_ENUM(NSInteger, TTFolloweState) {
    TTFolloweStateFollow    = 1,
    TTFolloweStateCancel    = 2,
};


@interface TTCancelFollowButton : SSThemedButton

@property (nonatomic, assign) TTFolloweState followState;

- (void)startLoading;

- (void)stopLoading;

-(BOOL)isLoading;

@end
