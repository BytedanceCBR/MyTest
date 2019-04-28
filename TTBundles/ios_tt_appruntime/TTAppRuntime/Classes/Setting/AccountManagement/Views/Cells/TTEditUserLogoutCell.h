//
//  TTEditUserLogoutCell.h
//  Article
//
//  Created by Zuopeng Liu on 7/15/16.
//
//

#import <UIKit/UIKit.h>
#import "TTBaseUserProfileCell.h"


@interface TTEditUserLogoutCell : TTBaseUserProfileCell
- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier;
- (void)reloadWithTitle:(NSString *)title themeKey:(NSString *)titleTextThemeKey;
@end
