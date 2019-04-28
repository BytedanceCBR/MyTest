//
//  ArticleAddressManager.h
//  Article
//
//  Created by Dianwei on 14-7-17.
//
//

#import <Foundation/Foundation.h>

#import "ArticleMobileViewController.h"

@interface ArticleAddressBridger : NSObject
+ (instancetype)sharedBridger;
- (BOOL)tryShowGetAddressBookAlertWithMobileLoginState:(ArticleLoginState)state;
@property(nonatomic, strong)UIViewController *presentingController;
@end
