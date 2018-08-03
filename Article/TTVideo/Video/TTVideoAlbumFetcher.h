//
//  TTVideoAlbumFetcher.h
//  Article
//
//  Created by 刘廷勇 on 16/1/13.
//
//

#import <Foundation/Foundation.h>

typedef void(^TTAlbumFetchCompletion)(NSArray *albums, NSError *error);

@interface TTVideoAlbumFetcher : NSObject

+ (void)startFetchWithURL:(NSString *)url completion:(TTAlbumFetchCompletion)completion;

@end
