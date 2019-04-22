//
//  SSADNewStyleViewButton.h
//  Article
//
//  Created by matrixzk on 10/30/15.
//
//

#import <UIKit/UIKit.h>

typedef void(^SplashADViewButtonTapHandler)();

@interface SSADNewStyleViewButton : UIView

@property (nonatomic, copy) SplashADViewButtonTapHandler buttonTapActionBlock;
@property (nonatomic, copy) NSString *titleText;

@end
