//
//  TTCommentDetailHeaderGroupItem.h
//  Article
//
//  Created by muhuai on 2017/4/18.
//
//

#import <Foundation/Foundation.h>
#import <TTThemed/SSThemed.h>
#import "TTCommentDetailModel.h"

@interface TTCommentDetailHeaderGroupItem : SSThemedView

@property (nonatomic , strong) NSDictionary *tracerDict;
- (void)refreshWithDetailModel:(TTCommentDetailModel *)detailModel;

@end
