//
//  MapViewController.m
//  MU Bus Tracking
//
//  Created by Jake Gregg on 9/27/13.
//  Copyright (c) 2013 Jake Gregg. All rights reserved.
//
#define ROUND_UP(N, S) ((((N) + (S) - 1) / (S)) * (S))
#import "MapViewController.h"

@interface MapViewController (private) <UITableViewDataSource, UITableViewDelegate, SidebarViewControllerDelegate, GMSMapViewDelegate>
@end

@implementation MapViewController
    
- (id)init {
    self = [super init];
    return self;
}

- (id)initWithRoutes:(NSArray*)route withCenter:(CLLocationCoordinate2D)center withZoom:(float)zoom {
    self = [super init];
    _routes = route;
    _center = center;
    _zoom = zoom;
    return self;
}

- (void)loadView
{
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:_center.latitude longitude:_center.longitude zoom:_zoom];
    _mapView_ = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"location"]) {
        _mapView_.myLocationEnabled = YES;
    } else {
        _mapView_.myLocationEnabled = NO;
    }
    _mapView_.settings.rotateGestures = NO;
    _mapView_.delegate = self;
    _mapView_.accessibilityElementsHidden = NO;
    self.view = _mapView_;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor clearColor];
    
    // Add left sidebar
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ButtonMenu.png"]  style:UIBarButtonItemStyleBordered target:self action:@selector(revealLeftSidebar:)];
    self.navigationItem.revealSidebarDelegate = self;

    if (![_routeName isEqualToString:@"ALL"]) {
        _busRefresh = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(checkBuses) userInfo:nil repeats:YES];
    }
    NSLog(@"Size of routes: %i", [_routes count]);
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    self.label = nil;
}

#pragma mark - private methods

- (UIImage *)overlayImage:(NSString *)name withColor:(UIColor *)color
{
    UIImage *image = [UIImage imageNamed: name];
    //  Create rect to fit the PNG image
    CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
    
    //  Start drawing
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    //  Fill the rect by the final color
    [color setFill];
    CGContextFillRect(context, rect);
    
    //  Make the final shape by masking the drawn color with the images alpha values
    CGContextSetBlendMode(context, kCGBlendModeDestinationIn);
    [image drawInRect: rect blendMode:kCGBlendModeDestinationIn alpha:1];
    
    //  Create new image from the context
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    
    //  Release context
    UIGraphicsEndImageContext();
    
    return img;
}

- (UIImage *)tintedImageWithColor:(NSString *) name :(UIColor *)tintColor
{
    UIImage *originalImage = [UIImage imageNamed: name];
    UIImage *imageForRendering = [originalImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:imageForRendering];
    // It's important to pass in 0.0f to this function to draw the image to the scale of the screen
    UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, NO, 0.0f);
    [tintColor setFill];
    CGRect bounds = CGRectMake(0, 0, imageView.bounds.size.width, imageView.bounds.size.height);
    UIRectFill(bounds);
    [imageView.image drawInRect:bounds blendMode:kCGBlendModeDestinationIn alpha:1.0];
    
    UIImage *tintedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return tintedImage;
}

-(UIImage *) createColoredImage:(NSString *) name {
    UIImage *originalImage = [UIImage imageNamed: name];
    UIImage *imageForRendering = [originalImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:imageForRendering];
    //imageView.image = imageForRendering;
    imageView.tintColor = [UIColor redColor];
    UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, NO, 0.0);
    [imageView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *coloredImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return coloredImage;
}

