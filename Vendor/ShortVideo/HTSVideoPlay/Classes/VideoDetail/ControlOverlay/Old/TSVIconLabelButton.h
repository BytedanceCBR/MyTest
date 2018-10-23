//
//  HTSVideoDetailButton.h
//  LiveStreaming
//
//  Created by willorfang on 16/6/30.
//  Copyright © 2016年 Bytedance. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface TSVIconLabelButton : UIControl

@property (nonatomic, strong, readonly) UIImageView *iconImageView;
@property (nonatomic, strong, readonly) UILabel *label;

@property (nonatomic, copy) NSString *labelString;
@property (nonatomic, copy) NSString *imageString;

- (instancetype)initWithImage:(NSString *)imageName label:(NSString *)labelString;

@end
