//
//  UITableView+FHHouseCard.h
//  ABRInterface
//
//  Created by bytedance on 2020/11/10.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UITableView(FHHouseCard)

- (void)fhHouseCard_registerCellStyles;

- (void)fhHouseCard_registerCellStylesWithDict:(NSDictionary *)dict;

- (UITableViewCell *)fhHouseCard_cellForEntity:(id)entity atIndexPath:(NSIndexPath *)indexPath;

- (UITableViewCell *)fhHouseCard_cellForEntity:(id)entity atIndexPath:(NSIndexPath *)indexPath withDict:(NSDictionary *)dict;

- (CGFloat)fhHouseCard_heightForEntity:(id)entity atIndexPath:(NSIndexPath *)indexPath;

- (CGFloat)fhHouseCard_heightForEntity:(id)entity atIndexPath:(NSIndexPath *)indexPath withDict:(NSDictionary *)dict;

- (BOOL)fhHouseCard_willShowCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (BOOL)fhHouseCard_didClickCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end

NS_ASSUME_NONNULL_END
