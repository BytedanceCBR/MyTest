//
//  TTVVideoDetailAlbumView.h
//  Article
//
//  Created by lishuangyang on 2017/6/18.
//
//
#import "SSThemed.h"
#import <TTVideoService/VideoInformation.pbobjc.h>
#import "TTVArticleProtocol.h"
#import "TTVVideoDetailAlbumViewModel.h"
@interface TTVVideoDetailAlbumView : SSThemedView

@property (nonatomic, strong)TTVVideoDetailAlbumViewModel *viewModel;

@end

@interface TTVVideoAlbumHolder : NSObject

@property (nonatomic, strong) TTVVideoDetailAlbumView *albumView;

+ (instancetype)holder;
+ (void)dispose;

@end