-(UIImage*) createColoredBusImage{
    
    CGImageRef originalImage = [[UIImage imageNamed:@"busStripped.png"] CGImage];
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef bitmapContext = CGBitmapContextCreate(NULL,
                                                       CGImageGetWidth(originalImage),
                                                       CGImageGetHeight(originalImage),
                                                       8,
                                                       CGImageGetWidth(originalImage)*4,
                                                       colorSpace,
                                                       kCGImageAlphaPremultipliedLast);
    
    CGContextDrawImage(bitmapContext, CGRectMake(0, 0, CGBitmapContextGetWidth(bitmapContext), CGBitmapContextGetHeight(bitmapContext)), originalImage);
    CGImageRef mask = [self createMaskWithImageAlpha:bitmapContext];
    
    UIImage *image = [UIImage imageNamed:@"busStripped.png"];
    //CGImageRef mask = [self createBusImageMask:image];
    CGRect imageFrame = CGRectMake(0,0,image.size.width,image.size.height);
    
    //CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClipToMask(bitmapContext, imageFrame, mask);
    
    // draw the image
    CGContextDrawImage(bitmapContext, imageFrame, mask);
    
    // set the blend mode and draw rectangle on top of image
    CGContextSetBlendMode(bitmapContext, kCGBlendModeColor);
    CGContextClipToMask(bitmapContext, imageFrame, mask); // respect alpha mask
    CGContextSetRGBFillColor(bitmapContext, 0.0, 0.0, 0.0, 1.0);
    CGContextFillRect(bitmapContext, imageFrame);
    
    image = UIGraphicsGetImageFromCurrentImageContext();
    //CGContextRelease(context);
    CGContextRelease(bitmapContext);
    CGImageRelease(mask);
    
    return image;
    
}

- (UIImage*) maskImage:(UIImage *)image withMask:(UIImage *)maskImage {
    
    CGImageRef maskRef = maskImage.CGImage;
    
    CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
                                        CGImageGetHeight(maskRef),
                                        CGImageGetBitsPerComponent(maskRef),
                                        CGImageGetBitsPerPixel(maskRef),
                                        CGImageGetBytesPerRow(maskRef),
                                        CGImageGetDataProvider(maskRef), NULL, false);
    
    CGImageRef masked = CGImageCreateWithMask([image CGImage], mask);
    return [UIImage imageWithCGImage:masked];
    
}

- (UIImage *)combineImage:(NSString *)name withBackgroundColor:(UIColor *)bgColor
{
    //UIImage *image = [UIImage imageNamed: name];
    //  Create rect to fit the PNG image
    CGRect rect = CGRectMake(0, 0, 20, 20);
    CGRect borderRectBlackOut = CGRectInset(rect, 1, 1);
    CGRect borderRectWhite = CGRectInset(rect, 3, 3);
    CGRect borderRectBlack = CGRectInset(borderRectWhite, 2, 2);
    
    //  Create bitmap contect
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    // Draw background first
    
    //  Set background color (will be under the PNG)
    //[bgColor setFill];
    
    //CGRect bufferedRect = CGRectMake(2, 2, 25, 30);
    //  Fill all context with background image
    //CGContextFillRect(context, rect);
    
    //  Draw the PNG over the background
    //[image drawInRect:rect];
    CGContextSetLineWidth(context, 2.0);
    CGContextSetFillColorWithColor(context, bgColor.CGColor);
    CGRect circlePoint = (CGRectMake(0, 0, 20.0, 20.0));
    
    CGContextFillEllipseInRect(context, circlePoint);
    
    CGContextSetLineWidth(context, 2.0);
    CGContextSetStrokeColorWithColor(context, [[UIColor whiteColor] CGColor]);
    CGContextStrokeEllipseInRect(context, borderRectWhite);
    
    CGContextSetLineWidth(context, 1.0);
    CGContextSetStrokeColorWithColor(context, [[UIColor blackColor] CGColor]);
    CGContextStrokeEllipseInRect(context, borderRectBlack);
    
    CGContextSetLineWidth(context, 1.0);
    CGContextSetStrokeColorWithColor(context, [[UIColor blackColor] CGColor]);
    CGContextStrokeEllipseInRect(context, borderRectBlackOut);
    
    //  Create new image from the context
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    
    //  Release context
    UIGraphicsEndImageContext();
    
    UIImageView *view = [[UIImageView alloc] initWithFrame:rect];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = view.bounds;
    //gradient.colors = [NSArray arrayWithObjects:(id)bgColor.CGColor, (id)[[UIColor grayColor] CGColor] ,(id)[[UIColor whiteColor] CGColor], nil];
    //gradient.locations = [NSArray arrayWithObjects:[[NSNumber alloc] initWithDouble: 0.60], [[NSNumber alloc] initWithDouble: 0.20], [[NSNumber alloc] initWithDouble: .20], nil];
    [view.layer insertSublayer:gradient atIndex:0];
    
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *retImg = UIGraphicsGetImageFromCurrentImageContext();
    
    
    UIGraphicsEndImageContext();
    
    return [self maskImage:img withMask:retImg];
}

