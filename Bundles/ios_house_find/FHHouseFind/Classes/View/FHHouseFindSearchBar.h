//
//  FHHouseFindSearchBar.h
//  Pods
//
//  Created by 张静 on 2019/1/2.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHHouseFindSearchBar : UIView

@property(nonatomic , strong) NSString *placeHolder;
@property(nonatomic , strong) NSString *inputText;
@property(nonatomic , copy) void (^tapInputBar)();

@end

NS_ASSUME_NONNULL_END
