//
//  TTWebImageManager+TTVSupport.h
//  Article
//
//  Created by pei yun on 2017/7/5.
//
//

#import <TTImage/TTWebImageManager.h>
#import <TTVideoService/Common.pbobjc.h>

@interface TTWebImageManager (TTVSupport)

+ (UIImage *)imageForTTVImageUrlList:(TTVImageUrlList *)urlList;

@end
