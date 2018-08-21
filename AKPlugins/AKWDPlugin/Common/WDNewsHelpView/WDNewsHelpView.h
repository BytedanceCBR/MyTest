//
//  WDNewsHelpView.h
//  Article
//
//  Created by Dianwei on 12-7-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSViewBase.h"

@interface WDNewsHelpView : SSViewBase
@property(nonatomic, retain)UIImageView *imageView;
@property(nonatomic, retain)UILabel *textLabel1;
@property(nonatomic, retain)UIView *bgView;

- (void)setImage:(UIImage*)image;
- (void)setText:(NSString*)text1;

@end
