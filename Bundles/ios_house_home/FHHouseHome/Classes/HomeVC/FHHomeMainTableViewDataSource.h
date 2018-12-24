//
//  FHHomeMainTableViewDataSource.h
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2018/12/22.
//

#import "JSONModel.h"
#import <JSONModel.h>
#import "FHHomeSectionHeader.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHHomeMainTableViewDataSource : JSONModel
@property(nonatomic,strong) NSArray <JSONModel *>*modelsArray;
@property (nonatomic, strong) FHHomeSectionHeader *categoryView;
@property (nonatomic, assign) BOOL showPlaceHolder;
@end

NS_ASSUME_NONNULL_END
