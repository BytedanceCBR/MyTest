//
//  ExploreChannelListViewController.h
//  Article
//
//  Created by Chen Hong on 14-10-13.
//
//

#import "SSViewControllerBase.h"

@interface ExploreChannelListViewController : SSViewControllerBase

@property(nonatomic,retain)NSDictionary *params;
@property(nonatomic,retain)NSDictionary *baseCondition;
- (instancetype)initWithRouteParams:(NSDictionary *)params;
@end
