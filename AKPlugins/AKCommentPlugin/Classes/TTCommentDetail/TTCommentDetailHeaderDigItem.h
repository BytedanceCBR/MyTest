//
//  TTCommentDetailHeaderDigItem.h
//  Article
//
//  Created by muhuai on 12/01/2017.
//
//

#import <TTThemed/SSThemed.h>
#import "TTCommentDetailModel.h"

@class TTCommentDetailHeaderDigItem;

@protocol TTCommentDetailHeaderDigItemDelegate <NSObject>

@optional
- (void)commentDetailHeaderDigItem:(TTCommentDetailHeaderDigItem *)digItem diggUserAvatarClicked:(SSUserModel *)userModel;
- (void)commentDetailHeaderDigItem:(TTCommentDetailHeaderDigItem *)digItem diggUsersAccessoryClicked:(id)sender;
@end

@interface TTCommentDetailHeaderDigItem : SSThemedView

@property (nonatomic, weak) id<TTCommentDetailHeaderDigItemDelegate> delegate;

- (id)initWithModel:(TTCommentDetailModel *)model Width:(CGFloat)width;

- (void)reloadDataWithModel:(TTCommentDetailModel *)model;

@end