- (CGImageRef) createMaskWithImageAlpha: (CGContextRef) originalImageContext {
    
    UInt8 *data = (UInt8 *)CGBitmapContextGetData(originalImageContext);
    
    float width = CGBitmapContextGetBytesPerRow(originalImageContext) / 4;
    float height = CGBitmapContextGetHeight(originalImageContext);
    
    // Make a bitmap context that's only 1 alpha channel
    // WARNING: the bytes per row probably needs to be a multiple of 4
    int strideLength = ROUND_UP(width * 1, 4);
    unsigned char * alphaData = (unsigned char * )calloc(strideLength * height, 1);
    CGContextRef alphaOnlyContext = CGBitmapContextCreate(alphaData,
                                                          width,
                                                          height,
                                                          8,
                                                          strideLength,
                                                          NULL,
                                                          kCGImageAlphaOnly);
    
    // Draw the RGBA image into the alpha-only context.
    //CGContextDrawImage(alphaOnlyContext, CGRectMake(0, 0, width, height), originalMaskImage);
    
    // Walk the pixels and invert the alpha value. This lets you colorize the opaque shapes in the original image.
    // If you want to do a traditional mask (where the opaque values block) just get rid of these loops.
    
    
    for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
            //unsigned char val = alphaData[y*strideLength + x];
            unsigned char val = data[y*(int)width*4 + x*4 + 3];
            val = 255 - val;
            alphaData[y*strideLength + x] = val;
        }
    }
    
    
    CGImageRef alphaMaskImage = CGBitmapContextCreateImage(alphaOnlyContext);
    CGContextRelease(alphaOnlyContext);
    free(alphaData);
    
    // Make a mask
    CGImageRef finalMaskImage = CGImageMaskCreate(CGImageGetWidth(alphaMaskImage),
                                                  CGImageGetHeight(alphaMaskImage),
                                                  CGImageGetBitsPerComponent(alphaMaskImage),
                                                  CGImageGetBitsPerPixel(alphaMaskImage),
                                                  CGImageGetBytesPerRow(alphaMaskImage),
                                                  CGImageGetDataProvider(alphaMaskImage),     NULL, false);
    CGImageRelease(alphaMaskImage);
    
    return finalMaskImage;
}

-(CGImageRef) createBusImageMask:(UIImage*) image {
    
    CGImageRef originalMaskImage = [image CGImage];
    float width = CGImageGetWidth(originalMaskImage);
    float height = CGImageGetHeight(originalMaskImage);
    
    int strideLength = ROUND_UP(width * 1, 4);
    unsigned char * alphaData = calloc(strideLength * height, sizeof(unsigned char));
    CGContextRef alphaOnlyContext = CGBitmapContextCreate(alphaData,
                                                          width,
                                                          height,
                                                          8,
                                                          strideLength,
                                                          NULL,
                                                          kCGImageAlphaOnly);
    
   
    CGContextDrawImage(alphaOnlyContext, CGRectMake(0, 0, width, height), originalMaskImage);
    
    for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
            unsigned char val = alphaData[y*strideLength + x];
            val = 255 - val;
            alphaData[y*strideLength + x] = val;
        }
    }
    
    CGImageRef alphaMaskImage = CGBitmapContextCreateImage(alphaOnlyContext);
    CGContextRelease(alphaOnlyContext);
    free(alphaData);

    
    CGImageRef finalMaskImage = CGImageMaskCreate(CGImageGetWidth(alphaMaskImage),
                                                  CGImageGetHeight(alphaMaskImage),
                                                  CGImageGetBitsPerComponent(alphaMaskImage),
                                                  CGImageGetBitsPerPixel(alphaMaskImage),
                                                  CGImageGetBytesPerRow(alphaMaskImage),
                                                  CGImageGetDataProvider(alphaMaskImage), NULL, false);
    return finalMaskImage;
}

