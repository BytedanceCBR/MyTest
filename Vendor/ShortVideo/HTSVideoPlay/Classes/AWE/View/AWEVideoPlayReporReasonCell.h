//
//  AWEVideoReportReasonCellViewController.h
//  Pods
//
//  Created by 01 on 17/5/7.
//
//
#import <UIKit/UIKit.h>
#import <SSThemed.h>

@interface AWEVideoPlayReporReasonCell : SSThemedTableViewCell

+ (NSInteger)cellHeight;

- (void)hideCellSepline:(BOOL)hidden;

- (void)setTitleText:(NSString *)text;

- (void)setSelectedStatus:(BOOL)selected;

@end
