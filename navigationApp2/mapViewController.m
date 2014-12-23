//
//  mapViewController.m
//  navigationApp2
//
//  Created by juston1 on 2014/9/21.
//  Copyright (c) 2014年 juston1. All rights reserved.
//

#import "mapViewController.h"
#import "infoViewController.h"
#import "ESTBeaconManager.h"

//add in 2014/12/14
//start
@interface mapViewController () <ESTBeaconManagerDelegate>
@property (nonatomic, strong) ESTBeacon         *nearestbeacon;
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

@interface mapViewController () <UIScrollViewDelegate>
@property (strong, nonatomic) IBOutlet UIView *showView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *getPositionID;
@property (weak, nonatomic) IBOutlet UIButton *rePositionButton;
@property (weak, nonatomic) IBOutlet UIButton *startNavigationButton;
@property (weak, nonatomic) IBOutlet UIView *viewInScrollView;
//@property (nonatomic, strong) UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) UIImage *image;
@end

@implementation mapViewController

static const CGSize DROP_SIZE = {10 , 10};
NSMutableArray *storeEveryPathRect;
NSMutableArray *storePositionIcon;

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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //add in 2014/12/18
    //start
    
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
        if(_nearestbeacon == nil){
            _nearestbeacon = [self.beaconsArray objectAtIndex:0];
        }
    }
    beacon = [self.beaconsArray objectAtIndex:0];
    
    ////////            judgement         //////////////

    if ([_nearestbeacon.minor integerValue] == [beacon.minor integerValue]){

        CGRect frame;
        frame.origin = CGPointZero;
        frame.size = CGSizeMake(12, 12);
        frame.origin.x = [[[self.infoFromBackstage objectForKey:[_nearestbeacon.minor stringValue]] objectForKey:@"xpos"] integerValue];
        frame.origin.y = [[[self.infoFromBackstage objectForKey:[_nearestbeacon.minor stringValue]] objectForKey:@"ypos"] integerValue];
        UIView *test = [[UIView alloc]initWithFrame:frame];
        test.backgroundColor = [UIColor greenColor];

        NSLog(@"(x,y) from self.infoFromBackstage %d %d\n",[[[self.infoFromBackstage objectForKey:[_nearestbeacon.minor stringValue]] objectForKey:@"xpos"] integerValue],[[[self.infoFromBackstage objectForKey:[_nearestbeacon.minor stringValue]] objectForKey:@"ypos"] integerValue]);
//        NSLog(@"id from self.pathFromBackstage %d\n",[[self.pathFromBackstage objectForKey:@"id"] integerValue]);
        NSLog(@"(x,y) from self.displayFromBackstage %d %d\n",[[[self.displaysFromBackstage objectForKey:[_nearestbeacon.minor stringValue]] objectForKey:@"xpos"] integerValue],[[[self.infoFromBackstage objectForKey:[_nearestbeacon.minor stringValue]] objectForKey:@"ypos"] integerValue]);
        for(id view in self.viewInScrollView.subviews)
        {
            if ([view backgroundColor]==[UIColor greenColor] || [view backgroundColor]==[UIColor redColor]) {
                [view removeFromSuperview];
            }
        }
        
        for(id icon in storePositionIcon)
        {
            [icon removeFromSuperview];
        }

//        [self.scrollView addSubview:userLocationImg];
        [self.viewInScrollView addSubview:test];
        
//        [storePositionIcon addObject:userLocationImg];
        self.nowPositionID = [_nearestbeacon.minor stringValue];

        NSLog(@"^^^^^^^^^");
    }

    _nearestbeacon = [self.beaconsArray objectAtIndex:0];
            beacon = [self.beaconsArray objectAtIndex:0];
    
    NSNumber *a = [[NSNumber alloc] initWithDouble:0.2];
    if([_nearestbeacon.distance floatValue] < [a floatValue]){
        NSLog(@"click button %@ %@ %@",self.nowPositionID,self.nowPositionX,self.nowPositionY);
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        infoViewController *mvc = (infoViewController *)[storyboard instantiateViewControllerWithIdentifier:@"infoViewStoryboard"];
        mvc.holdPositionID = self.nowPositionID;
        mvc.holdPositionX = self.nowPositionX;
        mvc.holdPositionY = self.nowPositionY;
        mvc.holdDisplaysName = [[self.displaysFromBackstage objectForKey:self.nowPositionID] objectForKey:@"name"];
        mvc.holdDisplaysImg = [[self.displaysFromBackstage objectForKey:self.nowPositionID] objectForKey:@"img"];
        mvc.holdDisplaysDescription = [[self.displaysFromBackstage objectForKey:self.nowPositionID] objectForKey:@"description"];
        
        mvc.holdFirstTimeMapViewControllerLoad = self.firstTimeMapViewControllerLoad;
        [self presentViewController:mvc animated:YES completion:^{}];
    }

}

