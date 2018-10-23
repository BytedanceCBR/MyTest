//
//  TTActionSheetCellModel.h
//  Article
//
//  Created by zhaoqin on 8/30/16.
//
//

#import <Foundation/Foundation.h>

@interface AWEActionSheetCellModel : NSObject
@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, assign) BOOL isSelected;
@end
