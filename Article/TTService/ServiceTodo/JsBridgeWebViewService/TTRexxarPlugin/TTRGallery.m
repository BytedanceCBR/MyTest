//
//  TTRGallery.m
//  Article
//
//  Created by muhuai on 2017/5/21.
//
//

#import "TTRGallery.h"
#import <TTPhotoScrollVC/TTPhotoScrollViewController.h>
#import <TTImage/TTImageInfosModel.h>

@implementation TTRGallery

- (void)galleryWithParam:(NSDictionary *)param callback:(TTRJSBResponse)callback webView:(UIView<TTRexxarEngine> *)webview controller:(UIViewController *)controller {
    NSArray *images = [param objectForKey:@"images"];
    NSArray *imageList = [param objectForKey:@"image_list"];
    if(images.count > 0 || imageList.count > 0)
    {
        TTPhotoScrollViewController *vc = [[TTPhotoScrollViewController alloc] init];
        vc.startWithIndex = [[param objectForKey:@"index"] intValue];
        if(imageList.count > 0)
        {
            NSMutableArray *models = [NSMutableArray arrayWithCapacity:imageList.count];
            for(NSDictionary *dict in imageList)
            {
                TTImageInfosModel *model = [[TTImageInfosModel alloc] initWithDictionary:dict];
                if (model) {
                    [models addObject:model];
                }
            }
            vc.imageInfosModels = models;
        }
        else if(images.count > 0)
        {
            vc.imageURLs = images;
        }
        
        [vc presentPhotoScrollView];
    }
    callback(TTRJSBMsgSuccess, @{@"code": @1});
}

@end
