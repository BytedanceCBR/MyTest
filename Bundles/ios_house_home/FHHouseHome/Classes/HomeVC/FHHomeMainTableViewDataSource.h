//
//  FHHomeMainTableViewDataSource.h
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2018/12/22.
//

#import "JSONModel.h"
#import <JSONModel.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHHomeMainTableViewDataSource : JSONModel
@property(nonatomic,strong) NSArray <JSONModel *>*modelsArray;

@end

NS_ASSUME_NONNULL_END
