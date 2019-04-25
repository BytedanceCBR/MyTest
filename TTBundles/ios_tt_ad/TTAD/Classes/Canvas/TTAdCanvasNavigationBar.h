//
//  TTAdCanvasNavigationBar.h
//  Article
//
//  Created by carl on 2017/6/6.
//
//

#import <UIKit/UIKit.h>
#import "TTThemed/SSViewBase.h"
#import "TTAlphaThemedButton.h"

@interface TTAdCanvasNavigationBar : SSViewBase
@property (nonatomic, strong) TTAlphaThemedButton *leftButton;
@property (nonatomic, strong) TTAlphaThemedButton *rightButton;
@end
