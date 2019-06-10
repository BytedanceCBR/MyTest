//
//  ExploreChannelListView.h
//  Article
//
//  Created by Chen Hong on 14-10-13.
//
//

#import "SSViewBase.h"
#import "ExploreMixedListBaseView.h"
#import "SSNavigationBar.h"

@class ExploreChannelListView;

@protocol ExploreChannelListViewDelegate <NSObject>

@optional
- (void)listViewStartRequest:(ExploreChannelListView *)listView;
- (void)listViewFinishRequest:(ExploreChannelListView *)listView error:(NSError *)error;

@end

@interface ExploreChannelListView : SSViewBase

@property (nonatomic, strong) SSNavigationBar * navigationBar;
@property (nonatomic, weak) id<ExploreChannelListViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame baseCondition:(NSDictionary *)baseCondition;

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation;

@end
