//
//  FHDetailHalfPopCheckCell.h
//  DemoFunTwo
//
//  Created by 春晖 on 2019/5/20.
//  Copyright © 2019 chunhui. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
// 官方直验
@interface FHDetailHalfPopCheckCell : UITableViewCell

+(CGFloat)heightForTile:(NSString *)title tip:(NSString *)tip;

-(void)updateWithTitle:(NSString *)title tip:(NSString *)tip;

@end

NS_ASSUME_NONNULL_END
