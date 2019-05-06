//
//  FHIMAlertViewListenerImpl.m
//  AKCommentPlugin
//
//  Created by leo on 2019/4/30.
//

#import "FHIMAlertViewListenerImpl.h"
#import "ExploreMovieView.h"
@implementation FHIMAlertViewListenerImpl

+(instancetype)shareInstance {
    static FHIMAlertViewListenerImpl* instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[FHIMAlertViewListenerImpl alloc] init];
    });
    return instance;
}

-(void)onUserClidkImAlert {
    [ExploreMovieView removeAllExploreMovieView];
}

@end
