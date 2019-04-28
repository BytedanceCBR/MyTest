//
//  TTBaseInfoPhotoView.h
//  Article
//
//  Created by wangdi on 2017/5/18.
//
//

#import "TTAlphaThemedButton.h"
#import "TTBaseInfoPhotoItemImageView.h"

@interface TTBaseInfoPhotoItemView : TTAlphaThemedButton

@end

typedef enum {
    TTPhotoTypeIDCard,
    TTPhotoTypePerson
    
}TTPhotoType;

@interface TTBaseInfoPhotoView : SSThemedView

@property (nonatomic, copy) void (^takePhotoBlock)(TTPhotoType photoType);
- (void)setImage:(UIImage *)image photoType:(TTPhotoType)photoType;
- (BOOL)isCompleted;
- (NSDictionary *)images;

@end
