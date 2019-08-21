//
// Created by zhulijun on 2019-07-17.
//


#import "FHUGCBaseCell.h"

@interface FHUGCCommunityDistrictTabModel : NSObject
@property(nonatomic, assign, getter=isSelected) BOOL selected;
@property(nonatomic, copy) NSString *title;
@property(nonatomic, assign) NSInteger categoryId;
@end

@interface FHUGCCommunityDistrictTabCell : FHUGCBaseCollectionCell
@end
