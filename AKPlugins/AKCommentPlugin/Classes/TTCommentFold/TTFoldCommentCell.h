//
//  TTFoldCommentCell.h
//  Article
//
//  Created by muhuai on 21/02/2017.
//
//

#import <UIKit/UIKit.h>
#import <TTThemed/SSThemed.h>
#import "TTCommentModelProtocol.h"
#import "TTFoldCommentCellLayout.h"

extern NSString *const kTTFoldCommentCellIdentifier;

@class TTFoldCommentCell;
@protocol TTFoldCommentCellDelegate <NSObject>

@optional
- (void)commentCell:(TTFoldCommentCell *)cell avatarViewOnClickWithModel:(id<TTCommentModelProtocol>)model;
- (void)commentCell:(TTFoldCommentCell *)cell nameViewOnClickWithModel:(id<TTCommentModelProtocol>)model;
@end

@interface TTFoldCommentCell : SSThemedTableViewCell

@property (nonatomic, weak) id<TTFoldCommentCellDelegate> delegate;

- (void)refreshWithModel:(id<TTCommentModelProtocol>)model layout:(TTFoldCommentCellLayout *)layout;

@end
