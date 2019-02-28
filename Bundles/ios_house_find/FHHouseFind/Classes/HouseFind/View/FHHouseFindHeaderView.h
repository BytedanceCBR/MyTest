//
//  FHHouseFindHeaderView.h
//  FHHouseFind
//
//  Created by 春晖 on 2019/2/12.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHHouseFindHeaderView : UICollectionReusableView

@property(nonatomic , copy) void (^deleteBlock)(FHHouseFindHeaderView *headerView);

-(void)updateTitle:(NSString *)title showDelete:(BOOL)showDelete;

@end

NS_ASSUME_NONNULL_END
