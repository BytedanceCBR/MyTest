//
//  TTVCommentListItem.m
//  Article
//
//  Created by lijun.thinker on 2017/5/17.
//
//

#import "TTVCommentListItem.h"

@implementation TTVCommentListItem

- (TTVCommentListLayout *)layout {
    
    if (!_layout) {
        
        _layout = [TTVCommentListLayout new];
    }
    
    return _layout;
}

@end
