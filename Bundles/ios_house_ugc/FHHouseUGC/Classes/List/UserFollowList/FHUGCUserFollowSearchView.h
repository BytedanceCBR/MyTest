//
//  FHUGCUserFollowSearchView.h
//  FHHouseList
//
//  Created by 张元科 on 2019/10/14.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHUGCUserFollowSearchView : UIView

@property (nonatomic, strong)   UITextField       *searchInput;
- (void)setSearchPlaceHolderText:(NSString *)text;

@end

NS_ASSUME_NONNULL_END
