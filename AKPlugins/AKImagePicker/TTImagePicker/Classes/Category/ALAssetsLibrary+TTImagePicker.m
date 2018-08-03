//
//  ALAssetsLibrary+TTImagePicker.m
//  Pods
//
//  Created by SongChai on 15/06/2017.
//
//

#import "ALAssetsLibrary+TTImagePicker.h"
#import "TTIndicatorView.h"
#import "TTThemedAlertController.h"
#import "UIViewAdditions.h"
#import "TTIndicatorView.h"
#import "UIImage+TTThemeExtension.h"
#import "TTUIResponderHelper.h"
#import "TTDeviceHelper.h"
#import "TTBaseMacro.h"
#import "UIDevice+TTAdditions.h"
#import "TTSandBoxHelper.h"

@implementation ALAssetsLibrary (TTImagePicker)

+ (instancetype) tt_defaultAssetsLibrary {
    static ALAssetsLibrary *library;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        library = [[self alloc] init];
    });
    return library;
}

- (TTImagePickerSaveImageCompletion) tt_defaultCompleteBlock {
    return ^(NSError *error) {
        if (error != NULL) {
            NSString * errorTip = nil;
            if (([[[UIDevice currentDevice] freeDiskSpace] longLongValue] / (1024 * 1024.f)) < 5.f) {
                errorTip = NSLocalizedString(@"您的磁盘剩余空间不足", nil);
            }
            else {
                errorTip = [NSString stringWithFormat:NSLocalizedString(@"保存失败，由于系统限制，请在“设置-隐私-照片”中，重新允许%@即可", nil), [TTSandBoxHelper appDisplayName]];
            }
            
            if ([errorTip length] > 0) {
                if ([[self class] tt_alertControllerEnabled]) {
                    TTThemedAlertController *alert = [[TTThemedAlertController alloc] initWithTitle:errorTip message:nil preferredType:TTThemedAlertControllerTypeAlert];
                    [alert addActionWithTitle:NSLocalizedString(@"确定", nil) actionType:TTThemedAlertActionTypeNormal actionBlock:nil];
                    [alert showFrom:[TTUIResponderHelper topmostViewController] animated:YES];
                }
                else {
                    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:errorTip
                                                                     message:nil
                                                                    delegate:nil
                                                           cancelButtonTitle:nil
                                                           otherButtonTitles:NSLocalizedString(@"确定", nil), nil];
                    [alert show];
                }
            }
        }
        else {
            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:NSLocalizedString(@"图片存储成功", nil) indicatorImage:[UIImage themedImageNamed:@"doneicon_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
        }
    };
}

- (ALAssetsLibraryWriteImageCompletionBlock) tt_defaultALAssetsLibraryWriteImageCompletionBlock:(TTImagePickerSaveImageCompletion)completionBlock
                                                                                  withAlbumName:(NSString*)albumName{
    
    if (isEmptyString(albumName)) {
        NSString * appName = [TTSandBoxHelper appDisplayName];
        if (isEmptyString(appName)) {
            appName = NSLocalizedString(@"头条", nil);
        }
        albumName = appName;
    }
    
    return ^(NSURL *assetURL, NSError *error) {
        if (error) {
            completionBlock(error);
        } else {
            [self assetForURL:assetURL resultBlock:^(ALAsset *asset) {
                __block BOOL groupHasExist = NO;
                
                
                [self enumerateGroupsWithTypes:ALAssetsGroupAlbum usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                    
                    if ([albumName compare:[group valueForProperty:ALAssetsGroupPropertyName]] == NSOrderedSame) {
                        groupHasExist = YES;
                        if (group.editable) {
                            [group addAsset:asset];
                        }
                    }
                    
                    if (group == nil && groupHasExist == NO) {
                        [self addAssetsGroupAlbumWithName:albumName resultBlock:^(ALAssetsGroup *group) {
                            if (group.editable) {
                                [group addAsset:asset];
                            }
                        } failureBlock:completionBlock];
                    }
                    
                } failureBlock:completionBlock];
            } failureBlock:completionBlock];
            
            completionBlock(nil);
        }
    };
}

#pragma -- mark public method

- (void)tt_saveImageData:(NSData *)imgData {
    [self tt_saveImageData:imgData toAlbum:nil withCompletionBlock:[self tt_defaultCompleteBlock]];
}

- (void)tt_saveImage:(UIImage *)img {
    [self tt_saveImage:img toAlbum:nil withCompletionBlock:[self tt_defaultCompleteBlock]];
}

