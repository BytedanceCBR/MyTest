//
//  TTVReplyListItem.h
//  Article
//
//  Created by lijun.thinker on 2017/6/1.
//
//

#import "TTVTableViewItem.h"
#import "TTVReplyListCellLayout.h"
#import "TTVReplyModelProtocol.h"

@interface TTVReplyListItem : TTVTableViewItem

@property (nonatomic, strong) TTVReplyListCellLayout *layout;

@property (nonatomic, strong) id <TTVReplyModelProtocol> model;

@end
