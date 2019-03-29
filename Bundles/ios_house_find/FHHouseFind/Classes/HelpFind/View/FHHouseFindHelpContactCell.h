//
//  FHHouseFindHelpContactCell.h
//  FHHouseFind
//
//  Created by 张静 on 2019/3/27.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol FHHouseFindLoginDelegate <NSObject>

- (void)confirm;

- (void)sendVerifyCode;

@end

@interface FHHouseFindHelpContactCell : UICollectionViewCell

@property(nonatomic, strong, readonly) UITextField *phoneInput;
@property(nonatomic, strong, readonly) UITextField *varifyCodeInput;
@property(nonatomic, strong) UIButton *sendVerifyCodeBtn;
@property(nonatomic , weak) id<FHHouseFindLoginDelegate> delegate;

- (void)enableSendVerifyCodeBtn:(BOOL)enabled;

@end

NS_ASSUME_NONNULL_END
