//
//  TTActionSheetTableCell.h
//  Article
//
//  Created by zhaoqin on 8/28/16.
//
//

#import <UIKit/UIKit.h>

@class AWEActionSheetCellModel;

@interface AWEActionSheetTableCell : UITableViewCell
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UILabel *revokeLabel;
@property (nonatomic, strong) UIView *seperatorView;

- (void)configCellWithModel:(AWEActionSheetCellModel *)model;

@end
