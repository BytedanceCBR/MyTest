//
//  IndexPathMappingCellCoordination.h
//  AFgzipRequestSerializer
//
//  Created by leo on 2018/11/11.
//

#import <Foundation/Foundation.h>
#import "TableViewCellCoordinator.h"
NS_ASSUME_NONNULL_BEGIN

@interface IndexPathMappingCellCoordinator : NSObject<TableViewCellCoordinator>
@property (nonatomic) NSMutableDictionary<NSIndexPath*, id<TableCellRender>>* renders;
@property (nonatomic) NSMutableDictionary<NSIndexPath*, id<TableCellSelector>>* selectors;

-(void)addCellRender:(id<TableCellRender>)render
         atIndexPath:(NSIndexPath*)indexPath;

-(void)addCellSelector:(id<TableCellSelector>)selector
           atIndexPath:(NSIndexPath*)indexPath;
@end

NS_ASSUME_NONNULL_END
