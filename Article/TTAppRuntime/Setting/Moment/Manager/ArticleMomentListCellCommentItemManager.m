//
//  ArticleMomentListCellCommentItemManager.m
//  Article
//
//  Created by Zhang Leonardo on 14-5-23.
//
//

#import "ArticleMomentListCellCommentItemManager.h"

@interface ArticleMomentListCellCommentItemManager ()

@property(nonatomic, retain)NSMutableSet * commentItems;
@property(nonatomic, retain)NSMutableSet * reuseCommentItems;
@end

@implementation ArticleMomentListCellCommentItemManager

- (void)dealloc
{
    [_reuseCommentItems removeAllObjects];
    self.reuseCommentItems = nil;
    
    [_commentItems removeAllObjects];
    self.commentItems = nil;
}

static ArticleMomentListCellCommentItemManager * shareManager;

+ (ArticleMomentListCellCommentItemManager *)shareManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareManager = [[ArticleMomentListCellCommentItemManager alloc] init];
    });
    return shareManager;
}

- (ArticleMomentListCellCommentItem *)dequeueReusableCommentItem
{
    ArticleMomentListCellCommentItem * item = [_reuseCommentItems anyObject];
    if (item != nil) {
        [_reuseCommentItems removeObject:item];
    }
    return item;
}

- (void)queueReusableCommentItem:(ArticleMomentListCellCommentItem *)item
{
    if (item == nil || ![item isKindOfClass:[ArticleMomentListCellCommentItem class]]) {
        return;
    }
    [_commentItems addObject:item];
    if (!_reuseCommentItems) {
        _reuseCommentItems = [[NSMutableSet alloc] initWithCapacity:5];
    }
    [_reuseCommentItems addObject:item];
}

@end
