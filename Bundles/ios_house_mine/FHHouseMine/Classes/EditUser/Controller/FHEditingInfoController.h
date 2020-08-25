//
//  FHEditingInfoController.h
//  FHHouseMine
//
//  Created by 谢思铭 on 2019/5/22.
//

#import "FHBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@protocol FHEditingInfoControllerDelegate <NSObject>

- (void)loadRequest;

@end

typedef NS_ENUM(NSInteger, FHEditingInfoType)
{
    FHEditingInfoTypeNone = 0,
    FHEditingInfoTypeUserName,
    FHEditingInfoTypeUserDesc
};

@interface FHEditingInfoController : FHBaseViewController

@property(nonatomic , weak) id<FHEditingInfoControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
