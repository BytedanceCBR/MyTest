//
//  UITextView+TTAdditions.h
//  Pods
//
//  Created by zhaoqin on 8/22/16.
//
//

#import <UIKit/UIKit.h>

@interface UITextView (TTAdditions)

@property (nonatomic, strong) NSString *placeHolder;
@property (nonatomic, strong) UIColor *placeHolderColor;
@property (nonatomic, strong) UIFont *placeHolderFont;
@property (nonatomic, assign) UIEdgeInsets placeHolderEdgeInsets;

/**
 *  根据输入的文字决定是否隐藏placeHoler
 */
- (void)showOrHidePlaceHolderTextView;

/**
 *  同步placeHolder字体
 */
- (void)syncFontWithPlaceHolderFont;

- (void)syncTextAlignmentWithPlaceHoler;

@end
