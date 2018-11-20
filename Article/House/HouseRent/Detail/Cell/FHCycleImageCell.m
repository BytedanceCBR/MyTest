//
//  FHCycleImageCell.m
//  Article
//
//  Created by leo on 2018/11/19.
//

#import "FHCycleImageCell.h"
#import "Bubble-Swift.h"

@implementation FHCycleImageCell

- (void)renderCell:(nonnull UITableViewCell *)cell
         withModel:(nonnull id)model
       atIndexPath:(nonnull NSIndexPath *)indexPath {
    if ([cell isKindOfClass:[CycleImageCell class]]) {
        CycleImageCell* theCell = (CycleImageCell*)cell;
        [theCell setImageObjsWithImages:nil];
    }
}

@end
