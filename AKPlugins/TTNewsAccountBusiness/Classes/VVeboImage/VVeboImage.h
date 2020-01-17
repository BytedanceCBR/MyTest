//
//  VVeboImage.h
//  vvebo
//
//  Created by Johnil on 14-3-6.
//  Copyright (c) 2014年 Johnil. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VVeboImage : UIImage

@property (nonatomic,assign) NSInteger currentPlayIndex;
@property (nonatomic,strong) NSData *data;

+ (VVeboImage *)gifWithData:(NSData *)data;
- (UIImage *)nextImage;
- (int)count;
- (float)frameDuration;
- (void)resumeIndex;
/// 是否还有下一桢
- (BOOL) hasNextImage;

@end
