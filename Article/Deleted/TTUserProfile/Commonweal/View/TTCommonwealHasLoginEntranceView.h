//
//  TTCommonwealHasLoginEntranceView.h
//  Article
//
//  Created by wangdi on 2017/8/10.
//
//

#import "TTAlphaThemedButton.h"

#define kCommonwealHasLoginEntranceViewH [TTDeviceUIUtils tt_newPadding:40]
#define kCommonwealHasLoginEntranceViewW [TTDeviceUIUtils tt_newPadding:94]

@interface TTCommonwealHasLoginEntranceView : TTAlphaThemedButton

- (void)setTopTitle:(NSString *)topTitle bottomTitle:(NSString *)bottomTitle isSelected:(BOOL)isSelected;

@end
