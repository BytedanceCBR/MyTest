//
//  TTCommentRepostDetailModel.h
//  Article
//
//  Created by ranny_90 on 2017/9/19.
//
//

#import <JSONModel/JSONModel.h>
#import "FRCommentRepost.h"

@interface FRCommentRepostDetailModel : JSONModel

@property (nonatomic, strong) NSNumber *err_no;

@property (nonatomic, assign) BOOL show_repost_entrance;

@property (nonatomic, assign) BOOL ban_face;

@property (nonatomic, strong) NSDictionary *comment;

@property (nonatomic, strong) FRCommentRepost *commentRepostModel;

- (void)updateCommentRepostModel;

@end
