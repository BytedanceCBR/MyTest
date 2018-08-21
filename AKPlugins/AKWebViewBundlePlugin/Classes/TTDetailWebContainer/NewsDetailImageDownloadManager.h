//
//  NewsDetailImageDownloadManager.h
//  Article
//
//  Created by Zhang Leonardo on 13-5-17.
//
//

#import <Foundation/Foundation.h>
#import "TTImageInfosModel.h"

//#define kNewsImageDownloadFinishedNotification @"kNewsImageDownloadFinishedNotification"
//#define kNewsImageDownloadModelKey @"kNewsImageDownloadModelKey"

@protocol NewsDetailImageDownloadManagerDelegate;

@interface NewsDetailImageDownloadManager : NSObject

@property(nonatomic, weak)id<NewsDetailImageDownloadManagerDelegate>delegate;

- (void)cancelAll;
- (void)cancelDownloadForImageModel:(TTImageInfosModel*)imageModel;
- (void)fetchImageWithModel:(TTImageInfosModel *)model insertTop:(BOOL)insert;
- (void)fetchImageWithModels:(NSArray *)models insertTop:(BOOL)insert;

@end

@protocol NewsDetailImageDownloadManagerDelegate<NSObject>

- (void)detailImageDownloadManager:(NewsDetailImageDownloadManager *)manager finishDownloadImageMode:(TTImageInfosModel *)model success:(BOOL)success;

@end
