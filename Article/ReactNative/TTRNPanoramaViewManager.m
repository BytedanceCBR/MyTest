//
//  TTRNPanoramaViewManager.m
//  Article
//
//  Created by yin on 2017/1/22.
//
//

#import "TTRNPanoramaViewManager.h"
#import "TTRNPanoramaView.h"

@implementation TTRNPanoramaViewManager

RCT_EXPORT_MODULE()

- (UIView *)view
{
    TTRNPanoramaView *panoramaView = [[TTRNPanoramaView alloc] init];
    return panoramaView;
}

RCT_EXPORT_VIEW_PROPERTY(source, NSDictionary)
RCT_EXPORT_VIEW_PROPERTY(enable, BOOL)

@end
