//
//  TTCommentFoldCell.h
//  Article
//
//  Created by muhuai on 27/02/2017.
//
//

#import <UIKit/UIKit.h>
#import <TTThemed/SSThemed.h>


extern NSString *const kTTCommentFooterCellReuseIdentifier;

typedef NS_ENUM(NSUInteger, TTCommentFooterCellType) {
    TTCommentFooterCellTypeNone,        // 空
    TTCommentFooterCellTypeFold,        // 查看折叠区
    TTCommentFooterCellTypeFoldLeft,    // 查看折叠区 居左
    TTCommentFooterCellTypeNoMore       // 已显示全部评论
};

@class TTCommentFooterCell;

@protocol TTCommentFooterCellDelegate <NSObject>

@optional
- (void)commentFooterCell:(TTCommentFooterCell *)cell onClickForType:(TTCommentFooterCellType)type;

@end

@interface TTCommentFooterCell : SSThemedTableViewCell

@property (nonatomic, assign) TTCommentFooterCellType type;
@property (nonatomic, weak) id<TTCommentFooterCellDelegate> delegate;

+ (CGFloat)cellHeight;

@end