- (void)beaconManager:(ESTBeaconManager *)manager didDiscoverBeacons:(NSArray *)beacons inRegion:(ESTBeaconRegion *)region
{
    self.beaconsArray = beacons;
    
    NSLog(@"didDiscoverBeacons");
}
//end
#pragma forScrollView

-(void)setScrollView:(UIScrollView *)scrollView
{
    _scrollView = scrollView;
    _scrollView.minimumZoomScale = 1;
    _scrollView.maximumZoomScale = 1.8;
    _scrollView.delegate = self;
    self.scrollView.contentSize = self.image ? self.image.size : CGSizeZero;
}

#pragma firstTimeAllocate
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.firstTimeMapViewControllerLoad = [NSString stringWithFormat:@"YES"];
    
#pragma set a UIButton of userIcon with hardcode
    
    UIButton *userLocationImg = [[UIButton alloc]init];
//    [userLocationImg addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [userLocationImg setBackgroundImage:
     [UIImage imageWithData:[NSData dataWithContentsOfFile:@"/Users/redapple/Desktop/iOS_developer/navigationApp3/素材/導覽地圖/user_icon.png"]]
                               forState:UIControlStateNormal];
    userLocationImg.frame = CGRectMake([self.nowPositionX integerValue], [self.nowPositionY integerValue], 30, 40);
    
    storePositionIcon = [[NSMutableArray alloc]init];
    storeEveryPathRect = [[NSMutableArray alloc]init];
    
    [self.viewInScrollView addSubview:userLocationImg];
    [storePositionIcon addObject:userLocationImg];
    self.startNavigationButton.enabled=NO;
    
    
#pragma download positions and paths information and displays_information from backstage
    
    self.storePath = [[NSMutableArray alloc]init];
    NSString *urlstring = [NSString stringWithFormat:@"http://salty-spire-9482.herokuapp.com/positions.json"];
    NSURL *url = [NSURL URLWithString:urlstring];
    NSData *data = [NSData dataWithContentsOfURL:url];
    NSError *error = nil;
    NSMutableArray *json = (NSMutableArray*)[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
    self.infoFromBackstage = [[NSMutableDictionary alloc]init];
    self.pathFromBackstage = [[NSMutableDictionary alloc]init];
    self.displaysFromBackstage = [[NSMutableDictionary alloc]init];
    
    
    for(int i=0;i<[json count];i++){
        [self.infoFromBackstage setObject:[json objectAtIndex:i] forKey:[[json objectAtIndex:i] objectForKey:@"name"]];
    }
    
    NSString *pathUrlstring = [NSString stringWithFormat:@"http://salty-spire-9482.herokuapp.com/paths.json"];
    NSURL *pathUrl = [NSURL URLWithString:pathUrlstring];
    NSData *pathData = [NSData dataWithContentsOfURL:pathUrl];
    NSError *pathError = nil;
    NSMutableArray *pathJson = (NSMutableArray*)[NSJSONSerialization JSONObjectWithData:pathData options:kNilOptions error:&pathError];
    
    for(int i=0;i<[pathJson count];i++){
        [self.pathFromBackstage setObject:[pathJson objectAtIndex:i] forKey:[[pathJson objectAtIndex:i] objectForKey:@"name"]];
    }
    
    NSString *displaysUrlstring = [NSString stringWithFormat:@"http://salty-spire-9482.herokuapp.com/exhibits.json"];
    NSURL *displaysUrl = [NSURL URLWithString:displaysUrlstring];
    NSData *displaysData = [NSData dataWithContentsOfURL:displaysUrl];
    NSError *displaysError = nil;
    NSMutableArray *displaysJson = (NSMutableArray*)[NSJSONSerialization JSONObjectWithData:displaysData options:kNilOptions error:&displaysError];
    
    for(int i=0;i<[displaysJson count];i++){
        [self.displaysFromBackstage setObject:[displaysJson objectAtIndex:i] forKey:[[displaysJson objectAtIndex:i] objectForKey:@"minor"]];
    }
    
    NSLog(@"self.displaysFromBackstage: %@",self.displaysFromBackstage);
    
}


