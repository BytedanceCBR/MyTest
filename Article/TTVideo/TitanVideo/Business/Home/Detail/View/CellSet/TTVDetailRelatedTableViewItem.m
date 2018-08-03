//
//  TTVDetailRelatedTableViewItem.m
//  Article
//
//  Created by pei yun on 2017/6/16.
//
//

#import "TTVDetailRelatedTableViewItem.h"

@implementation TTVDetailRelatedTableViewItem

@end

@implementation TTVDetailRelatedTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundSelectedColorThemeKey = kColorBackground4Highlighted;
    }
    return self;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}



@end
