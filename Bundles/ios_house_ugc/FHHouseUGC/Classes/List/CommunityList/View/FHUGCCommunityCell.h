//
// Created by zhulijun on 2019-07-18.
//

#import <Foundation/Foundation.h>
#import "FHUGCBaseCell.h"
#import "FHUGCFollowButton.h"

typedef NS_ENUM(NSInteger, FHUGCCommunityCellType) {
    FHUGCCommunityCellTypeFollow,
    FHUGCCommunityCellTypeChoose,
    FHUGCCommunityCellTypeNone,
};

@interface FHUGCCommunityCell : UITableViewCell
@property(nonatomic, weak, nullable) id currentData;
@property(nonatomic, strong) FHUGCFollowButton *followButton;//关注button

+ (Class)cellViewClass;

- (void)refreshWithData:(id)data type:(FHUGCCommunityCellType)type;

+ (CGFloat)heightForData:(id)data;

@end
