//
//  FHHouseSingleImageInfoCellBridgeDelegate.h
//  Pods
//
//  Created by 谷春晖 on 2018/11/19.
//

#ifndef FHHouseSingleImageInfoCellBridgeDelegate_h
#define FHHouseSingleImageInfoCellBridgeDelegate_h

@class FHSearchHouseDataItemsModel;
@class FHNewHouseItemModel;
@class FHHouseRentDataItemsModel;

@protocol  FHHouseSingleImageInfoCellBridgeDelegate<NSObject>


-(void)updateWithModel:(FHSearchHouseDataItemsModel *)model isLastCell:(BOOL)isLastCell;

@optional
-(void)updateWithNewHouseModel:(FHNewHouseItemModel *)model isFirstCell:(BOOL)isFirstCell isLastCell:(BOOL)isLastCell;

@optional
-(void)updateWithSecondHouseModel:(FHSearchHouseDataItemsModel *)model isFirstCell:(BOOL)isFirstCell isLastCell:(BOOL)isLastCell;

-(void)updateWithRentHouseModel:(FHHouseRentDataItemsModel *)model  isFirstCell:(BOOL)isFirstCell isLastCell:(BOOL)isLastCell;

@end


#endif /* FHHouseSingleImageInfoCellBridgeDelegate_h */
