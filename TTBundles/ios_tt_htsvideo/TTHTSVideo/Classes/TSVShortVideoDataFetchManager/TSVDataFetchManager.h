//
//  TSVDataFetchManager.h
//  Article
//
//  Created by 王双华 on 2017/9/20.
//

#import <Foundation/Foundation.h>
#import "TSVShortVideoDataFetchManagerProtocol.h"

@class TTShortVideoModel;

@interface TSVDataFetchManager : NSObject<TSVShortVideoDataFetchManagerProtocol>

@property (nonatomic, strong, readonly) TTShortVideoModel *replacedModel;//被替换掉的model
@property (nonatomic, assign, readonly) NSInteger replacedIndex;//被替换掉的model在数组中的index
@property (nonatomic, strong) id detailCellCurrentItem;
@end
