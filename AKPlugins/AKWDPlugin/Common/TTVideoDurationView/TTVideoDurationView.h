//
//  TTVideoDurationView.h
//  Article
//
//  Created by xuzichao on 2016/12/20.
//
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface TTVideoDurationView : UIView

@property (nonatomic, assign) BOOL isLightStyle;

- (void)showLeftImage:(BOOL)show;

- (void)setLeftImage:(NSString *)imageName;

- (void)setDurationText:(NSString *)text;

@end
