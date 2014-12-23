//
//  ViewController.m
//  navigationApp2
//
//  Created by juston1 on 2014/9/21.
//  Copyright (c) 2014年 juston1. All rights reserved.
//

#import "ViewController.h"
#import "mapViewController.h"
#import "ESTBeaconManager.h"


@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *getSignalName;
@end


//add in 2014/12/14
//start
@interface ViewController () <ESTBeaconManagerDelegate>
@property (nonatomic, strong) ESTBeacon         *beacon;
@property (nonatomic, strong) ESTBeaconManager  *beaconManager;
@property (nonatomic, strong) ESTBeaconRegion   *beaconRegion;
@property (nonatomic, strong) NSArray *beaconsArray;
@property (nonatomic, assign) ESTScanType scanType;
@property (nonatomic, copy)     void (^completion)(ESTBeacon *);

@property (nonatomic, strong) UIImageView       *backgroundImage;
@property (nonatomic, strong) UIImageView       *positionDot;

@end
//end

@implementation ViewController

//add in 2014/12/14
//start
- (id)initWithBeacon:(ESTBeacon *)beacon
{
    self = [super init];
    if (self)
    {
        self.beacon = beacon;
    }
    
    NSLog(@"initWithBeacon\n");
    
    return self;
}

- (id)initWithScanType:(ESTScanType)scanType completion:(void (^)(ESTBeacon *))completion
{
    NSLog(@"initWithScanType");
    self = [super init];
    if (self)
    {
        self.scanType = scanType;
        self.completion = [completion copy];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"viewDidLoad");
    self.title = @"Distance Demo";
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
    self.beaconManager = [[ESTBeaconManager alloc] init];
    self.beaconManager.delegate = self;
    
    /*
     * Creates sample region object (you can additionaly pass major / minor values).
     *
     * We specify it using only the ESTIMOTE_PROXIMITY_UUID because we want to discover all
     * hardware beacons with Estimote's proximty UUID.
     */
    self.beaconRegion = [[ESTBeaconRegion alloc] initWithProximityUUID:ESTIMOTE_PROXIMITY_UUID
                                                            identifier:@"EstimoteSampleRegion"];
    
    /*
     * Starts looking for Estimote beacons.
     * All callbacks will be delivered to beaconManager delegate.
     */
    self.scanType = 1;
    self.completion = [_completion copy];
    if (self.scanType == ESTScanTypeBeacon)
    {
        NSLog(@"startRangingBeacons\nself.scanType:%d\n",self.scanType);
        [self startRangingBeacons];
    }
    else
    {
        NSLog(@"startEstimoteBeaconsDiscoveryForRegion\nself.scanType:%d\n",self.scanType);
        [self.beaconManager startEstimoteBeaconsDiscoveryForRegion:self.beaconRegion];
    }
    
    
    /*
     * BeaconManager setup.
     */
    
    self.beaconManager = [[ESTBeaconManager alloc] init];
    self.beaconManager.delegate = self;
    
    self.beaconRegion = [[ESTBeaconRegion alloc] initWithProximityUUID:ESTIMOTE_PROXIMITY_UUID
                                                            identifier:@"RegionIdentifier"];
    [self startRangingBeacons];
    
    [self.beaconManager startRangingBeaconsInRegion:self.beaconRegion];
    
}

- (void)beaconManager:(ESTBeaconManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (self.scanType == ESTScanTypeBeacon)
    {
        NSLog(@"didChangeAuthorizationStatus");
        [self startRangingBeacons];
    }
}

