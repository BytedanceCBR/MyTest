//
// Created by zhulijun on 2019-06-12.
//

#import <Foundation/Foundation.h>

@class FHCommunityDetailViewController;
@class FHCommunityDetailHeaderView;


@interface FHCommunityDetailViewModel : NSObject <UIScrollViewDelegate>
@property(nonatomic , strong) NSMutableDictionary *tracerDict;

- (instancetype)initWithController:(FHCommunityDetailViewController *)viewController;

- (void)requestData:(BOOL) refreshFeed;

- (void)viewWillAppear;

-(void)addGoDetailLog;

-(void)addStayPageLog:(NSTimeInterval)stayTime;
@end