#pragma secondTimeAllocate
- (IBAction)findOurPlaceAgain:(UIButton *)sender {
    
    UIButton *userLocationImg = [[UIButton alloc]init];
//    [userLocationImg addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [userLocationImg setBackgroundImage:
     [UIImage imageWithData:[NSData dataWithContentsOfFile:@"/Users/redapple/Desktop/iOS_developer/navigationApp3/素材/導覽地圖/user_icon.png"]]
                               forState:UIControlStateNormal];
    userLocationImg.frame = CGRectMake([[[self.infoFromBackstage objectForKey:self.getPositionID.text] objectForKey:@"xpos"] integerValue],
                                       [[[self.infoFromBackstage objectForKey:self.getPositionID.text] objectForKey:@"ypos"] integerValue], 30, 40);
    
    for(id view in storeEveryPathRect){
        [view removeFromSuperview];
    }
    
    for(id icon in storePositionIcon){
        [icon removeFromSuperview];
    }
    
    [self.viewInScrollView addSubview:userLocationImg];
    [storePositionIcon addObject:userLocationImg];
    _nowPositionID = self.getPositionID.text;
    NSLog(@"%@ after set now Position ID",self.nowPositionID);
    
    if(self.secondPositionID){
        
        int pointOfPathCount=0;
        
        NSString *pathToBeSeperated = [[self.pathFromBackstage objectForKey:
                                        [NSString stringWithFormat:@"%@,%@",self.nowPositionID,self.secondPositionID]] objectForKey:@"pathInfo"];
        
        NSLog(@"now in findPlaceAgain  %@,%@",self.nowPositionID,self.secondPositionID);
        
        for(id rect in storeEveryPathRect){
            NSLog(@"remove every path rect in findOurPlaceAgain");
            [rect removeFromSuperview];
        }
        
        while(pointOfPathCount < [pathToBeSeperated componentsSeparatedByString:@" "].count){
            
            [self.storePath insertObject:[[pathToBeSeperated componentsSeparatedByString:@" "]
                                          objectAtIndex:pointOfPathCount] atIndex:pointOfPathCount];
            
            NSString *xPositionSecond = [[[[pathToBeSeperated componentsSeparatedByString:@" "]
                                           objectAtIndex:pointOfPathCount] componentsSeparatedByString:@","] firstObject];
            NSString *yPositionSecond = [[[[pathToBeSeperated componentsSeparatedByString:@" "]
                                           objectAtIndex:pointOfPathCount] componentsSeparatedByString:@","] lastObject];
            
            NSLog(@"%@ %@",xPositionSecond,yPositionSecond);
            
            CGRect frame;
            frame.origin = CGPointZero;
            frame.size = DROP_SIZE;
            frame.origin.x = [xPositionSecond integerValue];
            frame.origin.y = [yPositionSecond integerValue];
            
            UIView *showPlaceView = [[UIView alloc]initWithFrame:frame];
            
            if(pointOfPathCount == [pathToBeSeperated componentsSeparatedByString:@" "].count-1)
                showPlaceView.backgroundColor = [UIColor redColor];
            else
                showPlaceView.backgroundColor = [UIColor blueColor];
            
            [UIView animateWithDuration:1.2 delay:0.1 options:UIViewAnimationOptionRepeat animations:^{
                if (showPlaceView.alpha == 1) {[showPlaceView setAlpha:0.2];}
                else if (showPlaceView.alpha != 1){[showPlaceView setAlpha:1];}}
                             completion:^(BOOL finished) {}];
            [storeEveryPathRect addObject:showPlaceView];
            
            if(pointOfPathCount!=0)
                [self.viewInScrollView addSubview:showPlaceView];
            
            pointOfPathCount++;
        }
    }
}

