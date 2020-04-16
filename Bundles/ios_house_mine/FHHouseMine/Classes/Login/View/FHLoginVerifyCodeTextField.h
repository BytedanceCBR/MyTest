//
//  FHLoginVerifyCodeTextField.h
//  Pods
//
//  Created by bytedance on 2020/4/15.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol FHVerifyCodeTextFieldDeleteDelegate <NSObject>

- (void)didClickBackWard;

@end

@interface FHLoginVerifyCodeTextField : UITextField

@property (nonatomic, weak) id<FHVerifyCodeTextFieldDeleteDelegate> deleteDelegate;

@end

NS_ASSUME_NONNULL_END
