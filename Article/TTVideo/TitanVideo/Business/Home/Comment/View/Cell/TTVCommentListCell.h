//
//  TTVCommentListCell.h
//  Article
//
//  Created by lijun.thinker on 2017/5/17.
//
//

#import "TTVCommentDefine.h"
#import "TTVTableViewItem.h"
#import "TTVCommentListItem.h"

#define kDetailActionGroupModelKey @"kDetailActionGroupModelKey"
#define kDetailActionItemCommentID @"kDetailActionItemCommentID"

@interface TTVCommentListCell : TTVTableViewCell

@property (nonatomic, weak) id <TTVCommentCellDelegate> delegate;

@property (nonatomic, strong) TTVCommentListItem *item;

@property(nonatomic, assign) BOOL impressionShown;

@end
