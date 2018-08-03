//
//  TTAlbumModel.h
//  Article
//
//  Created by tyh on 2017/4/11.
//
//

#import <Foundation/Foundation.h>
#import "TTAssetModel.h"

//相册Model
@interface TTAlbumModel : NSObject
@property (nonatomic, strong) NSString *name;        ///< The album name
@property (nonatomic, assign) NSInteger count;       ///< Count of photos the album contain
@property (nonatomic, strong) id result;             ///< PHFetchResult<PHAsset> or ALAssetsGroup<ALAsset>
@property (nonatomic, strong) NSArray<TTAssetModel *> *models;

@end
