//
//  UIImage+WDUploadIdentify.h
//  WDPublisher
//
//  Created by 延晋 张 on 2018/1/23.
//

#import <UIKit/UIKit.h>

@interface UIImage (WDUploadIdentify)

- (NSString *)uploadIdentifier;
- (void)setUploadIdentifier:(NSString *)uploadIdentifier;

@end
