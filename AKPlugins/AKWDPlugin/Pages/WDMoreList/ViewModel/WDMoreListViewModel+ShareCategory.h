//
//  WDMoreListViewModel+ShareCategory.h
//  Article
//
//  Created by 延晋 张 on 2017/1/25.
//
//

#import "WDMoreListViewModel.h"

@protocol TTActivityContentItemProtocol;

@interface WDMoreListViewModel (ShareCategory)

- (NSArray<id<TTActivityContentItemProtocol>> *)wd_customItems;
- (NSArray<id<TTActivityContentItemProtocol>> *)wd_shareItems;

@end
