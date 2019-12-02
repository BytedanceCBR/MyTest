//
//  FHMainOldTopTagsView.h
//  FHHouseList
//
//  Created by 张元科 on 2019/9/23.
//

#import <UIKit/UIKit.h>
#import "FHEnvContext.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHMainOldTopTagsView : UIView

@property (nonatomic, strong)   NSMutableDictionary       *lastConditionDic;
@property (nonatomic, copy)     dispatch_block_t       itemClickBlk;
@property (nonatomic, copy)     NSString* condition;

- (BOOL)hasTagData;

@end

@interface FHMainOldTagsView : UIControl

@property (nonatomic, strong)   FHSearchFilterConfigOption       *optionData;
@property (nonatomic, assign)   BOOL       isSelected;

@end

NS_ASSUME_NONNULL_END
