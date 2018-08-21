//
//  FRForumLocationSingleLineCell.h
//  Article
//
//  Created by 王霖 on 15/7/14.
//
//

#import "SSThemed.h"

typedef NS_ENUM(NSInteger, FRForumLocationSingleLineCellStyle) {
    FRForumLocationSingleLineCellStyleDefault = 0,
    FRForumLocationSingleLineCellStyleValue1
};

@interface FRForumLocationSingleLineCell : SSThemedTableViewCell

@property (nonatomic, copy)NSString *title;
@property (nonatomic, assign)FRForumLocationSingleLineCellStyle cellStyle;

@end
