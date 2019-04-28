//
//  UITextField+TTTouchAreaAddition.h
//  Article
//
//  Created by zuopengliu on 14/9/2017.
//
//

#import <UIKit/UIKit.h>



@interface UITextField (TTTouchAreaAddition)

/**
 点击区域的EdgeInset
 */
@property (nonatomic, assign) UIEdgeInsets excludedHitTestEdgeInsets;

@end
