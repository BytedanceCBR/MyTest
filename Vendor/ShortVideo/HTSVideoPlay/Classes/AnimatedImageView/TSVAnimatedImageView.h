//
//  SRVAnimatedImageView.h
//  Pods
//
//  Created by Zuyang Kou on 14/08/2017.
//
//

#import <YYImage/YYImage.h>
#import <TTImageView.h>

@protocol TSVImageViewProtocol <NSObject>

- (void)tsv_setImageWithModel:(TTImageInfosModel *)model
             placeholderImage:(UIImage *)placeholder;

- (void)tsv_setImageWithModel:(TTImageInfosModel *)model
             placeholderImage:(UIImage *)placeholder
                      options:(SDWebImageOptions)options
              isAnimatedImage:(BOOL)isAnimatedImage
                      success:(TTImageViewSuccessBlock)success
                      failure:(TTImageViewFailureBlock)failure;

@property(nonatomic, copy) IBInspectable NSString *backgroundColorThemeKey;

@property(nonatomic, assign) TTImageViewContentMode imageContentMode;

@end

@interface TTImageView (TSVImageViewProtocol) <TSVImageViewProtocol>

@end

@interface TSVAnimatedImageView : YYAnimatedImageView<TSVImageViewProtocol>

@property(nonatomic, copy) IBInspectable NSString *backgroundColorThemeKey;
@property(nonatomic, copy) IBInspectable NSString *borderColorThemeKey;

@property(nonatomic, assign) TTImageViewContentMode imageContentMode;

@end
