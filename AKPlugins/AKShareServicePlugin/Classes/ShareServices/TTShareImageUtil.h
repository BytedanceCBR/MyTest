//
//  TTShareImageUtil.h
//  TTShare
//
//  Created by muhuai on 18/01/02.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface TTShareImageUtil: NSObject

+ (void)downloadImageDataWithURL:(NSURL *)url limitLength:(NSUInteger)limitLength completion:(void (^)(NSData *, NSError *))completion;

+ (NSData *)compressImage:(UIImage *)image withLimitLength:(NSUInteger)limitLength;

+ (NSData *)drawNewImage:(UIImage *)image withSize:(CGSize)size;
@end
