//
//  TTAdCanvasViewModel.m
//  Article
//
//  Created by carl on 2017/7/16.
//
//

#import "TTAdCanvasViewModel.h"

#import "TTAdCanvasUtils.h"
#import "TTAdCanvasManager.h"

@implementation TTAdCanvasViewModel

- (instancetype)initWithCondition:(NSDictionary *)condition {
    self = [super init];
    if (self) {
        self.ad_id = condition[@"ad_id"];
        self.log_extra = condition[@"log_extra"];
        NSString *root_color = condition[@"root_color"];
        self.rootViewColor = [TTAdCanvasUtils colorWithCanvasRGBAString:root_color];
    }
    return self;
}

- (instancetype)initWithModel:(TTAdCanvasProjectModel *)projectModel {
    self = [super init];
    if (self) {
        TTAdCanvasResourceModel *resourceModel = projectModel.resource;
        if (resourceModel.animationStyle) {
            self.animationStyle = [resourceModel.animationStyle integerValue];
        } else {
            self.animationStyle = TTAdCanvasOpenAnimationMoveUp;
        }
        
        self.hasCreateFeedData = resourceModel.hasCreateFeedData;
        
        if (projectModel.resource.image.count > 0) {
            NSDictionary *imageInfo = projectModel.resource.image.firstObject;
            self.canvasImageModel = [[TTImageInfosModel alloc] initWithDictionary:imageInfo];
        }
        
        self.layoutInfo = [TTAdCanvasManager parseJsonDict:projectModel];
        self.rootViewColor = [TTAdCanvasUtils colorWithCanvasRGBAString:resourceModel.rootViweColorString];
    }
    return self;
}

- (NSDictionary *)adInfo {
    if (!_adInfo) {
        NSMutableDictionary *adInfo = [NSMutableDictionary dictionary];
        [adInfo setValue:self.ad_id forKey:@"cid"];
        [adInfo setValue:self.log_extra forKey:@"log_extra"];
        _adInfo = adInfo;
    }
    return _adInfo;
}

@end
