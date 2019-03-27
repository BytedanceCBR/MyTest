//
//  FHHouseFindHelpRegionSheet.h
//  FHHouseFind
//
//  Created by 张静 on 2019/3/27.
//

#import <UIKit/UIKit.h>

#define REGION_CONTENT_HEIGHT 258

NS_ASSUME_NONNULL_BEGIN

@interface FHHouseFindHelpRegionSheet : UIView

@property(nonatomic,copy)void(^selectItemsBlock)(NSArray *selectItemList);

- (void)showWithItemList:(NSArray *)itemList;
- (void)dismiss;
@end

NS_ASSUME_NONNULL_END
