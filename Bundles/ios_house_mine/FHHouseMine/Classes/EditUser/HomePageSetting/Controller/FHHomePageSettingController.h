//
//  FHHomePageSettingController.h
//  FHHouseMine
//
//  Created by 谢思铭 on 2019/10/16.
//

#import "FHBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@protocol FHHomePageSettingControllerDelegate <NSObject>

- (void)reloadAuthDesc:(NSInteger)auth;

@end

@interface FHHomePageSettingController : FHBaseViewController

@property (nonatomic, assign) NSInteger currentAuth;

@property(nonatomic , weak) id<FHHomePageSettingControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
