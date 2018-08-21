
#import "TTDeleteDataSource.h"

@implementation TTDeleteDataSource
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.editingStyle = UITableViewCellEditingStyleDelete;
    }
    return self;
}
#pragma mark - ********** 控件代理模块 **********
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.editingStyle;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        if ([self.delegate respondsToSelector:@selector(tableView:deleteRowAtIndexPath:)]) {
            [self.delegate tableView:tableView deleteRowAtIndexPath:indexPath];
        }
    }
}
@end
