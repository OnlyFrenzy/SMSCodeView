//
//  SMSCodeView.swift
//  SMSCodeTextField
//
//  Created by Nikita Bruy on 09.09.2021.
//

import UIKit

open class SMSCodeView: UIView {
    
    private weak var delegate: SMSCodeViewDelegate?
    
    private lazy var inputTextField: UITextField = {
        let textField = UITextField()
        textField.autocorrectionType = .no
        textField.keyboardType = self.keyboardType
        textField.delegate = self
        
        textField.addTarget(
            self,
            action: #selector(inputTextFieldValueChanged),
            for: .allEditingEvents
        )
        
        return textField
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.spacing = self.spacing
        return stackView
    }()
    
    private var viewsArray = [UIView]()
    
// MARK: - Properties
    private(set) var quantityOfViews = 0
    
    private(set) var spacing: CGFloat = 16
    private(set) var inputViewsBackgroundColor: UIColor? = .clear
    private(set) var cornerRadius: CGFloat = 0
    private(set) var borderWidth: CGFloat = 0
    private(set) var borderColor: UIColor? = .black
    private(set) var fillBorderColor: UIColor? = .black
    private(set) var errorBorderColor: UIColor? = .black
    private(set) var editingBorderColor: UIColor? = .black
    private(set) var labelsInInputViewsBackgroundColor: UIColor? = .clear
    private(set) var textColor: UIColor? = .black
    private(set) var textFont: UIFont? = .systemFont(ofSize: 40)
    private(set) var cursorColor: UIColor? = .black
    private(set) var keyboardType: UIKeyboardType = .numberPad
    private(set) var errorTextColor: UIColor? = .black
    
// MARK: - create
    public func create() {

        self.addSubview(self.inputTextField)

        self.viewsArray = self.createViews()
        self.viewsArray.forEach { self.stackView.addArrangedSubview($0) }
        
        self.addSubview(self.stackView)
        
        self.stackViewResizing()
    }
    
// MARK: - createViews
    private func createViews() -> [UIView] {
        
        let viewsWidthWithoutSpacing = self.stackView.frame.width - (self.spacing * CGFloat(self.quantityOfViews - 1))
        let viewWidth = viewsWidthWithoutSpacing / CGFloat(self.quantityOfViews)
        
        var viewsArray = [UIView]()
        if self.quantityOfViews < 1,
           viewWidth < 0 { return viewsArray}
         
        for viewNumber in 1...self.quantityOfViews {
            let view = UIView()
            view.frame.size.width = viewWidth
            view.tag = viewNumber
            view.isUserInteractionEnabled = true
            
            view.backgroundColor = self.inputViewsBackgroundColor
            
            view.layer.borderWidth = self.borderWidth
            view.layer.borderColor = self.borderColor?.cgColor
            view.layer.cornerRadius = self.cornerRadius
            
            view.addGestureRecognizer(
                UITapGestureRecognizer(
                    target: self,
                    action: #selector(viewDidTap)
                ))
            viewsArray.append(view)
        }
        
        return viewsArray
    }
    
// MARK: - inputTextFieldValueChanged
    @objc
    private func inputTextFieldValueChanged() {
        
        self.viewsArray.forEach { $0.subviews.forEach { $0.removeFromSuperview() } }
        
        if self.inputTextField.text?.count ?? 0 <= 0 {
            
            self.setCursorAnimation(onViewWithTag: (self.inputTextField.text?.count ?? 0) + 1,
                                    cursorPosition: .left)
            
            self.changeInputViewsBorderColorWhenClear()
            self.changeInputViewsBorderColorWhenFill()
            self.changeInputViewsBorderColorWhenEditing(isViewDidTap: false)
            
            self.delegate?.smsCodeValueChanged(value: self.inputTextField.text)
            
            return
        }
        
        for characterNumber in 1...(self.inputTextField.text?.count ?? 0) {
            let view = self.viewsArray[characterNumber - 1]
            
            let label = UILabel()
            label.backgroundColor = self.labelsInInputViewsBackgroundColor
            label.textAlignment = .center
            label.textColor = self.textColor
            label.font = self.textFont
            
            guard let inputTextFieldText = self.inputTextField.text else { return }
            
            let characterAtNumber = Array(inputTextFieldText)[characterNumber - 1]
            
            label.text = String(characterAtNumber)
            view.addSubview(label)
            
            self.labelResizing(label: label, toView: view)
        }
        
        self.setCursorAnimation(onViewWithTag: (self.cursorPosition() ?? 0) + 1,
                                cursorPosition: .left)
        
        self.changeInputViewsBorderColorWhenClear()
        self.changeInputViewsBorderColorWhenFill()
        self.changeInputViewsBorderColorWhenEditing(isViewDidTap: false)
        
        self.delegate?.smsCodeValueChanged(value: self.inputTextField.text)
    }
    
