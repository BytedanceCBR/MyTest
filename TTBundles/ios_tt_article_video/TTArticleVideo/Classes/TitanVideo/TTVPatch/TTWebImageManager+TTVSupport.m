//
//  TTWebImageManager+TTVSupport.m
//  Article
//
//  Created by pei yun on 2017/7/5.
//
//

#import "TTWebImageManager+TTVSupport.h"

@implementation TTWebImageManager (TTVSupport)

+ (UIImage *)imageForTTVImageUrlList:(TTVImageUrlList *)urlList
{
    if ([urlList.URLListArray count] == 0) {
        return nil;
    }
    else {
        for (int i = 0; i < [urlList.URLListArray count]; i++) {
            TTVAUrl *aurl = [urlList.URLListArray objectAtIndex:i];
            UIImage * img = [self imageForURLString:aurl.URL];
            if (img) {
                return img;
            }
        }
    }
    return nil;
}

@end
