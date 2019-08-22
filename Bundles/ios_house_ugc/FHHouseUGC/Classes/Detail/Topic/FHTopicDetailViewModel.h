//
//  FHTopicDetailViewModel.h
//  FHHouseUGC
//
//  Created by 张元科 on 2019/8/22.
//

#import <Foundation/Foundation.h>
#import "FHTopicDetailViewController.h"
#import "FHUGCBaseViewModel.h"
#import "FHUGCCellManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHTopicDetailViewModel : FHUGCBaseViewModel

@property (nonatomic, strong)   FHUGCCellManager       *ugcCellManager;

-(instancetype)initWithController:(FHTopicDetailViewController *)viewController;

- (void)startLoadData;

@end

NS_ASSUME_NONNULL_END
