//
//  NSBundle+TTAResources.m
//  TTAccountSDK
//
//  Created by liuzuopeng on 4/19/17.
//
//

#import "NSBundle+TTAResources.h"
#import <UIKit/UIScreen.h>
#import <objc/runtime.h>



#define __IS_IPAD__     (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define __IS_IPHONE__   (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)


@implementation NSBundle (tta_ResourceBundle)

+ (NSString *)__tta_bundleName__
{
    return @"TTAccountAssets";
}

+ (NSBundle *)tta_resourceBundle
{
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *subBundlePath = [mainBundle pathForResource:[self __tta_bundleName__] ofType:@"bundle"];
    NSBundle *subBundle = [NSBundle bundleWithPath:subBundlePath];
    return subBundle;
}

@end



@implementation UIImage (tta_AccountResources)

+ (UIImage *)tta_imageNamed:(NSString *)name
{
    if (!name) return nil;
    
    typedef
    NS_ENUM (NSInteger, TTAImageNameFixType) {
        TTAImageNameAppendScale,
        TTAImageNameAppendSuffix,
        TTAImageNameAppendScaleSuffix,
        TTAImageNameAppendScaleIPad,
        TTAImageNameAppendSuffixIpad,
        TTAImageNameAppendScaleSuffixIpad
    };
    
    NSString* (^tta_fixedImageNameBlock)(TTAImageNameFixType) = ^(TTAImageNameFixType fixType) {
        NSRange dot = [name rangeOfString:@"." options:NSBackwardsSearch];
        NSString *namePrefix = name;
        NSString *nameSuffix = @"png";
        if (dot.location != NSNotFound) {
            namePrefix = [name substringToIndex:dot.location];
            nameSuffix = [name substringFromIndex:dot.location + 1];
        }
        
        NSString *imageName = nil;
        switch (fixType) {
            case TTAImageNameAppendScale: {
                if (fabs([UIScreen mainScreen].scale - 2) <= FLT_EPSILON) {
                    imageName = [namePrefix stringByAppendingString:@"@2x"];
                } else if (fabs([UIScreen mainScreen].scale - 3) <= FLT_EPSILON) {
                    imageName = [namePrefix stringByAppendingString:@"@3x"];
                }
            }
                break;
                
            case TTAImageNameAppendScaleIPad: {
                if (fabs([UIScreen mainScreen].scale - 2) <= FLT_EPSILON) {
                    imageName = [namePrefix stringByAppendingString:@"@2x"];
                } else if (fabs([UIScreen mainScreen].scale - 3) <= FLT_EPSILON) {
                    imageName = [namePrefix stringByAppendingString:@"@3x"];
                }
                if (__IS_IPAD__) {
                    imageName = [imageName stringByAppendingString:@"~ipad"];
                }
            }
                break;
                
            case TTAImageNameAppendSuffix: {
                imageName = [namePrefix stringByAppendingFormat:@".%@", nameSuffix];
            }
                break;
                
            case TTAImageNameAppendSuffixIpad: {
                imageName = [namePrefix stringByAppendingFormat:@".%@", nameSuffix];
                if (__IS_IPAD__) {
                    imageName = [imageName stringByAppendingString:@"~ipad"];
                }
            }
                break;
                
            case TTAImageNameAppendScaleSuffix: {
                if (fabs([UIScreen mainScreen].scale - 2) <= FLT_EPSILON) {
                    imageName = [namePrefix stringByAppendingFormat:@"@2x.%@", nameSuffix];
                } else if (fabs([UIScreen mainScreen].scale - 3) <= FLT_EPSILON) {
                    imageName = [namePrefix stringByAppendingFormat:@"@3x.%@", nameSuffix];
                }
            }
                break;
                
            case TTAImageNameAppendScaleSuffixIpad: {
                if (fabs([UIScreen mainScreen].scale - 2) <= FLT_EPSILON) {
                    imageName = [namePrefix stringByAppendingFormat:@"@2x.%@", nameSuffix];
                } else if (fabs([UIScreen mainScreen].scale - 3) <= FLT_EPSILON) {
                    imageName = [namePrefix stringByAppendingFormat:@"@3x.%@", nameSuffix];
                }
                if (__IS_IPAD__) {
                    imageName = [imageName stringByAppendingString:@"~ipad"];
                }
            }
                break;
        }
        return imageName;
    };
    
    UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.bundle/images/%@", [NSBundle __tta_bundleName__], name]];
    if (image) return image;
    
    
    image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.bundle/images/%@", [NSBundle __tta_bundleName__], tta_fixedImageNameBlock(TTAImageNameAppendScale)]];
    if (image) return image;
    
    
    image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.bundle/images/%@", [NSBundle __tta_bundleName__], tta_fixedImageNameBlock(TTAImageNameAppendSuffix)]];
    if (image) return image;
    
    
    image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.bundle/images/%@", [NSBundle __tta_bundleName__], tta_fixedImageNameBlock(TTAImageNameAppendScaleSuffix)]];
    if (image) return image;
    
    
    if (__IS_IPAD__) {
        image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.bundle/images/%@", [NSBundle __tta_bundleName__], tta_fixedImageNameBlock(TTAImageNameAppendScaleIPad)]];
        if (image) return image;
        
        
        image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.bundle/images/%@", [NSBundle __tta_bundleName__], tta_fixedImageNameBlock(TTAImageNameAppendSuffixIpad)]];
        if (image) return image;
        
        
        image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.bundle/images/%@", [NSBundle __tta_bundleName__], tta_fixedImageNameBlock(TTAImageNameAppendScaleSuffixIpad)]];
        if (image) return image;
    }
    
    
    if (!image) {
        static NSArray<NSString *> *pngs = nil;
        if (!pngs) {
            pngs = [[NSBundle tta_resourceBundle] pathsForResourcesOfType:@"png" inDirectory:@"images"];
        }
        
        __block NSInteger foundIdx = NSNotFound;
        [pngs enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj tta_containsString:name]) {
                foundIdx = idx;
            }
        }];
        
        if (foundIdx != NSNotFound) {
            image = [UIImage imageWithContentsOfFile:pngs[foundIdx]];
            return image;
        }
    }
    
    return nil;
}

