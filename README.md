# Cognito User Pools iOS Example Application

This application is a sample iOS application created to showcase how to integrate iOS applications with [AWS Cognito User Pools](http://docs.aws.amazon.com/cognito/latest/developerguide/cognito-user-identity-pools.html) (which are a part of the [AWS Cognito](https://aws.amazon.com/cognito/) service).

This code sample will be utilized in a series of articles which will expalain the integration. I will include links to the articles as they are published.

## Setup

To run the application, you will have to perform the following steps: installing the AWS dependencies, setting up the user pool configuration, and creating a sample user.

### Installing Dependencies

This application utilizes [CocoaPods](https://cocoapods.org/) for managing the dependencies. At this point, the only dependencies are the specific pieces of the AWS iOS SDK which relate to Cognito User Pools.

If you haven't used CocoaPods, be sure to read the [Getting Started Guide](https://guides.cocoapods.org/using/getting-started.html). Once you have CocoaPods installed, just navigate to the project directory in your terminal (the one which contains the Podfile file) and enter the following:

```bash
pod install
```

This will install the needed dependencies for this project. 

### User Pool Configuration

To use this example application, you will need to create a Cognito User Pool and add in four specific values to a config file. The config file should be named `CognitoApplication/CognitoConfig.plist`. This file should have the following keys:

| Key | Type | Value |
|----|----|----|
| **region** | String| This is the region in which you created your user pool.  This needs to be the standard region identifier such as 'us-east-1' or 'ap-southeast-1' |
| **poolId** | String | The id of the user pool that you created |
| **clientId** | String | The clientId configured as a part of the app that you attached to the user pool |
| **clientSecret** | String | The clientSecret that is configured as a part of the app that you attached to the user pool |

### Creating a Sample User

This initial version of the application does not include user signup (that will be handled in the second article).  This requires that you setup a user in the Cognito console.  For this to work as expected, the `given_name`, `family_name`, and `email` should be the only required attributes.
