//
//  FHVideoViewController.h
//  FHHouseMine
//
//  Created by 谢思铭 on 2019/4/15.
//

#import <UIKit/UIKit.h>
#import "FHVideoModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHVideoViewController : UIViewController

- (void)updateData:(FHVideoModel *)model;

- (void)play;

@end

NS_ASSUME_NONNULL_END
