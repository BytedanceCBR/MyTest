//
//  FHRowsView.h
//  FHHouseRent
//
//  Created by leo on 2018/11/20.
//  Copyright © 2018 com.haoduofangs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FHSpringboardView.h"

NS_ASSUME_NONNULL_BEGIN

@protocol RowItemView <NSObject>

@end

@interface FHRowsView : UIView
@property (nonatomic, assign, readonly) NSInteger rowCount;
@property (nonatomic, assign, readonly) NSInteger rowHight;
@property (nonatomic, copy) void(^clickedCallBack)(NSInteger index);

@property (nonatomic, strong) NSArray<id<FHSpringboardItemView>>*currentItems;

-(instancetype)initWithRowCount:(NSInteger)rowCount;
- (instancetype)initWithRowCount:(NSInteger)rowCount withRowHight:(NSInteger) rowHight;
-(void)addRowItemViews:(NSArray<UIView<RowItemView>*>*)rows;
-(void)addItemViews:(NSArray<id<FHSpringboardItemView>>*)items;
@end

NS_ASSUME_NONNULL_END