    @objc
    private func viewDidTap(_ sender: UITapGestureRecognizer) {
        
        guard let senderView = sender.view else { return }
        
        self.setCursor(onPosition: senderView.tag)
    }
   
// MARK: - setCursor
    private func setCursor(onPosition: Int) {
        
        self.inputTextField.becomeFirstResponder()
        
        if self.inputTextField.text?.isEmpty ?? true {
            
            let newPosition = self.inputTextField.beginningOfDocument
            self.inputTextField.selectedTextRange = self.inputTextField.textRange(from: newPosition, to: newPosition)
            
            self.setCursorAnimation(onViewWithTag: 1,
                                    cursorPosition: .left)
            
            return
        }
        
        if let newPosition = self.inputTextField.position(from: self.inputTextField.beginningOfDocument, offset: onPosition) {

            self.inputTextField.selectedTextRange = self.inputTextField.textRange(from: newPosition, to: newPosition)
            
            self.setCursorAnimation(onViewWithTag: onPosition,
                                    cursorPosition: .right)
            
            self.changeInputViewsBorderColorWhenClear()
            self.changeInputViewsBorderColorWhenFill()
            self.changeInputViewsBorderColorWhenEditing(isViewDidTap: true)
            
            return
        }
        
        let newPosition = self.inputTextField.endOfDocument
        self.inputTextField.selectedTextRange = self.inputTextField.textRange(from: newPosition, to: newPosition)
        
        self.setCursorAnimation(onViewWithTag: (self.cursorPosition() ?? 0) + 1,
                                cursorPosition: .left)
        
        self.changeInputViewsBorderColorWhenClear()
        self.changeInputViewsBorderColorWhenFill()
        self.changeInputViewsBorderColorWhenEditing(isViewDidTap: false)
    }
    
    private func cursorPosition() -> Int? {
        
        if let selectedRange = self.inputTextField.selectedTextRange {
            
            let beginningOfDocument = self.inputTextField.beginningOfDocument
            let cursorPosition = self.inputTextField.offset(from: beginningOfDocument, to: selectedRange.start)
            
            return cursorPosition
        }
        
        return nil
    }
    
    private func setCursorAnimation(onViewWithTag: Int?, cursorPosition: CursorPositionOnView) {
        
        self.viewsArray.forEach({ $0.subviews.forEach { view in
            if view is CursorView {
                view.removeFromSuperview()
            }
        } })
        
        let cursorView = CursorView()
        cursorView.setColor(self.cursorColor)
        
        guard let view = viewsArray.first(where: { $0.tag == onViewWithTag }) else { return }
        
        view.addSubview(cursorView)
        self.cursorViewResizing(cursorView: cursorView, toView: view, cursorPosition: cursorPosition)
        
        cursorView.isHidden = false
        cursorView.enableAnimation()
    }
   
//MARK: - resizing
    private func stackViewResizing() {

        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        
         NSLayoutConstraint.activate([
            self.stackView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
            self.stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0),
            self.stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
            self.stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0)
         ])
        
        self.stackView.autoresizesSubviews = true
     }
    
    private func labelResizing(label: UILabel, toView view: UIView) {
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            label.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0)
        ])
    }
    
    private func cursorViewResizing(cursorView: CursorView, toView view: UIView, cursorPosition: CursorPositionOnView) {
        
        cursorView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            cursorView.topAnchor.constraint(equalTo: view.topAnchor, constant: 10),
            cursorView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10),
            cursorView.widthAnchor.constraint(equalToConstant: 1)
        ])
        
        if cursorPosition == .left {
            
            NSLayoutConstraint.activate([
                cursorView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10)
            ])
        }
        
        if cursorPosition == .right {
            
            NSLayoutConstraint.activate([
                cursorView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10)
            ])
        }
    }
    
