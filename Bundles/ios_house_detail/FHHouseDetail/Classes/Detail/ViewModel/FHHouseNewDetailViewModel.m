//
//  FHHouseNewDetailViewModel.m
//  FHHouseDetail
//
//  Created by 张元科 on 2019/1/30.
//

#import "FHHouseNewDetailViewModel.h"
#import "FHHouseDetailAPI.h"

@implementation FHHouseNewDetailViewModel

- (void)startLoadData
{
    [FHHouseDetailAPI requestNewDetail:@"6581052152733499652" completion:^(FHDetailNewModel * _Nullable model, NSError * _Nullable error) {
        
        NSLog(@"zjing-%@",model);
    }];
    
}

@end
