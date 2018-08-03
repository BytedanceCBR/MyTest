

#import <Foundation/Foundation.h>

@protocol TTViewProtocol <NSObject>
- (void)update:(id)data;
- (BOOL)needUpdate;
- (void)doLayoutSubviews;
@end
