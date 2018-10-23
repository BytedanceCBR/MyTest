//
//  TTSegmentedControl.h
//  Article
//
//  Created by yuxin on 11/26/15.
//
//

#import <UIKit/UIKit.h>

@interface TTSegmentedControl : UISegmentedControl

@property (nonatomic, copy) IBInspectable NSString *backgroundColorThemeKey;
@property (nonatomic, strong) NSMutableArray * badgeViews;

@end
