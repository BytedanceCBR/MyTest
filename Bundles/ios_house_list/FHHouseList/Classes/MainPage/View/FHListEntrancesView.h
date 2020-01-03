//
//  FHListEntrancesView.h
//  FHHouseList
//
//  Created by 张静 on 2019/12/13.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class FHConfigDataOpDataItemsModel;
@interface FHListEntrancesView : UIView

@property (nonatomic, assign) NSInteger countPerRow;
@property (nonatomic, copy) void (^clickBlock)(NSInteger index , FHConfigDataOpDataItemsModel *model);

+(CGFloat)rowHeight;

-(void)updateWithItems:(NSArray *)items;

@end
NS_ASSUME_NONNULL_END
