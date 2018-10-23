//
//  TTRNImageView.m
//  Article
//
//  Created by Chen Hong on 2016/10/25.
//
//

#import "TTRNImageView.h"
#import "RCTAutoInsetsProtocol.h"
#import "RCTConvert.h"
#import "RCTEventDispatcher.h"
#import "RCTLog.h"
#import "RCTUtils.h"
#import "RCTView.h"
#import "UIView+React.h"
#import "UIImage+MultiFormat.h"
#import "TTImageView.h"
#import "SSSimpleCache.h"
#import "TTAdLog.h"
/**
 *
 import {requireNativeComponent} from 'react-native';
 
 var TTRNImageView = requireNativeComponent('TTRNImageView', TTRNImageView);
 
 <TTRNImageView
 source={{uri: 'https://facebook.github.io/react/img/logo_og.png'}}
 style={{width: 320, height: 320, borderRadius: 33, borderWidth: 2, borderColor:'#fff'}}
 />
 
 */

@interface TTRNImageView ()
@property(nonatomic, strong)TTImageView *imageView;
@end

@implementation TTRNImageView

- (instancetype)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        super.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = YES;
        _imageView = [[TTImageView alloc] initWithFrame:self.bounds];
        _imageView.enableNightCover = NO;
        [self addSubview:_imageView];
    }
    return self;
}

- (void)setSource:(NSDictionary *)source
{
    if (![_source isEqualToDictionary:source]) {
        _source = [source copy];
        
        NSString *url = [RCTConvert NSString:source[@"uri"]];
        NSString* tagUri = [RCTConvert NSString:source[@"tag"]];
        UIImage *cachedImage = nil;
        if (!isEmptyString(tagUri)&&[[SSSimpleCache sharedCache] isCacheExist:tagUri]) {
            cachedImage = [UIImage sd_imageWithData:[[SSSimpleCache sharedCache] dataForUrl:tagUri]];
        } else if ([[SSSimpleCache sharedCache] isCacheExist:url]) {
           cachedImage = [UIImage sd_imageWithData:[[SSSimpleCache sharedCache] dataForUrl:url]];
        }
        
        if (cachedImage) {
            DLog(@"RESOURCE %s hittouch a %@", __PRETTY_FUNCTION__, url);
            _imageView.imageView.image = cachedImage;
        } else {
            if ([url hasPrefix:@"http://"]) {
                NSString *placeholder = [RCTConvert NSString:source[@"default_uri"]];
                [_imageView setImageWithURLString:url placeholderImage:[UIImage imageNamed:placeholder]];
            } else {
                [_imageView setImage:[UIImage imageNamed:url]];
            }
        }
        
        self.layer.minificationFilter = kCAFilterTrilinear;
        self.layer.magnificationFilter = kCAFilterTrilinear;
    }
}



- (void)layoutSubviews
{
    [super layoutSubviews];
    _imageView.frame = self.bounds;
}

- (void)setResizeMode:(RCTResizeMode)resizeMode
{
    if (_resizeMode != resizeMode) {
        _resizeMode = resizeMode;
        
        if (_resizeMode == RCTResizeModeRepeat) {
            _imageView.imageContentMode = TTImageViewContentModeScaleToFill;
        } else {
            _imageView.imageContentMode = (TTImageViewContentMode)resizeMode;
        }
    }
}

- (void)dealloc
{
    
}

@end
