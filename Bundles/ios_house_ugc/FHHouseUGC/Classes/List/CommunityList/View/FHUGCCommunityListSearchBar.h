//
// Created by zhulijun on 2019-07-17.
//

#import <Foundation/Foundation.h>


@interface FHUGCCommunityListSearchBar : UIView
@property(nonatomic, copy) NSString *searchTint;
@property(nonatomic, copy) void (^searchClickBlk)();
@end