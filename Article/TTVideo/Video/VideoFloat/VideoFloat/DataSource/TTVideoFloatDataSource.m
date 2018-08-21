
#import "TTVideoFloatDataSource.h"
#import "TTVideoFloatCellEntity.h"
#import "TTVideoFloatCell.h"

@interface TTVideoFloatDataSource()
{
    TTVideoFloatCellEntity *_preEntity;
}
@end


@implementation TTVideoFloatDataSource

- (TTBaseCellEntity *)cellEntity:(id)aItem indexPath:(NSIndexPath *)indexPath
{
    if ([aItem isKindOfClass:[TTVideoFloatCellEntity class]])
    {
        TTVideoFloatCellEntity *entity = (TTVideoFloatCellEntity *)aItem;
        entity.cellClass = [TTVideoFloatCell class];
        entity.heightOfCell = [TTVideoFloatCell cellHeightWithEntity:entity indexPath:indexPath];
        if (indexPath.row == 0) {
            entity.startY = 0;
            entity.endY = entity.heightOfCell;
        }
        else
        {
            entity.startY = _preEntity.endY + 0.001;
            entity.endY = entity.startY + entity.heightOfCell;
        }
        _preEntity = entity;
        return entity;
    }
    return nil;
}

@end
