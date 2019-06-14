//
//  FHEditingInfoViewModel.h
//  FHHouseMine
//
//  Created by 谢思铭 on 2019/5/22.
//

#import <Foundation/Foundation.h>
#import "FHEditingInfoController.h"
#import "FHEditableUserInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHEditingInfoViewModel : NSObject

@property(nonatomic, strong) FHEditableUserInfo *userInfo;
@property(nonatomic, assign) FHEditingInfoType type;

- (instancetype)initWithTextField:(UITextField *)textField controller:(FHEditingInfoController *)viewController;

- (void)save;

@end

NS_ASSUME_NONNULL_END