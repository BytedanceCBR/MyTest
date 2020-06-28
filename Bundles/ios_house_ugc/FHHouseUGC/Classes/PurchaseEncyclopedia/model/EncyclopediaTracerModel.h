//
//  EncyclopediaTracerModel.h
//  FHHouseUGC
//
//  Created by liuyu on 2020/5/26.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface EncyclopediaTracerModel : JSONModel
@property (copy, nonatomic, nonnull)NSString *categoryName;
@property (copy, nonatomic ,nonnull)NSString *enterFrom;
@property (copy, nonatomic, nonnull)NSString *originFrom;
@property (copy, nonatomic, nonnull)NSString *pageType;
@end

NS_ASSUME_NONNULL_END
