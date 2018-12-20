//
//  FilterItemBar.h
//  HouseRent
//
//  Created by leo on 2018/11/15.
//  Copyright © 2018 com.haoduofangs. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol FHFilterItem <NSObject>

-(void)onSelected:(BOOL)isSelected;

@end

@protocol FilterItemBarStateChangedDelegate <NSObject>

-(void)onPanelExpand:(BOOL)isExpand;

@end

@interface FilterItemBar : UIView
@property (nonatomic, weak) id<FilterItemBarStateChangedDelegate> stateChangedDelegate;
+(instancetype)instanceWithItems:(UIView<FHFilterItem>*)items;
-(instancetype)initWithItems:(UIView<FHFilterItem>*)items;
-(void)packUp;
@end

NS_ASSUME_NONNULL_END
