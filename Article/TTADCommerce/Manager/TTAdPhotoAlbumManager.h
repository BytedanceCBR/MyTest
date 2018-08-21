//
//  TTAdPhotoAlbumManager.h
//  Article
//
//  Created by yin on 16/8/4.
//
//

#import <Foundation/Foundation.h>
#import "TTPhotoDetailAdModel.h"
#import "TTPhotoDetailAdCollectionCell.h"
#import "TTAdSingletonManager.h"
#import <TTAdModule/TTAdConstant.h>
#import "TTAdManagerProtocol.h"

@protocol TTAdPhotoAlbumManagerDelegate <NSObject>

-(void)photoAlbum_downloadAdImageFinished;

@end

@interface TTAdPhotoAlbumManager : NSObject<TTAdSingletonProtocol>

/**
 *  图集页广告数据
 */
@property (nonatomic, strong, readonly) TTPhotoDetailAdModel* photoDetailAdModel;

@property (nonatomic, weak) __weak id<TTAdPhotoAlbumManagerDelegate>delegate;

+ (instancetype)sharedManager;

- (void)isNativePhotoAlbum:(BOOL)isNative;

- (void)fetchPhotoDetailAdModel:(TTPhotoDetailAdModel*)model;

- (void)fetchPhotoDetailAdModelDict:(NSDictionary*)dict;

- (TTPhotoDetailAdModel*)photoDetailAdModel;

- (TTPhotoDetailAdDisplayType)getPhotoDetailADDisplayType;

- (BOOL)hasPhotoDetailAd;

- (BOOL)hasFinishDownloadAdImage;

- (UIImage*)getAdImage;

- (NSString*)getImagePageTitle;

- (TTPhotoDetailAdCollectionCell*)cellForPhotoDetailAd;

- (void)adImageClickWithResponder:(UIResponder*)responder;

-(void)adCreativeButtonClickWithModel:(TTPhotoDetailAdModel *)adModel WithResponder:(UIResponder*)responder;

- (void)trackAdImageShow;

- (void)trackAdImageFinishLoad;

- (void)trackAdImageClick;

-(void)trackDownloadClick;

-(void)trackDownloadClickToAppstore;

-(void)trackDownloadClickToOpenApp;

@end
