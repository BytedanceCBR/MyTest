//
//  TTRNViewController.h
//  Article
//
//  Created by Chen Hong on 16/7/14.
//
//

#import <UIKit/UIKit.h>
#import "SSViewControllerBase.h"
#import "TTRNBundleInfoBuilder.h"

@interface TTRNViewController : SSViewControllerBase

@property (nonatomic) BOOL hideBackButton; // Default is NO.
@property (nonatomic) BOOL isWhiteBack; // Default is NO.

/**
 @prams initialProperties
 */
- (instancetype)initWithModuleName:(NSString *)moduleName
                        bundleInfo:(void(^)(TTRNBundleInfoBuilder *builder))block
                 initialProperties:(NSDictionary *)initialProperties;

- (void)sendDeviceEventWithName:(NSString *)name body:(id)body;

@end
