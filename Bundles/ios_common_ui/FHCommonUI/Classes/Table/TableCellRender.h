//
//  TableCellRender.h
//  AFgzipRequestSerializer
//
//  Created by leo on 2018/11/11.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TableCellRender <NSObject>

- (void)renderCell:(UITableViewCell *)cell withModel:(id)model atIndexPath:(NSIndexPath*)indexPath;
@optional
-(NSString*)reusedIdentifer;
-(void)selectedWithModel:(nullable id)model;

@end

NS_ASSUME_NONNULL_END
