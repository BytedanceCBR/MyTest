//
// Created by zhulijun on 2019-07-17.
//

#import <Foundation/Foundation.h>
#import "FHUGCCommunityDistrictTabCell.h"

typedef NS_ENUM(NSInteger,FHUGCCommunityDistrictTabSelectType){
    FHUGCCommunityDistrictTabSelectTypeClick,
    FHUGCCommunityDistrictTabSelectTypeDefault,
};

@protocol FHUGCCommunityCategoryViewDelegate<NSObject>

@optional
- (void)onCategorySelect:(FHUGCCommunityDistrictTabModel *)select before:(FHUGCCommunityDistrictTabModel *)before selectType:(FHUGCCommunityDistrictTabSelectType)selectType;

@end

@interface FHUGCCommunityCategoryView : UIView
@property(nonatomic, weak) id <FHUGCCommunityCategoryViewDelegate> delegate;

//默认全部为非选中状态,
- (void)refreshWithCategories:(NSArray<FHUGCCommunityDistrictTabModel *> *)categories;

- (void)select:(NSInteger)categoryId selectType:(FHUGCCommunityDistrictTabSelectType)selectType;
@end