- (IBAction)getSecondPoint:(UIButton *)sender {
    
    _secondPositionID = sender.restorationIdentifier;
    NSLog(@"get second point %@",self.secondPositionID);
    self.startNavigationButton.enabled=YES;
    
}

#pragma navigation
- (IBAction)navigationStart:(UIButton *)sender {
    
    int pointOfPathCount=0;
    
    NSString *pathToBeSeperated = [[self.pathFromBackstage objectForKey:
                                    [NSString stringWithFormat:@"%@,%@",self.nowPositionID,self.secondPositionID]] objectForKey:@"pathInfo"];
    
    for(id rect in storeEveryPathRect){
        [rect removeFromSuperview];
    }
    
    NSLog(@" navigation start positionID %@.%@",self.nowPositionID,self.secondPositionID);
    
    while(pointOfPathCount < [pathToBeSeperated componentsSeparatedByString:@" "].count){
        
        [self.storePath insertObject:[[pathToBeSeperated componentsSeparatedByString:@" "]
                                      objectAtIndex:pointOfPathCount] atIndex:pointOfPathCount];
        
        NSString *xPositionSecond = [[[[pathToBeSeperated componentsSeparatedByString:@" "]
                                       objectAtIndex:pointOfPathCount] componentsSeparatedByString:@","] firstObject];
        NSString *yPositionSecond = [[[[pathToBeSeperated componentsSeparatedByString:@" "]
                                       objectAtIndex:pointOfPathCount] componentsSeparatedByString:@","] lastObject];
        
        NSLog(@"%@ %@",xPositionSecond,yPositionSecond);
        
        CGRect frame;
        frame.origin = CGPointZero;
        frame.size = DROP_SIZE;
        frame.origin.x = [xPositionSecond integerValue];
        frame.origin.y = [yPositionSecond integerValue];
        
        UIView *showPlaceView = [[UIView alloc]initWithFrame:frame];
        
        if(pointOfPathCount == [pathToBeSeperated componentsSeparatedByString:@" "].count-1)
            showPlaceView.backgroundColor = [UIColor redColor];
        else
            showPlaceView.backgroundColor = [UIColor blueColor];
        
        [UIView animateWithDuration:1.2 delay:0.1 options:UIViewAnimationOptionRepeat animations:^{
            if (showPlaceView.alpha == 1) {
                [showPlaceView setAlpha:0.2];
            }else if (showPlaceView.alpha != 1){
                [showPlaceView setAlpha:1];
            }
        } completion:^(BOOL finished) {
            
        }];
        
        [storeEveryPathRect addObject:showPlaceView];
        
        if(pointOfPathCount!=0)
            [self.viewInScrollView addSubview:showPlaceView];
        
        pointOfPathCount++;
    }
}


-(IBAction)textFieldReture:(id)sender
{
    [sender resignFirstResponder];
}
/*
-(void)buttonClick:(id)sender
{

    ESTBeacon *beacon111;
    beacon111 = [self.beaconsArray objectAtIndex:0];
    NSNumber *a = [[NSNumber alloc] initWithDouble:0.2];

    if(beacon111.distance < a){
    NSLog(@"click button %@ %@ %@",self.nowPositionID,self.nowPositionX,self.nowPositionY);
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    infoViewController *mvc = (infoViewController *)[storyboard instantiateViewControllerWithIdentifier:@"infoViewStoryboard"];
    mvc.holdPositionID = self.nowPositionID;
    mvc.holdPositionX = self.nowPositionX;
    mvc.holdPositionY = self.nowPositionY;
    mvc.holdDisplaysName = [[self.displaysFromBackstage objectForKey:self.nowPositionID] objectForKey:@"name"];
    mvc.holdDisplaysImg = [[self.displaysFromBackstage objectForKey:self.nowPositionID] objectForKey:@"img"];
    mvc.holdDisplaysDescription = [[self.displaysFromBackstage objectForKey:self.nowPositionID] objectForKey:@"description"];
    
    mvc.holdFirstTimeMapViewControllerLoad = self.firstTimeMapViewControllerLoad;
    [self presentViewController:mvc animated:YES completion:^{}];
    }
    
}
*/
@end