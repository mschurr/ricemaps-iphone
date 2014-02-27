//
//  RUMapViewController.m
//  Rice University Map
//
//  Created by Matthew Schurr on 1/28/14.
//  Copyright (c) 2014 Schurr Solutions. All rights reserved.
//

#import "RUMapViewController.h"
#import "RUMapDataManager.h"
#import "RUMapDataBuses.h"
#import "UIImage+Resize.h"
#import <GoogleMaps/GoogleMaps.h>

/*
 -Show bus route info when tapping on bus, show motion projection based on previous updates?, overlay entire route on map
 -Get directions to buildings
 -Show distance to buildings
 -Search by person
 -Search by course
 */

@interface RUMapViewController () <UITableViewDataSource, UITableViewDelegate, UISearchDisplayDelegate, UISearchBarDelegate, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet GMSMapView *mapView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) RUMapDataManager *dataManager;
@property (strong, nonatomic) RUMapDataBuses *busData;
@property (strong, nonatomic) NSArray *busMarkers;
@property (strong, nonatomic) NSArray *searchResults;
@end

@implementation RUMapViewController

/* --UITableViewDataSource */

- (NSArray *) searchResults
{
    if(!_searchResults)
        _searchResults = [[NSArray alloc] init];
    return _searchResults;
}

- (NSInteger) tableView: (UITableView *) tableView numberOfRowsInSection: (NSInteger) section
{
    return [self.searchResults count];
}

#define CELL_IDENTIFIER @"searchCell"
- (UITableViewCell *) tableView: (UITableView *) tableView cellForRowAtIndexPath: (NSIndexPath *) indexPath
{
    UITableViewCell *cell;
    
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CELL_IDENTIFIER];
        cell.textLabel.text = @"";
        cell.detailTextLabel.text = @"";
    }
    
    if(indexPath.row >= [self.searchResults count])
        return cell;
    RUMapDataResult *item = (RUMapDataResult *) [self.searchResults objectAtIndex: indexPath.row];
    cell.textLabel.text = item.title;
    cell.detailTextLabel.text = item.description;
    return cell;
}

/* --UITableViewDelegate */

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.searchDisplayController setActive: NO animated: YES];
    RUMapDataResult *result = [self.searchResults objectAtIndex: indexPath.row];
    [self.mapView clear];
    
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = CLLocationCoordinate2DMake(result.latitude, result.longitude);
    if([result.description length]) {
        marker.snippet = result.description;
    }
    marker.title = result.title;
    marker.map = self.mapView;
    
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude: result.latitude longitude: result.longitude zoom: 17 bearing:0 viewingAngle: 30];
    [self.mapView animateToCameraPosition: camera];
}

/* --UISearchDisplayDelegate */

- (void) searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller
{
    NSLog(@"searchStart");
}

- (void) searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    NSLog(@"searchEnd");
}

- (BOOL) searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self updateSearchResults: searchString];
    return YES;
}

- (void) updateSearchResults: (NSString *) queryString
{
    dispatch_queue_t queue = dispatch_queue_create("updateTable", NULL);
    dispatch_async(queue, ^{
        self.searchResults = [self.dataManager searchResultsForQuery: queryString];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.searchDisplayController.searchResultsTableView reloadData];
        });
    });
}

/* --UISearchBarDelegate */


/* --implementation */

- (RUMapDataManager *) dataManager
{
    if(!_dataManager)
        _dataManager = [[RUMapDataManager alloc] init];
    return _dataManager;
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if(object == self.busData) {
        dispatch_async(dispatch_get_main_queue(), ^{
            // Clear existing bus markers.
            for(GMSMarker *marker in self.busMarkers) {
                marker.map = nil;
            }
            
            // Allocate a new array.
            NSMutableArray *busMarkers = [[NSMutableArray alloc] init];
            UIImage *busImage = [UIImage imageNamed: @"bus-icon.png"];
            
            // Insert new markers.
            for(NSDictionary *busData in self.busData.busLocations) {
                GMSMarker *marker = [[GMSMarker alloc] init];
                marker.title = [NSString stringWithFormat:@"Bus: %@", busData[RUMapDataBuses_LABEL]];
                marker.position = CLLocationCoordinate2DMake([busData[RUMapDataBuses_LATITUDE] doubleValue],
                                                             [busData[RUMapDataBuses_LONGITUDE] doubleValue]);
                //marker.icon = [GMSMarker markerImageWithColor: [UIColor blueColor]];
                marker.icon = busImage;
                marker.groundAnchor = CGPointMake(0.5, 0.5);
                marker.map = self.mapView;
                [busMarkers addObject: marker];
            }
            
            // Remember the markers.
            self.busMarkers = busMarkers;
        });
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set up buses.
    self.busData = [[RUMapDataBuses alloc] init];
    [self.busData addObserver: self forKeyPath: @"busLocations" options: NSKeyValueObservingOptionNew context: nil];
    [self.busData startMonitoring];
    
    /*GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude: self.dataManager.initialLatitude
                                                            longitude: self.dataManager.initialLongitude
                                                                 zoom: 17];*/

    GMSCameraPosition *camera = [GMSCameraPosition cameraWithTarget: CLLocationCoordinate2DMake(self.dataManager.initialLatitude,
                                                                                                self.dataManager.initialLongitude)
                                   zoom: 17
                                bearing: 0
                           viewingAngle: 30];
    
    //self.mapView = [GMSMapView mapWithFrame: CGRectZero camera: camera];
    self.mapView.camera = camera;
    self.mapView.myLocationEnabled = YES;
    self.mapView.buildingsEnabled = YES;
    [self.mapView setMinZoom: 15.0 maxZoom: 18.0];
    
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = CLLocationCoordinate2DMake(self.dataManager.initialLatitude, self.dataManager.initialLongitude);
    marker.title = @"Rice University";
    marker.snippet = @"Houston, TX";
    marker.map = self.mapView;
    
    // Set up search bar.
    //self.searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar: self.searchBar contentsController: self];
    self.searchBar.placeholder = @"Search People, Places, and Courses...";
    self.searchDisplayController.delegate = self;
    self.searchDisplayController.searchResultsDataSource = self;
    self.searchDisplayController.searchResultsDelegate = self;
}

- (void) dealloc
{
    [self.busData stopMonitoring];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    /*if([self.dataManager needsUpdate]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Database Synchronization" message: @"Would you like to download updated information from the Rice Database now?" delegate: self cancelButtonTitle: @"No" otherButtonTitles: @"Yes", nil];
        [alert show];
    }*/
    [self.dataManager performUpdateNotifyTarget: self Action: @selector(updateDidComplete)];
}

- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if([alertView.title isEqualToString: @"Database Synchronization"] && buttonIndex == 1) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Notice" message: @"The application is downloading updated information in the background. You will be notified when the process is completed." delegate: self cancelButtonTitle: @"Continue..." otherButtonTitles: nil];
        [alert show];
        [self.dataManager performUpdateNotifyTarget: self Action: @selector(updateDidComplete)];
    }
    
    NSLog(@"alert dismiss %d", buttonIndex);
}

- (void) updateDidComplete
{
    /*UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Notice" message: @"The database update has completed. You will now search using the updated information." delegate: self cancelButtonTitle:@"Continue..." otherButtonTitles: nil];
    [alert show];*/
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
