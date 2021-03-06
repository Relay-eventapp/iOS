//
//  LoginViewController.swift
//  EventApp
//
//  Created by Mike Zhao on 3/22/15.
//  Copyright (c) 2015 Mike Zhao. All rights reserved.
//

import UIKit
import Parse

class LoginViewController: UIViewController, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate {
    
    var logInViewController = PFLogInViewController()
    var signUpViewController = PFSignUpViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if(PFUser.currentUser() == nil) {
            
            logInViewController.delegate = self
            signUpViewController.delegate = self
            logInViewController.signUpController = signUpViewController
            presentLogInSignUpView()
        }
        else
        {
            self.dismissViewControllerAnimated(false, completion: nil)
        }
    }
    
    //present the Login and Signup View
    func presentLogInSignUpView()
    {
        logInViewController.fields = (PFLogInFields.UsernameAndPassword
            | PFLogInFields.LogInButton
            | PFLogInFields.SignUpButton
            | PFLogInFields.DismissButton
            | PFLogInFields.PasswordForgotten)
        
        self.presentViewController(logInViewController, animated: true, completion: nil)
    }
    
    //Verify User Info
    func logInViewController(logInController: PFLogInViewController, shouldBeginLogInWithUsername username: String, password: String) -> Bool
    {
        if(!username.isEmpty || !password.isEmpty)
        {
            return true
        }
        else
        {
            return false
        }
    }
    
    //Log In
    func logInViewController(logInController: PFLogInViewController, didLogInUser user: PFUser)
    {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func signUpViewController(signUpController: PFSignUpViewController, didSignUpUser user: PFUser) {
        signUpController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //Fail to Log In
    func logInViewController(logInController: PFLogInViewController, didFailToLogInWithError error: NSError?)
    {
        println("Failed to log in...")
    }
    
    //Sign up View
    func signUpViewController(signUpController: PFSignUpViewController, shouldBeginSignUp info: [NSObject : AnyObject]) -> Bool
    {
        if let password = info["password"] as? String
        {
            return count(password.utf16) >= 4
        }
        else
        {
            return false
        }
    }
    
    //Fail to Sign Up
    func signUpViewController(signUpController: PFSignUpViewController, didFailToSignUpWithError error: NSError?)
    {
        println("Failed to sign up...")
    }
    
    //Cancel Sign Up
    func signUpViewControllerDidCancelSignUp(signUpController: PFSignUpViewController)
    {
        println("User dismissed sign up.")
    }
}