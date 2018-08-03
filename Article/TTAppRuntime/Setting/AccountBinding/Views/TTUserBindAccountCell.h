//
//  TTUserBindAccountCell.h
//  Article
//
//  Created by Zuopeng Liu on 7/15/16.
//
//

#import <UIKit/UIKit.h>
#import "TTBaseUserProfileCell.h"


@class TTThirdPartyAccountInfoBase;
typedef void (^TTTriggerBindingUserAccountBlock)(id sender, TTThirdPartyAccountInfoBase *info);

@interface TTUserBindAccountCell : TTBaseUserProfileCell
@property (nonatomic, copy) TTTriggerBindingUserAccountBlock callbackDidTapBindingAccount;

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier;
- (void)reloadWithAccountInfo:(TTThirdPartyAccountInfoBase *)accountItem;
@end
