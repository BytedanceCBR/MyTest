//
//  FHRealtorDetailWebViewController.h
//  Article
//
//  Created by leo on 2019/1/7.
//

#import "SSWebViewController.h"
#import <FHHouseBase/FHRealtorDetailWebViewControllerDelegate.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHRealtorDetailWebViewController : SSWebViewController
@property (nonatomic, weak) id<FHRealtorDetailWebViewControllerDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
