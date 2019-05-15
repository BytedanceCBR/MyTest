//
//  ArticlePostMomentViewController.h
//  Article
//
//  Created by Huaqing Luo on 13/1/15.
//
//

#import "SSViewControllerBase.h"
#import "SSViewBase.h"
#import "ExploreMomentDefine.h"

#define DefaultImagesSelectionLimit 9

extern unsigned int g_postForumMinCharactersLimit;
extern unsigned int g_postMomentMaxCharactersLimit;

@interface ArticlePostMomentViewController : SSViewControllerBase

@property (nonatomic, assign) long long forumID; // default 0

- (instancetype)initWithSourceType:(PostMomentSourceType)sourceType;

@end

@interface AddMultiImagesView : SSViewBase

@property (nonatomic, assign) NSInteger selectionLimit;
@property (nonatomic, readonly) NSMutableArray * selectedAssetsImages;

@end
