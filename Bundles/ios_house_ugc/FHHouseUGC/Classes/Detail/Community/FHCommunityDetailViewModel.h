//
// Created by zhulijun on 2019-06-12.
//

#import <Foundation/Foundation.h>

@class FHCommunityDetailViewController;
@class FHCommunityDetailHeaderView;


@interface FHCommunityDetailViewModel : NSObject <UIScrollViewDelegate>
@property(nonatomic , strong) NSMutableDictionary *tracerDict;

- (instancetype)initWithController:(FHCommunityDetailViewController *)viewController tracerDict:(NSDictionary*)tracerDict;

- (void)requestData:(BOOL) userPull refreshFeed:(BOOL) refreshFeed showEmptyIfFailed:(BOOL) showEmptyIfFailed showToast:(BOOL) showToast;

- (void)viewWillAppear;

- (void)viewWillDisappear;

-(void)addGoDetailLog;

-(void)addStayPageLog:(NSTimeInterval)stayTime;

- (void)addPublicationsShowLog;
@end
