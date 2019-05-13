//
//  TTPlayerResolutionDegradeTipView.h
//  Article
//
//  Created by 赵晶鑫 on 29/08/2017.
//
//

#import <UIKit/UIKit.h>

@interface TTPlayerResolutionDegradeTipView : UIView

@property (nonatomic, copy) void(^resolutionDegradeBlock)();
@property (nonatomic, copy) void(^closeBlock)();

- (BOOL)showIfNeeded;

@end