-(void)addBusToMapWithBus:(Bus*)bus onMap:(GMSMapView*)map{
    // Add the Marker to the map
    CGFloat lat = (CGFloat)[bus.latitude floatValue];
    CGFloat lng = (CGFloat)[bus.longitude floatValue];
    
    GMSMarker *marker = [[GMSMarker alloc]init];
    marker.position = CLLocationCoordinate2DMake(lat, lng);
    marker.title = bus.busID;
    marker.icon = [UIImage imageNamed:@"bus.png"];
    //marker.icon = [self createColoredBusImage];
    bus.marker = [self createColoredImage:@"busStripped.png"];
    marker.map = map;
}

-(GMSPolyline*)createRouteWithPoints:(NSArray*) points{
    GMSMutablePath *path = [GMSMutablePath path];
    CLLocationCoordinate2D coordinate;
    
    for(int i =0; i < [points count]; i++){
        [[points objectAtIndex:i] getValue:&coordinate];
        [path addCoordinate:coordinate];
    }
    
    GMSPolyline *route = [GMSPolyline polylineWithPath:path];
    
    return route;
}

-(void)plotStopsWithStops:(NSArray*)stops withRoute:(Route*)route onMap:(GMSMapView*)map{
    Stop *stop;
    for (int i=0; i< [stops count]; i++) {
        GMSMarker *marker = [[GMSMarker alloc]init];
        stop = [stops objectAtIndex:i];
        marker.position = stop.location;
        marker.title = stop.name;
        //marker.icon = [UIImage imageNamed:@"busstop.png"];
        //marker.icon = [UIImage imageNamed:@"busStripped.png"];
        //marker.icon = [self createColoredImage:@"busStripped.png"];
        ColorService *cs = [[ColorService alloc]init];
        marker.icon = [self combineImage:@"busStripped.png" withBackgroundColor:route.color];
        marker.map = map;
    }
}

-(void)checkBuses {
    if (![_buses isKindOfClass:[NSNull class] ]) {
        for (Bus *bus in _buses) {
            bus.marker.map = nil;
        }
    
        BusService *bs = [[BusService alloc]init];
        _buses = [bs getBusWithRoute:_routeName];
    
        for(Bus *bus in _buses){
            [self addBusToMapWithBus:bus onMap:_mapView_];
        }
    }
    
}

#pragma mark Action

- (void)revealLeftSidebar:(id)sender {
    [self.navigationController toggleRevealState:JTRevealedStateLeft];
}

- (void)revealRightSidebar:(id)sender {
    [self.navigationController toggleRevealState:JTRevealedStateRight];
}

#pragma mark JTRevealSidebarDelegate

// This is an examle to configure your sidebar view through a custom UIViewController
- (UIView *)viewForLeftSidebar {
    // Use applicationViewFrame to get the correctly calculated view's frame
    // for use as a reference to our sidebar's view
    CGRect viewFrame = self.navigationController.applicationViewFrame;
    UITableViewController *controller = self.leftSidebarViewController;
    if ( ! controller) {
        self.leftSidebarViewController = [[SidebarViewController alloc] init];
        self.leftSidebarViewController.sidebarDelegate = self;
        controller = self.leftSidebarViewController;
        controller.title = @"Routes";
        self.leftSidebarViewController.routes = _routes;
        
    }
    ColorService *cs = [[ColorService alloc] init];
    controller.view.backgroundColor = [UIColor whiteColor];
    controller.navigationController.navigationBar.barTintColor = [cs getColorFromHexString:APP_COLOR];
    //controller.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"OpeH1.png"]]];
    controller.view.frame = CGRectMake(0, viewFrame.origin.y, 270, viewFrame.size.height);
    controller.view.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight;
    return controller.view;
}

