//
//  LoginController.swift
//  Onboarding
//
//  Created by jungwooram on 2020-05-13.
//  Copyright © 2020 jungwooram. All rights reserved.
//

import UIKit
import GoogleSignIn

protocol AuthenticationDelegate: class {
    func authenticationComplete()
}
class LoginController: UIViewController {

    // MARK : - Properties
    
    weak var delegate: AuthenticationDelegate?
    
    private var viewModel = LoginViewModel()
    
    private let iconImage = UIImageView(image: #imageLiteral(resourceName: "firebase-logo"))
    
    private let emailTextField = CustomTextField(placeholder: "Email")
    
    private let passwordTextField: CustomTextField = {
        let tf = CustomTextField(placeholder: "Password")
        tf.isSecureTextEntry = true
        return tf
    }()
    
    private let loginButton: AuthButton = {
        let button = AuthButton(type: .system)
        button.title = "Log In"
        button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        return button
    }()
        
    private let forgotPasswordButton: UIButton = {
        let button = UIButton(type: .system)
        let atts: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor(white: 1.0, alpha: 0.87), .font: UIFont.systemFont(ofSize: 15)]
        let attributedTitle = NSMutableAttributedString(string: "Forgat your password? ",
                                                        attributes: atts)
        let boldAtts: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor(white: 1.0, alpha: 0.87), .font: UIFont.boldSystemFont(ofSize: 15)]
        attributedTitle.append(NSAttributedString(string: "Get help signing in.",
                                                  attributes: boldAtts))
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.addTarget(self, action: #selector(showForgotPassword), for: .touchUpInside)
        return button
    }()
    
    private let dividerView = DividerView()

    private let googleLoginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "btn_google_light_pressed_ios").withRenderingMode(.alwaysOriginal), for: .normal)
        button.setTitle("  Log in with Google", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(handleGoogleLogin), for: .touchUpInside)
        return button
    }()
    
    private let dontHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        let atts: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor(white: 1.0, alpha: 0.87), .font: UIFont.systemFont(ofSize: 16)]
        let attributedTitle = NSMutableAttributedString(string: "Don't have an account? ",
                                                        attributes: atts)
        let boldAtts: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor(white: 1.0, alpha: 0.87), .font: UIFont.boldSystemFont(ofSize: 16)]
        attributedTitle.append(NSAttributedString(string: "Sign Up",
                                                  attributes: boldAtts))
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.addTarget(self, action: #selector(showSignUpController), for: .touchUpInside)
        return button
    }()
    
    // MARK : - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureNotificationObservers()
        configureGoogleSignIn()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // MARK: - Selectors
    
    @objc func handleLogin() {
        
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
    
        showLoader(true)
        
        Service.logUserIn(withEmail: email, password: password, completion: { result, error in
            
            self.showLoader(false)

            if let error = error {
                self.showMessage(withTitle: "Error", message: error.localizedDescription)
                return
            }
            
            self.delegate?.authenticationComplete()
        })
        
    }
    
    @objc func showForgotPassword() {
        let controller = ResetPasswordController()
        controller.delegate = self
        controller.email = emailTextField.text
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func handleGoogleLogin() {
        showLoader(true)
        GIDSignIn.sharedInstance()?.signIn()
    }
    
    @objc func showSignUpController() {
        let controller = RegistrationController()
        controller.delegate = delegate
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func textDidChange(_ sender: UITextField) {
        
        if sender == emailTextField {
            viewModel.email = sender.text
        } else {
            viewModel.password = sender.text
        }
        
        updateForm()
    }
    
    // MARK: - Helpers
    
    func configureUI() {
        navigationController?.navigationBar.isHidden = true
        navigationController?.navigationBar.barStyle = .black
        
        configureGradientBackground()
        
        view.addSubview(iconImage)
        iconImage.centerX(inView: view)
        iconImage.setDimensions(height: 120, width: 120)
        iconImage.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 32)
        
        let stack = UIStackView(arrangedSubviews: [emailTextField,
                                                   passwordTextField,
                                                   loginButton])
        stack.axis = .vertical
        stack.spacing = 20
        
        view.addSubview(stack)
        stack.anchor(top: iconImage.bottomAnchor, left: view.leftAnchor,
                     right: view.rightAnchor, paddingTop: 32, paddingLeft: 32, paddingRight: 32)
        
        let secondStack = UIStackView(arrangedSubviews: [forgotPasswordButton,
                                                         dividerView,
                                                         googleLoginButton])
        secondStack.axis = .vertical
        secondStack.spacing = 28
        
        view.addSubview(secondStack)
        secondStack.anchor(top: stack.bottomAnchor, left: view.leftAnchor,
                           right: view.rightAnchor, paddingTop: 24, paddingLeft: 32,
                           paddingRight: 32)
        
        view.addSubview(dontHaveAccountButton)
        dontHaveAccountButton.centerX(inView: view)
        dontHaveAccountButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor)
    }
    
    func configureNotificationObservers() {
        emailTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
    }
    
    func configureGoogleSignIn() {
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance()?.delegate = self
        
    }
}

//MARK: - FormViewModel

extension LoginController: FormViewModel {
    func updateForm() {
        loginButton.isEnabled = viewModel.shouldEnableButton
        loginButton.backgroundColor = viewModel.buttonBackgroundColor
        loginButton.setTitleColor(viewModel.buttonTitleColor, for: .normal)
    }
}

//MARK: - GIDSignInDelegate

extension LoginController: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
        self.showLoader(false)

        if let error = error {
            print("DEBUG: didSignInFor: \(error.localizedDescription)")
            return
        }
        
        Service.signInWithGoogle(didSignFor: user) { error in
            if let error = error {
                print("DEBUG: didSignInFor: \(error.localizedDescription)")
                return
            }
            print("DEBUG: Successfully signed in with google...")
            self.delegate?.authenticationComplete()
        }
    }
}

//MARK: - ResetPasswordControllerDelegate

extension LoginController: ResetPasswordControllerDelegate {
    func didSendResetPassword() {
        navigationController?.popViewController(animated: true)
        self.showMessage(withTitle: "Success", message: MSG_RESET_PASSWORD_LINK_SENT)
    }
}
