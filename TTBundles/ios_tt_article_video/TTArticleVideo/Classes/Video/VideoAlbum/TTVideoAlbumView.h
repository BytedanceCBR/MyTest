//
//  TTVideoAlbumView.h
//  Article
//
//  Created by 刘廷勇 on 16/1/6.
//
//

#import "SSThemed.h"
#import "Article.h"
#import <TTVideoService/VideoInformation.pbobjc.h>

@interface TTVideoAlbumView : SSThemedView
@property (nonatomic, strong) TTVRelatedItem *item;
@property (nonatomic, strong) Article *article;
@property (nonatomic, strong) Article *currentPlayingArticle;

- (void)reload;
- (void)dismissSelf;

@end

@interface TTVideoAlbumHolder : NSObject

@property (nonatomic, strong) TTVideoAlbumView *albumView;

+ (instancetype)holder;
+ (void)dispose;

@end