// Optional delegate methods for additional configuration after reveal state changed
- (void)didChangeRevealedStateForViewController:(UIViewController *)viewController {
    // Example to disable userInteraction on content view while sidebar is revealing
    if (viewController.revealedState == JTRevealedStateNo) {
        self.view.userInteractionEnabled = YES;
    } else {
        self.view.userInteractionEnabled = NO;
    }
}

@end


@implementation MapViewController (Private)

#pragma mark SidebarViewControllerDelegate

- (void)sidebarViewController:(SidebarViewController *)sidebarViewController didSelectObject:(NSObject *)object atIndexPath:(NSIndexPath *)indexPath {
    
    [self.navigationController setRevealedState:JTRevealedStateNo];
    if (indexPath.row < [_routes count] +2) {
        MapViewController *controller = [[MapViewController alloc] init];
        controller.routes = _routes;
        controller.buses = _buses;
        controller.routeName = (indexPath.row == 0 ? @"ALL" :(indexPath.row==1 ? @"ALL" : (indexPath.row > 1 && indexPath.row < [_routes count]+2 ? ((Route*)(_routes[indexPath.row-2])).name : @"Settings")));
        controller.center = (indexPath.row == 0 ? CLLocationCoordinate2DMake(MAIN_LAT, MAIN_LON):(indexPath.row==1 ? CLLocationCoordinate2DMake(MAIN_LAT, MAIN_LON) :(indexPath.row > 1 && indexPath.row < [_routes count]+2 ? ((Route*)_routes[indexPath.row-2]).center:CLLocationCoordinate2DMake(MAIN_LAT, MAIN_LON))));
        controller.zoom = (indexPath.row == 0 ? MAIN_ZOOM :(indexPath.row==1 ? MAIN_ZOOM:(indexPath.row > 1 && indexPath.row < [_routes count]+2 ? ((Route*)_routes[indexPath.row-2]).zoom:MAIN_ZOOM)));
        [_busRefresh invalidate];
        _busRefresh = nil;
        
        controller.view.backgroundColor = [UIColor clearColor];
        controller.title = (NSString *)object;
        controller.leftSidebarViewController  = sidebarViewController;
        controller.leftSelectedIndexPath      = indexPath;

        sidebarViewController.sidebarDelegate = controller;
        [self.navigationController setViewControllers:[NSArray arrayWithObject:controller] animated:NO];
        if (indexPath.row==0)
            [self showFavorites:controller.mapView_];
        else if (indexPath.row==1)
            [self showAllRoutesOnMap:controller.mapView_];
        else if (indexPath.row > 1 && indexPath.row < [_routes count]+2)
            [self showBusWithRoute:_routes[indexPath.row-2] onMap:controller.mapView_];
    }
    else
        [self displaySettings:sidebarViewController withName:object withIndexPath:indexPath];
        //[self showAllRoutesOnMap:controller.mapView_];
}

-(void)showFavorites:(GMSMapView*)map {
    float alpha = 1.f;
    for (Route *r in _routes) {
        BOOL isFav = [[NSUserDefaults standardUserDefaults] boolForKey:r.name];
        if(isFav){
            NSArray *curr = r.shape;
            GMSPolyline *routeLine = [self createRouteWithPoints:curr];
            routeLine.map = map;
            const CGFloat *cArr = CGColorGetComponents(r.color.CGColor);
            UIColor *c = [UIColor colorWithRed:cArr[0] green:cArr[1] blue:cArr[2] alpha:alpha];
            alpha-= .10f;
            routeLine.strokeColor = c;
            routeLine.strokeWidth = 10.f;
            routeLine.geodesic = YES;
        }
    }
}

-(void)showAllRoutesOnMap:(GMSMapView*)map {
    float alpha = 1.f;
    for (Route *r in _routes) {
        NSArray *curr = r.shape;
        GMSPolyline *routeLine = [self createRouteWithPoints:curr];
        routeLine.map = map;
        const CGFloat *cArr = CGColorGetComponents(r.color.CGColor);
        UIColor *c = [UIColor colorWithRed:cArr[0] green:cArr[1] blue:cArr[2] alpha:alpha];
        alpha-= .10f;
        routeLine.strokeColor = c;
        routeLine.strokeWidth = 10.f;
        routeLine.geodesic = YES;
    }
    
}

