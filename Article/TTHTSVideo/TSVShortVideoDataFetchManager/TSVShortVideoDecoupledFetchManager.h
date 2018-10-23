//
//  TSVShortVideoDecoupledFetchManager.h
//  HTSVideoPlay
//
//  Created by 邱鑫玥 on 2017/12/11.
//

#import "TSVDataFetchManager.h"
#import <TTCategoryDefine.h>

@class TTShortVideoModel;

@interface TSVShortVideoDecoupledFetchManager : TSVDataFetchManager

@property (nonatomic, strong, readonly) NSArray<TTShortVideoModel *> *detailItems;

- (instancetype)initWithItems:(NSArray<TTShortVideoModel *> *)items
            requestCategoryID:(NSString *)requestCategoryID
           trackingCategoryID:(NSString *)trackingCategoryID
                 listEntrance:(NSString *)listEntrance;

@end
