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

@end

@interface FHMainOldTagsView : UIControl

@property (nonatomic, strong)   FHSearchFilterConfigOption       *optionData;
@property (nonatomic, assign)   BOOL       isSelected;

@end

NS_ASSUME_NONNULL_END