// MARK: - changeInputViewsBorderColorWhen
    private func changeInputViewsBorderColorWhenFill() {
        
        self.viewsArray.forEach { view in
            if view.tag <= (self.inputTextField.text?.count) ?? 0  {
                view.layer.borderColor = self.fillBorderColor?.cgColor
            }
        }
    }
    
    private func changeInputViewsBorderColorWhenClear() {
        
        self.viewsArray.forEach { $0.layer.borderColor = self.borderColor?.cgColor }
    }
    
    private func changeInputViewsBorderColorWhenEditing(isViewDidTap: Bool) {
        let selectedView = self.viewsArray.first { view in
            if isViewDidTap {
                return view.tag == self.cursorPosition()
            } else {
                return view.tag - 1 == self.cursorPosition()
            }
        }
        
        selectedView?.layer.borderColor = self.editingBorderColor?.cgColor
    }
    
//MARK: - setters
    @discardableResult
    public func setDelegate(_ delegate: SMSCodeViewDelegate) -> Self {
        self.delegate = delegate
        return self
    }
    
    @discardableResult
    public func setViewsCount(_ viewsCount: Int) -> Self {
        self.quantityOfViews = viewsCount
        return self
    }
    
    @discardableResult
    public func setSpacingBetweenViews(_ spacing: CGFloat) -> Self {
        self.spacing = spacing
        return self
    }
    
    @discardableResult
    public func setInputViewsBackgroundColor(_ backgroundColor: UIColor?) -> Self {
        self.inputViewsBackgroundColor = backgroundColor
        return self
    }
    
    @discardableResult
    public func setCornerRadius(_ cornerRadius: CGFloat) -> Self {
        self.cornerRadius = cornerRadius
        return self
    }
    
    @discardableResult
    public func setBorderWidth(_ borderWidth: CGFloat) -> Self {
        self.borderWidth = borderWidth
        return self
    }
    
    @discardableResult
    public func setBorderColor(_ borderColor: UIColor?) -> Self {
        self.borderColor = borderColor
        return self
    }
    
    @discardableResult
    public func setFillBorderColor(_ borderColor: UIColor?) -> Self {
        self.fillBorderColor = borderColor
        return self
    }
    
    @discardableResult
    public func setErrorBorderColor(_ borderColor: UIColor?) -> Self {
        self.errorBorderColor = borderColor
        return self
    }
    
    @discardableResult
    public func setEditingBorderColor(_ borderColor: UIColor?) -> Self {
        self.editingBorderColor = borderColor
        return self
    }
    
    @discardableResult
    public func setTextColor(_ textColor: UIColor?) -> Self {
        self.textColor = textColor
        return self
    }
    
    @discardableResult
    public func setErrorTextColor(_ textColor: UIColor?) -> Self {
        self.errorTextColor = textColor
        return self
    }
    
    @discardableResult
    public func setTextFont(_ textFont: UIFont?) -> Self {
        self.textFont = textFont
        return self
    }
    
    @discardableResult
    public func setCursorColor(_ cursorColor: UIColor?) -> Self {
        self.cursorColor = cursorColor
        return self
    }
    
    @discardableResult
    public  func setKeyboardType(_ keyboardType: UIKeyboardType) -> Self {
        self.keyboardType = keyboardType
        return self
    }
    
// MARK: - actions
    public func changeBorderColorToError() {
        self.viewsArray.forEach { $0.layer.borderColor = self.errorBorderColor?.cgColor }
    }
    
    public func changeTextColorToError() {
        self.viewsArray.forEach { $0.subviews.forEach { view in
            guard let label = view as? UILabel else { return }
            label.textColor = self.errorTextColor
        } }
    }
    
    public func changeInputViewsBackgroundColor(_ color: UIColor) {
        self.viewsArray.forEach { $0.backgroundColor = color }
    }
    
    public func changeTextColor(_ color: UIColor) {
        self.viewsArray.forEach { $0.subviews.forEach { view in
            guard let label = view as? UILabel else { return }
                label.textColor = color
        } }
    }
    
    public func endEditing() {
        self.inputTextField.resignFirstResponder()
        self.changeInputViewsBorderColorWhenClear()
        self.changeInputViewsBorderColorWhenFill()
    }
    
    public func changeTextValue(to text:String?) {
        self.inputTextField.text = text
        self.inputTextFieldValueChanged()
    }
}

// MARK: - UITextFieldDelegate
extension SMSCodeView: UITextFieldDelegate {
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if self.inputTextField.text?.count ?? 0 >= self.quantityOfViews {
            if range.length != 1 {
                return false
            }
        }
        
        return true
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        self.delegate?.smsCodeEndEditing(textField)
    }

    public func textFieldDidBeginEditing(_ textField: UITextField) {
        self.delegate?.smsCodeBeginEditing(textField)
    }
}