-(void)showBusWithRoute:(Route *)route onMap:(GMSMapView*)map{
    BusService *bs = [[BusService alloc] init];
    NSArray *curr = [bs getBusWithRoute:route.name];
    if (curr) {
        for (Bus *bus in curr) {
            [self addBusToMapWithBus:bus onMap:map];
        }
    }
    
    StopService *ss = [[StopService alloc] init];
    NSArray *stops = [ss getStopsWithRoute:route.name];
    [self plotStopsWithStops:stops withRoute:route onMap:map];
    
    //RouteService *rs = [[RouteService alloc] init];
    NSArray *coords = route.shape;
    GMSPolyline *routeLine = [self createRouteWithPoints:coords];
    routeLine.map = map;
    routeLine.strokeColor = route.color;
    routeLine.strokeWidth = 10.f;
    routeLine.geodesic = YES;
}

-(void) displaySettings:(SidebarViewController*)sidebarViewController withName:(NSObject *)object withIndexPath:(NSIndexPath*)indexPath {
    SettingsViewController *controller = [[SettingsViewController alloc]initWithRoutes:_routes];
    controller.view.backgroundColor = [UIColor whiteColor];
    controller.title = (NSString *)object;
    controller.leftSidebarViewController  = sidebarViewController;
    controller.leftSelectedIndexPath      = indexPath;
    controller.routes = _routes;
    controller.buses = _buses;
    controller.routeName = (indexPath.row == 0 ? @"ALL" :(indexPath.row==1 ? @"ALL" : (indexPath.row > 1 && indexPath.row < [_routes count]+2 ? ((Route*)(_routes[indexPath.row-2])).name : @"Settings")));
    controller.center = (indexPath.row == 0 ? CLLocationCoordinate2DMake(MAIN_LAT, MAIN_LON):(indexPath.row==1 ? CLLocationCoordinate2DMake(MAIN_LAT, MAIN_LON) :(indexPath.row > 1 && indexPath.row < [_routes count]+2 ? ((Route*)_routes[indexPath.row-2]).center:CLLocationCoordinate2DMake(MAIN_LAT, MAIN_LON))));
    controller.zoom = (indexPath.row == 0 ? MAIN_ZOOM :(indexPath.row==1 ? MAIN_ZOOM:(indexPath.row > 1 && indexPath.row < [_routes count]+2 ? ((Route*)_routes[indexPath.row-2]).zoom:MAIN_ZOOM)));
    [_busRefresh invalidate];
    _busRefresh = nil;
    sidebarViewController.sidebarDelegate = controller;

    [self.navigationController setViewControllers:[NSArray arrayWithObject:controller] animated:NO];
}

- (NSIndexPath *)lastSelectedIndexPathForSidebarViewController:(SidebarViewController *)sidebarViewController {
    return self.leftSelectedIndexPath;
}

# pragma mark GMSMapViewDelegate

-(void)mapView:(GMSMapView*)mapView didBeginDraggingMarker:(GMSMarker *)marker {
    NSLog(@"didBeginDraggingMarker");
}

-(void)mapView:(GMSMapView*)mapView didChangeCameraPosition:(GMSCameraPosition *)position {
    float dLat= 0.025f, dLon = 0.025f;
    if (position.zoom < 12.9 || position.target.latitude > _center.latitude + dLat
        || position.target.latitude < _center.latitude - dLat || position.target.longitude < _center.longitude - dLon ||
        position.target.longitude > _center.longitude + dLon) {
        GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:_center.latitude longitude:_center.longitude zoom:_zoom];
        [_mapView_ animateToCameraPosition:camera];
    }
    
}
-(void)mapView:(GMSMapView *)mapView didLongPressAtCoordinate:(CLLocationCoordinate2D)coordinate {
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:_center.latitude longitude:_center.longitude zoom:_zoom];
    [_mapView_ animateToCameraPosition:camera];
}

@end
