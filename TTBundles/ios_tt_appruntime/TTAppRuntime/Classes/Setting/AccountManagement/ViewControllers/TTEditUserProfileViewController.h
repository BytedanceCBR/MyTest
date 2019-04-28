//
//  TTEditUserProfileViewController.h
//  Article
//
//  Created by Zuopeng Liu on 7/15/16.
//
//

#import <UIKit/UIKit.h>
#import "TTBaseThemedViewController.h"
#import <TTAccountBusiness.h>

extern NSString *const kTTEditUserInfoDidFinishNotificationName;
extern NSString *const kTTUserEditableInfoKey;

@class TTEditUserProfileViewController;
@protocol TTEditUserProfileViewControllerDelegate <NSObject>
@optional
- (void)editUserProfileController:(TTEditUserProfileViewController *)aController goBack:(id)sender;
- (BOOL)hideDescriptionCellInEditUserProfileController:(TTEditUserProfileViewController *)aController;
@end


@interface TTEditUserProfileViewController : TTBaseThemedViewController
@property (nonatomic, assign) TTAccountUserType userType;
@property (nonatomic, weak) id<TTEditUserProfileViewControllerDelegate> delegate;

- (instancetype)initWithUserType:(TTAccountUserType)userType;

- (void)goBack:(id)sender;
@end
