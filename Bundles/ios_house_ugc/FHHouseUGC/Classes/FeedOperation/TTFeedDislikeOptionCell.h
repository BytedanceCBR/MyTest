//
//  TTFeedDislikeOptionCell.h
//  AFgzipRequestSerializer
//
//  Created by 曾凯 on 2018/7/13.
//

#import <UIKit/UIKit.h>
#import "FHFeedOperationOption.h"
#import "SSThemed.h"

NS_ASSUME_NONNULL_BEGIN

@interface TTFeedDislikeOptionCell : UITableViewCell
@property (nonatomic, strong) SSThemedView *separator;
- (void)configWithOption:(FHFeedOperationOption *)option showSeparator:(BOOL)showSeparator;
@end

NS_ASSUME_NONNULL_END
