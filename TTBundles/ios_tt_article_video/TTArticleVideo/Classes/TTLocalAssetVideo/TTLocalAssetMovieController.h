//
//  TTLocalAssetMovieController.h
//  Article
//
//  Created by xiangwu on 2016/12/8.
//
//

#import <UIKit/UIKit.h>

@interface TTLocalAssetMoviePlayModel : NSObject

@property (nonatomic, copy) NSString *playURL;
@property (nonatomic, copy) NSString *videoID;

@end

@interface TTLocalAssetMovieController : NSObject

@property (nonatomic, strong, readonly) UIView *movieView;
@property (nonatomic, strong) TTLocalAssetMoviePlayModel *playModel;
@property (nonatomic, copy) dispatch_block_t movieFinishBlock;

- (void)play;
- (void)stop;
- (void)pause;

@end
