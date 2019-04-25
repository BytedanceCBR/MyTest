//
//  TTVCommentListItem.h
//  Article
//
//  Created by lijun.thinker on 2017/5/17.
//
//

#import "TTVTableViewItem.h"
#import "TTVCommentListLayout.h"
#import "TTVideoCommentItem+Extension.h"
#import "TTVCommentModelProtocol.h"

@interface TTVCommentListItem : TTVTableViewItem

@property (nonatomic, strong) id <TTVCommentModelProtocol, TTCommentDetailModelProtocol> commentModel;

@property(nonatomic, assign) BOOL impressionShown;

@property (nonatomic, strong) TTVCommentListLayout *layout;

@end
