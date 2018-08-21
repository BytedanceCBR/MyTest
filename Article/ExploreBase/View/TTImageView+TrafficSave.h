//
//  TTImageView+TrafficSave.h
//  Article
//
//  Created by Chen Hong on 14-9-28.
//
//

#import "TTImageView.h"

@interface TTImageView (TrafficSave)

- (void)setImageWithURLStringInTrafficSaveMode:(NSString *)URLString placeholderImage:(UIImage *)placeholder;

- (void)setImageWithModelInTrafficSaveMode:(TTImageInfosModel *)model placeholderImage:(UIImage *)placeholder;

- (void)setImageWithModelInTrafficSaveMode:(TTImageInfosModel *)model
                          placeholderImage:(UIImage *)placeholder
                                   success:(TTImageViewSuccessBlock)success
                                   failure:(TTImageViewFailureBlock)failure;
@end
