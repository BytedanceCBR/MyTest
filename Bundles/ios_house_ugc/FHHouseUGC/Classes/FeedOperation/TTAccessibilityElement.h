//
//  TTAccessibilityElement.h
//  TTPlatformUIModel
//
//  Created by 王振旺 on 2018/8/15.
//

#import <UIKit/UIKit.h>

@interface TTAccessibilityElement : UIAccessibilityElement

@property (nonatomic, copy) NSString * (^labelBlock)();
@property (nonatomic, copy) BOOL (^activateActionBlock)();

@end
