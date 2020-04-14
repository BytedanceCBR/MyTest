//
//  FHLoginContainerViewController.h
//  Pods
//
//  Created by bytedance on 2020/4/14.
//

#import "FHBaseViewController.h"
#import "FHLoginViewModel.h"
#import "FHLoginDefine.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHLoginContainerViewController : FHBaseViewController

@property (nonatomic, weak) FHLoginViewModel *viewModel;

@property (nonatomic, assign) FHLoginViewType viewType;

@end

NS_ASSUME_NONNULL_END