- (void)tt_saveImage:(UIImage *)img withCompletionBlock:(TTImagePickerSaveImageCompletion)completionBlock {
    [self tt_saveImage:img toAlbum:nil withCompletionBlock:completionBlock];
}

- (void)tt_saveImage:(UIImage *)img toAlbum:(NSString *)albumName withCompletionBlock:(TTImagePickerSaveImageCompletion)completionBlock {
    [self writeImageToSavedPhotosAlbum:img.CGImage
                           orientation:(ALAssetOrientation)img.imageOrientation
                       completionBlock:[self tt_defaultALAssetsLibraryWriteImageCompletionBlock:completionBlock withAlbumName:albumName]];
}

- (void)tt_saveImageData:(NSData *)imgData toAlbum:(NSString *)albumName withCompletionBlock:(TTImagePickerSaveImageCompletion)completionBlock {
    [self writeImageDataToSavedPhotosAlbum:imgData
                                  metadata:nil
                           completionBlock:[self tt_defaultALAssetsLibraryWriteImageCompletionBlock:completionBlock withAlbumName:albumName]];
}

#define MaxImageDataSize (3 * 1024 * 1024)

+ (UIImage *)tt_fullSizeImageForAssetRepresentation:(ALAssetRepresentation *)assetRepresentation
{
    UIImage *result = nil;
    NSData *data = nil;
    
    uint8_t *buffer = (uint8_t *)malloc(sizeof(uint8_t)*[assetRepresentation size]);
    if (buffer != NULL) {
        NSError *error = nil;
        NSUInteger bytesRead = [assetRepresentation getBytes:buffer fromOffset:0 length:[assetRepresentation size] error:&error];
        data = [NSData dataWithBytes:buffer length:bytesRead];
        
        free(buffer);
    }
    
    if ([data length])
    {
        result = [UIImage imageWithData:data];
    }
    
    return result;
}

+ (UIImage *)tt_getBigImageFromAsset:(ALAsset *)asset
{
    UIImage * image = nil;
    ALAssetRepresentation * assetRepresentation = [asset defaultRepresentation];
    if ([assetRepresentation size] <= 0) {
        image = [UIImage imageWithCGImage:[asset aspectRatioThumbnail]];
    } else if ([assetRepresentation size] < MaxImageDataSize){
        
        if (([asset valueForProperty:ALAssetPropertyType] == ALAssetTypeVideo)) {
            image = [UIImage imageWithCGImage:[assetRepresentation fullScreenImage]];
        }
        else {
            image = [ALAssetsLibrary tt_fullSizeImageForAssetRepresentation:assetRepresentation];
            
            // luohuaqing: Try to use fullScreenImage as far as possible, since it's much smaller in size
            CGFloat longEdge = MAX(image.size.width, image.size.height);
            CGFloat shortEdge = MIN(image.size.width, image.size.height);
            if (longEdge / shortEdge <= [TTUIResponderHelper screenSize].height / [TTUIResponderHelper screenSize].width) {
                image = [UIImage imageWithCGImage:[assetRepresentation fullScreenImage]];
            }
        }
        
        
    } else {
        image = [UIImage imageWithCGImage:[assetRepresentation fullScreenImage]];
    }
    
    return image;
}

+ (UIImage *)tt_fullResolutionImageFromAsset:(ALAsset *)asset
{
    UIImage * image = nil;
    ALAssetRepresentation * assetRepresentation = [asset defaultRepresentation];
    if ([assetRepresentation size] <= 0) {
        image = [UIImage imageWithCGImage:[asset aspectRatioThumbnail]];
    }
    else {
        UIImageOrientation orientation = UIImageOrientationUp;
        NSNumber *orientationValue = [asset valueForProperty:@"ALAssetPropertyOrientation"];
        if (orientationValue != nil) {
            //wanglin:get the correct orientation from EXIF(meta data) if orientation exists
            orientation = [orientationValue integerValue];
        }
        
        CGImageRef iref = [assetRepresentation fullResolutionImage];
        if (iref) {
            image = [UIImage imageWithCGImage:iref scale:1.0 orientation:orientation];
        }
    }
    return image;
}

+ (BOOL)tt_alertControllerEnabled {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"SSCommonLogicTTAlertControllerEnabledKey"]) {
        return [[NSUserDefaults standardUserDefaults] boolForKey:@"SSCommonLogicTTAlertControllerEnabledKey"];
    }
    else {
        //默认否
        return NO;
    }
}

@end
