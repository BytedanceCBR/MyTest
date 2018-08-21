//
//  ArticleGetLocalDataOperation.h
//  Article
//
//  Created by Dianwei on 12-11-18.
//
//

#import <Foundation/Foundation.h>
#import "SSDataOperation.h"

extern NSInteger getLocalNormalLoadCount();
extern NSInteger getLocalOfflineLoadCount();

@interface ArticleGetLocalDataOperation : SSDataOperation

- (Class)orderedDataClass;
+ (NSArray *)fixOrderedDataWhenQueryFromDB:(NSArray *)sortedDataList withCategoryID:(NSString *)categoryID;

@end
