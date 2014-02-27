//
//  RUMapDataResult.h
//  Rice University Map
//
//  Created by Matthew Schurr on 1/28/14.
//  Copyright (c) 2014 Schurr Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum RUMapDataResultTypeEnum {
    RUMapDataResultTypeLocation=0,
    RUMapDataResultTypeCourse=1,
    RUMapDataResultTypePerson=2
} RUMapDataResultType;

@interface RUMapDataResult : NSObject
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *description;
@property (nonatomic) double longitude;
@property (nonatomic) double latitude;
@property (nonatomic) RUMapDataResultType type;
@end
