//
//  TableViewCellCoordinator.h
//  AFgzipRequestSerializer
//
//  Created by leo on 2018/11/11.
//

#import <Foundation/Foundation.h>
#import "TableCellRender.h"
#import "TableCellSelector.h"
NS_ASSUME_NONNULL_BEGIN

@protocol TableViewCellCoordinator <NSObject>
-(id<TableCellRender>)cellRenderAtIndexPath:(NSIndexPath*)indexPath;
-(NSString*)cellReusedIdentiferForIndexPath:(NSIndexPath*)incexPath;
@end

NS_ASSUME_NONNULL_END
