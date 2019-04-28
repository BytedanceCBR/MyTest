//
//  TTPlayerVolumeView.h
//  Article
//
//  Created by 赵晶鑫 on 12/09/2017.
//
//

#import <UIKit/UIKit.h>
#import "TTVideoVolumeService.h"

@interface TTPlayerVolumeView : UIView

@property (nonatomic, weak) TTVideoVolumeService *service;

- (void)showAnimated:(BOOL)animated;
- (void)dismissAnimated:(BOOL)animated;

- (void)updateVolumeValue:(float)volume;

@end
