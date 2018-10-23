//
//  AKProfileHeaderViewUnLogin.h
//  Article
//
//  Created by chenjiesheng on 2018/3/2.
//

#import <UIKit/UIKit.h>

@protocol AKProfileHeaderViewUnLoginDelegate <NSObject>

- (void)loginButtonClicked:(NSString *)platform;

@end

@interface AKProfileHeaderViewUnLogin : UIView

@property (nonatomic, weak)NSObject<AKProfileHeaderViewUnLoginDelegate> *delegate;

@end
