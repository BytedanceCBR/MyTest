//
//  TTFeedCollectionCellService.h
//  Article
//
//  Created by Chen Hong on 2017/3/29.
//
//

#import <Foundation/Foundation.h>
#import "TTFeedCollectionCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface TTFeedCollectionCellService : NSObject

+ (instancetype)sharedInstance;

/// 设置默认CellHelper类
- (void)setDefaultFeedCollectionCellHelperClass:(Class<TTFeedCollectionCellHelper>)cellHelper;

/// 注册特定的CellHelper类
- (void)registerFeedCollectionCellHelperClass:(Class<TTFeedCollectionCellHelper>)cellHelper;

/// 返回频道对应的cell类
- (nullable Class<TTFeedCollectionCell>)cellClassFromFeedCategory:(nonnull id<TTFeedCategory>)feedCategory;

/// 枚举所有支持的cell类
- (void)enumerateCellClassUsingBlock:(void (NS_NOESCAPE ^)(Class<TTFeedCollectionCell> cellClass))block;

@end

NS_ASSUME_NONNULL_END
