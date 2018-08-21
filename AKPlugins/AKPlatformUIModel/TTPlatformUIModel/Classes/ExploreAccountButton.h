//
//  ArticleXPAccountButton.h
//  Article
//
//  Created by SunJiangting on 14-4-13.
//
//

#import <UIKit/UIKit.h>
#import "TTThirdPartyAccountInfoBase.h"

@interface ExploreAccountButton : UIButton

@property (nonatomic, strong) TTThirdPartyAccountInfoBase * accountInfo;


- (void) reloadButtonState;
@end