-(void)startRangingBeacons
{
    if ([ESTBeaconManager authorizationStatus] == kCLAuthorizationStatusNotDetermined)
    {
        if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1) {
            NSLog(@"startRagingBeacons if iOS 7");
            /*
             * No need to explicitly request permission in iOS < 8, will happen automatically when starting ranging.
             */
            [self.beaconManager startRangingBeaconsInRegion:self.beaconRegion];
        } else {
            NSLog(@"startRagingBeacons if iOS 8");
            /*
             * Request permission to use Location Services. (new in iOS 8)
             * We ask for "always" authorization so that the Notification Demo can benefit as well.
             * Also requires NSLocationAlwaysUsageDescription in Info.plist file.
             *
             * For more details about the new Location Services authorization model refer to:
             * https://community.estimote.com/hc/en-us/articles/203393036-Estimote-SDK-and-iOS-8-Location-Services
             */
            [self.beaconManager requestAlwaysAuthorization];
        }
        NSLog(@"startRagingBeacons if \nself.region: %@",self.beaconRegion);
        [self.beaconManager startRangingBeaconsInRegion:self.beaconRegion];
    }
    else if([ESTBeaconManager authorizationStatus] == kCLAuthorizationStatusAuthorized)
    {
        NSLog(@"startRagingBeacons else if 1");
        [self.beaconManager startRangingBeaconsInRegion:self.beaconRegion];
    }
    else if([ESTBeaconManager authorizationStatus] == kCLAuthorizationStatusDenied)
    {
        NSLog(@"startRagingBeacons else if 2");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location Access Denied"
                                                        message:@"You have denied access to location services. Change this in app settings."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        
        [alert show];
    }
    else if([ESTBeaconManager authorizationStatus] == kCLAuthorizationStatusRestricted)
    {
        NSLog(@"startRagingBeacons else if 3");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location Not Available"
                                                        message:@"You have no access to location services."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        
        [alert show];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self.beaconManager stopRangingBeaconsInRegion:self.beaconRegion];
    [self.beaconManager stopEstimoteBeaconDiscovery];
    
    [super viewDidDisappear:animated];
}

- (void)dismiss
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - ESTBeaconManager delegate

- (void)beaconManager:(ESTBeaconManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(ESTBeaconRegion *)region
{
    self.beaconsArray = beacons;
    
    NSLog(@"didRangeBeacons");
    
    int i = 0;
    ESTBeacon *beacon;
    if (self.beaconsArray.count >= 1) {
        for (i = 0; i < self.beaconsArray.count; i++) {
            beacon = [self.beaconsArray objectAtIndex:i];
            NSLog(@"beacon %d distance: %.2f\n", [beacon.minor integerValue], [beacon.distance floatValue]);
        }
    }
    
}

- (void)beaconManager:(ESTBeaconManager *)manager didDiscoverBeacons:(NSArray *)beacons inRegion:(ESTBeaconRegion *)region
{
    self.beaconsArray = beacons;
    
    NSLog(@"didDiscoverBeacons");
}
//end

- (IBAction)findOurPlace:(UIButton *)sender
{
    ESTBeacon *nearistBeacon = [self.beaconsArray objectAtIndex:0];
    NSLog(@"%@",[nearistBeacon.minor stringValue]);
    NSString *urlstring = [NSString stringWithFormat:@"http://salty-spire-9482.herokuapp.com/positions/find.json?name=%@",[nearistBeacon.minor stringValue]];
    NSURL *url = [NSURL URLWithString:urlstring];
    NSData *data = [NSData dataWithContentsOfURL:url];
    NSLog(@"!!!!!!!!!%@\n",data);
    NSError *error = nil;
    NSMutableArray *json = (NSMutableArray*)[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    NSLog(@"!!!!!!!!!%@\n",[[json objectAtIndex:0] objectForKey:@"name"]);
    
    _holdPositionX = [[json objectAtIndex:0] objectForKey:@"xpos"];
    _holdPositionY = [[json objectAtIndex:0] objectForKey:@"ypos"];
    _firstPositionID = [[json objectAtIndex:0] objectForKey:@"name"];

  
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([segue.identifier isEqualToString:@"changeMapVC"])
    {
        if([segue.destinationViewController isKindOfClass:[mapViewController class]])
        {
            mapViewController *mvc = (mapViewController *)segue.destinationViewController;
            mvc.nowPositionX = [NSString stringWithFormat:@"%@",self.holdPositionX];
            mvc.nowPositionY = [NSString stringWithFormat:@"%@",self.holdPositionY];
            mvc.nowPositionID = [NSString stringWithFormat:@"%@",self.firstPositionID];
        }
    }
}


-(IBAction)textFieldReture:(id)sender
{
    [sender resignFirstResponder];
}



@end