@end



@implementation UIImageView (tta_ImageLoaderByName)

- (void)setTta_imageName:(NSString *)tta_imageName
{
    if (![self.tta_imageName isEqualToString:tta_imageName]) {
        objc_setAssociatedObject(self, @selector(tta_imageName), tta_imageName, OBJC_ASSOCIATION_COPY_NONATOMIC);
        
        self.image = [UIImage tta_imageNamed:tta_imageName];
    }
}

- (NSString *)tta_imageName
{
    NSString *imageNameString = objc_getAssociatedObject(self, _cmd);
    if ([imageNameString isKindOfClass:[NSString class]]) {
        return imageNameString;
    }
    return nil;
}

@end



@implementation UIButton (tta_ImageLoaderByName)

- (void)setTta_imageName:(NSString *)tta_imageName
{
    if (![self.tta_imageName isEqualToString:tta_imageName]) {
        objc_setAssociatedObject(self, @selector(tta_imageName), tta_imageName, OBJC_ASSOCIATION_COPY_NONATOMIC);
        
        UIImage *image = [UIImage tta_imageNamed:tta_imageName];
        [self setImage:image forState:UIControlStateNormal];
    }
}

- (NSString *)tta_imageName
{
    NSString *imageNameString = objc_getAssociatedObject(self, _cmd);
    if ([imageNameString isKindOfClass:[NSString class]]) {
        return imageNameString;
    }
    return nil;
}

- (void)setTta_hlImageName:(NSString *)tta_hlImageName
{
    
    if (![self.tta_imageName isEqualToString:tta_hlImageName]) {
        objc_setAssociatedObject(self, @selector(tta_hlImageName), tta_hlImageName, OBJC_ASSOCIATION_COPY_NONATOMIC);
        
        UIImage *hlImage = [UIImage tta_imageNamed:tta_hlImageName];
        [self setImage:hlImage forState:UIControlStateHighlighted];
    }
}

- (NSString *)tta_hlImageName
{
    NSString *imageNameString = objc_getAssociatedObject(self, _cmd);
    if ([imageNameString isKindOfClass:[NSString class]]) {
        return imageNameString;
    }
    return nil;
}

@end

