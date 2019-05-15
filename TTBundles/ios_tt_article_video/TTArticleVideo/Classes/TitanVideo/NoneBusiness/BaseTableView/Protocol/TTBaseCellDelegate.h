
#import <Foundation/Foundation.h>
@class TTBaseCellEntity;
@protocol TTBaseCellDelegate <NSObject>
@optional
- (void)chain_cellLongPressedWithCellEntity:(TTBaseCellEntity *)cellEntity indexPath:(NSIndexPath *)indexPath;
- (void)chain_cellLongPressedEndedWithCellEntity:(TTBaseCellEntity *)cellEntity indexPath:(NSIndexPath *)indexPath;
@end
