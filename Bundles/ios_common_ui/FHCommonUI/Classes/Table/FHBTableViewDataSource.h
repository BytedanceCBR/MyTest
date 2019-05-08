//
//  FHBTableViewDataSource.h
//  AFgzipRequestSerializer
//
//  Created by leo on 2018/11/14.
//

#import <UIKit/UIKit.h>
#import "TableViewCellCoordinator.h"
#import "FlatRawTableRepository.h"
NS_ASSUME_NONNULL_BEGIN

@interface FHBTableViewDataSource : NSObject <UITableViewDataSource, UITableViewDelegate>

- (instancetype)initWithCoordinator:(id<TableViewCellCoordinator>)coordinator
                     withRespoitory:(id<FlatRawTableRepository>)repository;

@end

NS_ASSUME_NONNULL_END
