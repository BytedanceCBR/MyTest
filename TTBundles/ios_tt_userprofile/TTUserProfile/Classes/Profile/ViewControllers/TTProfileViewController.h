//
//  TTProfileViewController.h
//  Article
//
//  Created by yuxin on 7/17/15.
//
//

#import <UIKit/UIKit.h>
#import "SSThemed.h"
#import "SSMyUserModel.h"
#import "TTImageView.h"
#import "TTAlphaThemedButton.h"
#import "SSViewControllerBase.h"



@interface TTProfileViewController : SSViewControllerBase
<
TTAccountMulticastProtocol
>
@property (nonatomic, weak) IBOutlet SSThemedTableView   *tableView;
@property (nonatomic, weak) IBOutlet TTAlphaThemedButton *padBackButton;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *tableViewTop;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *tableViewLeft;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *tableViewBottom;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *tableViewRight;
@property (nonatomic, copy) NSString *fromTab;

- (void)updateHeaderControls;
- (void)reloadTableViewLater;
- (void)reloadTableView;
- (void)refreshUserInfoView;
- (void)updateHeaderBenefitInfo;
- (void)refreshCommonwealView;

@end
