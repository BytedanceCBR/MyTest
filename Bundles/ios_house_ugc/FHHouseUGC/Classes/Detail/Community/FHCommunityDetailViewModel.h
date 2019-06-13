//
// Created by zhulijun on 2019-06-12.
//

#import <Foundation/Foundation.h>

@class FHCommunityDetailViewController;
@class FHCommunityDetailHeaderView;


@interface FHCommunityDetailViewModel : NSObject <UIScrollViewDelegate>
- (instancetype)initWithController:(FHCommunityDetailViewController *)viewController;

- (void)requestData;
@end