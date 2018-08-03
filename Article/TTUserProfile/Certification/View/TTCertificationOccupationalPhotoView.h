//
//  TTCertificationOccupationalPhotoView.h
//  Article
//
//  Created by wangdi on 2017/5/21.
//
//

#import "SSThemed.h"
#import "TTBaseInfoPhotoItemImageView.h"

@interface TTCertificationOccupationalPhotoView : SSThemedView

@property (nonatomic, copy) void (^takePhotoBlock)();
- (void)setImage:(UIImage *)image;
- (BOOL)isCompleted;

@end
