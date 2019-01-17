//
//  FHRealtorDetailWebViewController.h
//  Article
//
//  Created by leo on 2019/1/7.
//

#import "SSWebViewController.h"

NS_ASSUME_NONNULL_BEGIN
@protocol FHRealtorDetailWebViewControllerDelegate <NSObject>

-(void)followUpAction;

@end
@interface FHRealtorDetailWebViewController : SSWebViewController
@property (nonatomic, weak) id<FHRealtorDetailWebViewControllerDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
