//
//  RUMapDataManager.m
//  Rice University Map
//
//  Created by Matthew Schurr on 1/28/14.
//  Copyright (c) 2014 Schurr Solutions. All rights reserved.
//

#import "RUMapDataManager.h"

@interface RUMapDataManager()
@property (strong, nonatomic) NSArray *locationIndex;
@property (strong, nonatomic) NSArray *courseIndex;
@property (strong, nonatomic) NSArray *peopleIndex;
@property (nonatomic) double initialLongitude;
@property (nonatomic) double initialLatitude;
@end

@implementation RUMapDataManager

- (id) init
{
    self = [super init];
    
    if(self) {
        self.initialLatitude = 29.71739;
        self.initialLongitude = -95.40183;
        self.locationIndex = @[
            
        ];
    }
    
    return self;
}

/* Returns an array of RUMapDataResults matching the provided search query. */
- (NSArray *) searchResultsForQuery: (NSString *) searchQuery
{
    NSMutableArray *results = [[NSMutableArray alloc] init];
    
    // Locations & Points of Interest
    for(RUMapDataLocation *location in self.locationIndex) {
        if([self array: location.searchTags matchesQueryString: searchQuery]) {
            RUMapDataResult *result = [[RUMapDataResult alloc] init];
            result.title = location.name;
            result.description = location.description;
            result.longitude = location.longitude;
            result.latitude = location.latitude;
            result.type = RUMapDataResultTypeLocation;
            [results addObject: result];
        }
    }
    
    // People
    for(RUMapDataPerson *person in self.peopleIndex) {
        if([self array: person.searchTags matchesQueryString: searchQuery]) {
            RUMapDataResult *result = [[RUMapDataResult alloc] init];
            result.title = person.name;
            result.description = person.description;
            result.longitude = person.longitude;
            result.latitude = person.latitude;
            result.type = RUMapDataResultTypePerson;
            [results addObject: result];
        }
    }
    
    // Courses
    for(RUMapDataCourse *course in self.courseIndex) {
        if([self array: course.searchTags matchesQueryString: searchQuery]) {
            RUMapDataResult *result = [[RUMapDataResult alloc] init];
            result.type = RUMapDataResultTypeCourse;
            result.title = course.name;
            result.description = course.description;
            result.longitude = course.longitude;
            result.latitude = course.latitude;
            [results addObject: result];
        }
    }
    
    return results;
}

/* Returns an RUMapDataResult for a provided course. */
- (NSArray/*RUMapDataResult*/ *) mapDataResultsForCourse: (RUMapDataCourse *) course
{
    NSMutableArray *results = [[NSMutableArray alloc] init];
    
    // Locations
    for(RUMapDataLocation *location in self.locationIndex) {
        BOOL match = NO;
        
        for(NSString *tag in location.searchTags) {
            for(NSString *courseTag in course.locationTags) {
                if([tag isEqualToString: courseTag]) {
                    match = YES;
                }
            }
        }
        
        if(match) {
            RUMapDataResult *result = [[RUMapDataResult alloc] init];
            result.title = location.name;
            result.description = course.name;
            result.longitude = location.longitude;
            result.latitude = location.latitude;
            [results addObject: result];
        }
    }
    
    
    return results;
}

- (BOOL) needsUpdate
{
    return YES;
}

- (void) performUpdateNotifyTarget: (id) target Action: (SEL) selector
{
    dispatch_queue_t queue = dispatch_queue_create("RUMapDataManager", NULL);
    dispatch_async(queue, ^{
        
        NSString *path = [[NSBundle mainBundle] pathForResource: @"campus_data" ofType: @"json"];
        NSData *json = [NSData dataWithContentsOfFile: path];
        NSArray *data = [NSJSONSerialization JSONObjectWithData: json options: 0 error: NULL];
        
        NSMutableArray *locationIndex = [[NSMutableArray alloc] init];
        
        for(NSDictionary *locationData in data) {
            RUMapDataLocation *location = [[RUMapDataLocation alloc] init];
            NSDictionary *locationCoordinates = (NSDictionary *) locationData[@"location"];
            location.name = locationData[@"name"];
            
            if([locationData objectForKey: @"abbreviation"] != nil && [locationData[@"abbreviation"] length] > 0) {
                NSString *buildingCode = [NSString stringWithFormat: @" (%@)", locationData[@"abbreviation"]];
                location.name = [location.name stringByAppendingString: buildingCode];
            }
            location.description = @"";
            location.longitude = [locationCoordinates[@"longitude"] doubleValue];
            location.latitude = [locationCoordinates[@"latitude"] doubleValue];
            
            NSMutableArray *searchTags = [[NSMutableArray alloc] init];
            //[searchTags addObject: locationData[@"abbreviation"]];
            
            /*for(NSString *tag in [location.name componentsSeparatedByString: @" "]) {
                [searchTags addObject: tag];
            }*/
            [searchTags addObject: location.name];
            
            location.searchTags = searchTags;
            
            [locationIndex addObject: location];
        }

        self.locationIndex = locationIndex;
        
        // Build People Index
        path = [[NSBundle mainBundle] pathForResource: @"faculty" ofType: @"json"];
        json = [NSData dataWithContentsOfFile: path];
        NSError *error;
        data = [NSJSONSerialization JSONObjectWithData: json options: 0 error: &error];
        
        NSMutableArray *peopleIndex = [[NSMutableArray alloc] init];
        
        //NSLog(@"raw=%@", [[NSString alloc] initWithData: json encoding: NSASCIIStringEncoding]);
        //NSLog(@"data=%@ err=%@",data,error);
        for(NSDictionary *peopleData in data) {
            RUMapDataPerson *person = [[RUMapDataPerson alloc] init];
            person.name = peopleData[@"name"];
            person.description = [NSString stringWithFormat: @"Office: %@", peopleData[@"office"]];
            person.searchTags = [NSArray arrayWithObject: person.name];
            [peopleIndex addObject: person];
        }
        
        self.peopleIndex = peopleIndex;
        
        // Finish
        
        dispatch_async(dispatch_get_main_queue(), ^{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [target performSelector: selector];
#pragma clang diagnostic pop
        });
    });
}

- (BOOL) array: (NSArray *) tags matchesQueryString: (NSString *) queryString
{
    BOOL matched = NO;
    NSArray *terms = [queryString componentsSeparatedByString: @" "];
    
    for(NSString * tag in tags) {
        for(NSString *term in terms) {
            NSRange range = [tag rangeOfString: term options: NSCaseInsensitiveSearch];
            if(range.location != NSNotFound) {
                matched = YES;
                break;
            }
        }
        
        if(matched)
            break;
    }
    
    return matched;
}

- (void) downloadCourseData
{
    dispatch_queue_t queue = dispatch_queue_create("RUMapDataManager", NULL);
    dispatch_async(queue, ^{
        // Download the map data.
        
        // Process the map data.
        [self didFinishDownloadingCourseData: nil];
        
        // Update the index and user interface.
        dispatch_async(dispatch_get_main_queue(), ^{
            [self didFinishProcessingCourseData];
        });
    });
}

- (void) didFinishDownloadingCourseData: (NSData *) data
{
    
}

- (void) didFinishProcessingCourseData
{
    
}

@end
