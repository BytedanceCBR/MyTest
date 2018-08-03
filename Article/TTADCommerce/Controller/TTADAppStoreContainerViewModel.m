//
//  TTADAppStoreContainerViewModel.m
//  Article
//
//  Created by rongyingjie on 2017/11/26.
//

#import <Foundation/Foundation.h>
#import "TTADAppStoreContainerViewModel.h"
#import "TTImageInfosModel.h"
#import "NSDictionary+TTAdditions.h"
#import "TTAnimatedImageView.h"
#import "TTArticleCellConst.h"

@interface TTADAppStoreContainerViewModel ()

@property (nonatomic, strong, readwrite) TTImageInfosModel *imageInfoModel;

@end

@implementation TTADAppStoreContainerViewModel

+ (BOOL)validateInfoDict:(NSDictionary *)infoDict
{
    if (!([infoDict tt_arrayValueForKey:@"head_image_list"] || [infoDict tt_dictionaryValueForKey:@"head_video_info"])) {
        return NO;
    }
    if (![infoDict tt_stringValueForKey:@"itunes_id"]) {
        return NO;
    }
    return YES;
}

- (instancetype)initWithDict:(NSDictionary *)dict {
    if (self = [super init]) {
        _surfaceDes = [[dict tt_stringValueForKey:@"surface_description"] copy];
        _displayTime = [dict tt_floatValueForKey:@"display_time"];
        _imageInfoModel = [self initializeImageModel:dict];
        _itunesId = [[dict tt_stringValueForKey:@"itunes_id"] copy];
        _adId = [[dict tt_stringValueForKey:@"ad_id"] copy];
        _logExtra = [[dict tt_stringValueForKey:@"log_extra"] copy];
        _isWaitTimeout = NO;
    }
    return self;
}

- (TTImageInfosModel *)initializeImageModel:(NSDictionary *)dict {
    TTImageInfosModel *imageInfoModel = nil;
    NSArray *imageLists = [dict arrayValueForKey:@"head_image_list"
                                    defaultValue:nil];
    if ([imageLists count] > 0) {
        NSDictionary *dataDict = [imageLists objectAtIndex:0];
        imageInfoModel = [[TTImageInfosModel alloc] initWithDictionary:dataDict];
    }
    return imageInfoModel;
}

- (CGFloat)imageHeight:(CGFloat)screenWidth {
    CGFloat height = 0;
    if (self.imageInfoModel.width) {
        height = self.imageInfoModel.height / self.imageInfoModel.width * screenWidth;
    }
    return height;
}

- (BOOL)isHiddenDescription {
    return !self.surfaceDes.length;
}

+ (TTImageView *)initalizeImageView {
    TTImageView *imageView = [[TTAnimatedImageView alloc] init];
    imageView.borderColorThemeKey = kPicViewBorderColor();
    imageView.backgroundColorThemeKey = kPicViewBackgroundColor();
    imageView.layer.borderWidth = [TTDeviceHelper ssOnePixel];
    imageView.imageContentMode = UIViewContentModeScaleAspectFill;
    return imageView;
}

+ (BOOL)systemlowThan9 {
    return [UIDevice currentDevice].systemVersion.floatValue < 9;
}

+ (SSThemedLabel *)initializeDesLabel{
    SSThemedLabel *desLabel = [[SSThemedLabel alloc] init];
    desLabel.backgroundColor = [UIColor clearColor];
    desLabel.font = [UIFont boldSystemFontOfSize:16];
    desLabel.textAlignment = NSTextAlignmentCenter;
    desLabel.textColor = [UIColor whiteColor];
    desLabel.numberOfLines = 1;
    return desLabel;
}
@end

