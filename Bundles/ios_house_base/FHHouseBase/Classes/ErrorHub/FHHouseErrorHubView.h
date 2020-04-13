//
//  FHHouseErrorHubView.h
//  FHHouseBase
//
//  Created by liuyu on 2020/4/9.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHHouseErrorHubView : UIView
+(void)showErrorHubViewWithTitle:(NSString *)title content:(NSString *)content;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *content;
@end

NS_ASSUME_NONNULL_END
