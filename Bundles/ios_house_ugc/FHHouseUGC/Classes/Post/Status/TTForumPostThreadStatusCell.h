//
//  TTForumPostThreadStatusCell.h
//  Article
//
//  Created by 徐霜晴 on 16/10/8.
//
//

#import <UIKit/UIKit.h>
#import "TTPostThreadTask.h"
#import "TTForumPostThreadStatusViewModel.h"
#import "SSThemed.h"

@interface TTForumPostThreadStatusCell : SSThemedTableViewCell

@property (nonatomic, strong) TTPostThreadTaskStatusModel *statusModel;

- (void)updateUploadingProgress:(CGFloat)progress;

+ (CGFloat)heightForStatusModel:(TTPostThreadTaskStatusModel *)statusModel;

+ (CGFloat)heightForStatus:(TTPostTaskStatus)status;

@end
