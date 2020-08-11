//
//  FHMapSearchNewHouseItemView.h
//  AKCommentPlugin
//
//  Created by 谢飞 on 2020/8/10.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHMapSearchNewHouseItemView : UIView
@property(nonatomic , weak) UIViewController *weakVC;

-(void)showNewHouse:(NSString *)query param:(NSDictionary *)param;

@end

NS_ASSUME_NONNULL_END
