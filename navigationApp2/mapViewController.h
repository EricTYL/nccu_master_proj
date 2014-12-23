//
//  mapViewController.h
//  navigationApp2
//
//  Created by juston1 on 2014/9/21.
//  Copyright (c) 2014年 juston1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ESTBeacon.h"
#import "ViewController.h"

@interface mapViewController : UIViewController
@property (nonatomic,strong) NSString *nowPositionX;
@property (nonatomic,strong) NSString *nowPositionY;
@property (nonatomic,strong) NSString *nowPositionID;
@property (nonatomic,strong) NSString *secondPositionID;
@property (nonatomic,strong) NSString *secondPositionX;
@property (nonatomic,strong) NSString *secondPositionY;
@property (nonatomic,strong) NSMutableArray *storePath;
@property (nonatomic,strong) NSMutableDictionary *infoFromBackstage;
@property (nonatomic,strong) NSMutableDictionary *pathFromBackstage;
@property (nonatomic,strong) NSMutableDictionary *displaysFromBackstage;
@property (nonatomic,strong) NSURL *imageURL;
@property (nonatomic,strong) NSString *firstTimeMapViewControllerLoad;
@end
