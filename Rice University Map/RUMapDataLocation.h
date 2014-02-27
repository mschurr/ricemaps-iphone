//
//  RUMapDataBuilding.h
//  Rice University Map
//
//  Created by Matthew Schurr on 1/28/14.
//  Copyright (c) 2014 Schurr Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RUMapDataLocation : NSObject

@property (strong, nonatomic) NSArray/*<NSString>*/ *searchTags;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *description;
@property (nonatomic) double longitude;
@property (nonatomic) double latitude;

@end
