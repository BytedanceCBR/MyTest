//
//  WDDetailNatantViewModel+ShareCategory.h
//  Article
//
//  Created by 延晋 张 on 2017/1/24.
//
//

#import "WDDetailNatantViewModel.h"

@protocol TTActivityContentItemProtocol;

@interface WDDetailNatantViewModel (ShareCategory)

- (NSArray<id<TTActivityContentItemProtocol>> *)wd_customItems;
- (NSArray<id<TTActivityContentItemProtocol>> *)wd_shareItems;

@end
