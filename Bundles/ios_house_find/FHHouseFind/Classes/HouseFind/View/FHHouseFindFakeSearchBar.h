//
//  FHHouseFindFakeSearchBar.h
//  FHHouseFind
//
//  Created by 春晖 on 2019/2/14.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHHouseFindFakeSearchBar : UIView

@property(nonatomic , copy) void (^tapBlock)();

@property(nonatomic , strong) NSString *placeholder;

@end

NS_ASSUME_NONNULL_END
