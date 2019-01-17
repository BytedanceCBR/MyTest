//
//  FHDetailPageCellCoordinator.h
//  AKCommentPlugin
//
//  Created by leo on 2018/11/19.
//

#import <Foundation/Foundation.h>
#import "TableViewCellCoordinator.h"
#import "FlatRawTableRepository.h"
NS_ASSUME_NONNULL_BEGIN

@interface FHSectionNode : NSObject

@end

@interface FHDetailPageCellCoordinator : NSObject<TableViewCellCoordinator, FlatRawTableRepository>

@end

NS_ASSUME_NONNULL_END
