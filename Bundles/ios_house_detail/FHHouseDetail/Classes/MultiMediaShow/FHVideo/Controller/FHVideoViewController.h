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

@property(nonatomic, strong) FHVideoModel *model;

- (void)updateData:(FHVideoModel *)model;

- (void)play;

- (void)pause;

@end

NS_ASSUME_NONNULL_END
