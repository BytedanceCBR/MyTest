//
//  TTRNProfileView.h
//  Article
//
//  Created by Chen Hong on 16/8/7.
//
//

#import "TTMomentProfileBaseView.h"
#import "TTRNView.h"

@class SSUserModel;

@interface TTRNProfileView : TTMomentProfileBaseView

- (id)initWithFrame:(CGRect)frame userModel:(SSUserModel *)model source:(NSString *)source refer:(NSString *)refer;

- (void)setRNFatalHandler:(TTRNFatalHandler)handler;

@end
