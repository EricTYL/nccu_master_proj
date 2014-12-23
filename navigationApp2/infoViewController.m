//
//  infoViewController.m
//  navigationApp2
//
//  Created by juston1 on 2014/11/30.
//  Copyright (c) 2014年 juston1. All rights reserved.
//

#import "infoViewController.h"
#import "mapViewController.h"

@interface infoViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation infoViewController


- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    NSLog(@"ID:%@,xpos:%@,ypos:%@!!!!!!!!!!!!",self.holdPositionID,self.holdPositionX,self.holdPositionY);
    
  //  NSURL *imgUrl = [NSURL URLWithString:self.holdDisplaysImg];
  //  self.imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:imgUrl]];
    self.label.text = self.holdDisplaysName;
    self.textView.text =self.holdDisplaysDescription;
    
    UIButton *xButtonImg = [[UIButton alloc]init];
    [xButtonImg addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [xButtonImg setBackgroundImage:
     [UIImage imageWithData:[NSData dataWithContentsOfFile:@"/Users/redapple/Desktop/iOS_developer/navigationApp3/navigationApp2/素材/文物說明/x.png"]]
                               forState:UIControlStateNormal];
    xButtonImg.frame = CGRectMake(100, 0, 40, 55);
    
    [self.view addSubview:xButtonImg];
    
}

-(void)buttonClick:(id)sender
{
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    mapViewController *mvc = (mapViewController *)[storyboard instantiateViewControllerWithIdentifier:@"mapViewStoryboard"];
    mvc.nowPositionID = self.holdPositionID;
    mvc.nowPositionX = self.holdPositionX;
    mvc.nowPositionY = self.holdPositionY;
    mvc.firstTimeMapViewControllerLoad = [NSString stringWithFormat:@"NO"];
    NSLog(@"page3 buttonclick firstTimeMVCC change to: %@",mvc.firstTimeMapViewControllerLoad);
    
    [self presentViewController:mvc animated:YES completion:^{}];
    
}


@end
