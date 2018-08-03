//
//  AKRedPacketOptionalLoginView.h
//  Article
//
//  Created by chenjiesheng on 2018/3/13.
//

#import <UIKit/UIKit.h>

@class TTAlphaThemedButton;

@protocol AKRedPacketOptionalLoginViewDelegate <NSObject>

@optional
- (void)arrowButtonClicked:(UIButton *)button;
- (void)loginButtonClicked:(UIButton *)button withPlatform:(NSString *)platform;

@end
@interface AKRedPacketOptionalLoginView : UIView

@property (nonatomic, strong, readonly)TTAlphaThemedButton                    *arrowButton;
@property (nonatomic, copy, readonly)  NSArray<TTAlphaThemedButton *>         *loginButtons;
@property (nonatomic, strong, readonly)UILabel                                *desLabel;
@property (nonatomic, copy, readonly)  NSArray<NSString *>                    *supportPlatforms;
@property (nonatomic, weak) NSObject<AKRedPacketOptionalLoginViewDelegate>    *delegate;

- (instancetype)initWithSupportPlatforms:(NSArray<NSString *> *)platfoms
                                delegate:(NSObject<AKRedPacketOptionalLoginViewDelegate> *)delegate;
- (void)showLoginButon;
- (void)hiddenLoginButton;
@end
