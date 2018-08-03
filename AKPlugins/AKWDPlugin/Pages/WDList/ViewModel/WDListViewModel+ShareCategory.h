//
//  WDListViewModel+ShareCategory.h
//  Article
//
//  Created by 延晋 张 on 2017/1/24.
//
//

#import "WDListViewModel.h"

@protocol TTActivityContentItemProtocol;

@interface WDListViewModel (ShareCategory)

- (NSArray<id<TTActivityContentItemProtocol>> *)wd_customItems;
- (NSArray<id<TTActivityContentItemProtocol>> *)wd_shareItems;

@end
