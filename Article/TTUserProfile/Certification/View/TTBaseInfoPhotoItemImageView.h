//
//  TTBaseInfoPhotoItemImageView.h
//  Article
//
//  Created by wangdi on 2017/5/21.
//
//

#import "SSThemed.h"

#define kDeletePhotoNotification  @"deletePhotoNotification"

@interface TTBaseInfoPhotoItemImageView : SSThemedView

@property (nonatomic, strong) SSThemedImageView *imageView;
- (void)setImage:(UIImage *)image;
@end
