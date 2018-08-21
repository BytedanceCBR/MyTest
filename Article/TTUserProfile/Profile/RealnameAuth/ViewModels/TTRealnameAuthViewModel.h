//
//  TTRealnameAuthViewModel.h
//  Article
//
//  Created by lizhuoli on 16/12/19.
//
//

#import <Foundation/Foundation.h>
#import "SSViewControllerBase.h"
#import "TTRealnameAuthModel.h"
#import "TTRealnameAuthDelegate.h"
#import "UIViewController+Refresh_ErrorHandler.h"

@interface TTRealnameAuthViewModel : NSObject

@property (nonatomic ,strong) TTRealnameAuthModel *model;

- (void)setupModel:(TTRealnameAuthModel *)model withSender:(id)sender;
- (void)loadInitialAuthStatus;
- (void)setupRootVC:(SSViewControllerBase<RealnameAuthViewDelegate, UIViewControllerErrorHandler> *)rootVC;
- (SSViewControllerBase<RealnameAuthViewDelegate, UIViewControllerErrorHandler> *)rootVC;

@end
