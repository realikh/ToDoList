//
//  AddEditToDoViewController.swift
//  ToDoList
//
//  Created by Alikhan Khassen on 08.01.2021.
//

import SnapKit

class AddEditToDoViewController: UIViewController {
    
    var toDo: ToDo? {
        didSet {
            titleTextField.text = toDo?.title
            dueDateDatePicker.date = toDo?.dueDate ?? Date()
            detailTextView.text = toDo?.detail
            isCompletedSwitch.isOn = toDo?.isCompleted ?? false
        }
    }
    
    var viewModel: HomeViewModel?
    
    private let containerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 15
        return stackView
    }()
    
    private let titleStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        return stackView
    }()
    
    private let dueDateStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        return stackView
    }()
    
    private let isCompletedStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        return stackView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.text = "Title"
        return label
    }()
    
    private let isCompletedLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.text = "Completed"
        return label
    }()
    
    private let dueDateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.text = "Due Date"
        return label
    }()
    
    private let titleTextField: UITextField = {
        let textField = UITextField()
        textField.textColor = .white
        textField.attributedPlaceholder = NSAttributedString(string: "ToDo Title", attributes: [NSAttributedString.Key.foregroundColor : UIColor.gray])
        return textField
    }()
    
    let dueDateDatePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .compact
//        datePicker.backgroundColor = .green
        return datePicker
    }()
    
    let isCompletedSwitch: UISwitch = {
        let isCompletedSwitch = UISwitch()
        isCompletedSwitch.isOn = false
        return isCompletedSwitch
    }()
    
    let detailTextView: UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 17)
        return textView
    }()
    
    let saveButton: UIButton = {
        let button = UIButton()
        button.setTitle("Save", for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 8.0
        return button
    }()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        title = "ToDo"
        view.backgroundColor = .black
        configureContainerStackView()
        
    }
    
    private func configureContainerStackView() {
        
        configureTitleStackView()
        configureDueDateStackView()
        configureIsCompletedStackView()
        configureDetailTextView()
        configureSaveButton()
        
        view.addSubview(containerStackView)
        
        containerStackView.snp.makeConstraints {
            $0.left.equalToSuperview().offset(20)
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.right.equalToSuperview().offset(-20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-200)
        }
    }
    
    private func configureTitleStackView() {
        titleStackView.addArrangedSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.width.equalTo(100)
        }
        titleStackView.addArrangedSubview(titleTextField)
        containerStackView.addArrangedSubview(titleStackView)
    }
    
    private func configureDueDateStackView() {
        dueDateStackView.addArrangedSubview(dueDateLabel)
        dueDateLabel.snp.makeConstraints {
            $0.width.equalTo(100)
        }
        dueDateStackView.addArrangedSubview(dueDateDatePicker)
        containerStackView.addArrangedSubview(dueDateStackView)
    }
    
    private func configureIsCompletedStackView() {
        isCompletedStackView.addArrangedSubview(isCompletedLabel)
        isCompletedStackView.addArrangedSubview(isCompletedSwitch)
        containerStackView.addArrangedSubview(isCompletedStackView)
    }
    
    private func configureDetailTextView() {
        detailTextView.textColor = .white
        detailTextView.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.1)
        detailTextView.layer.cornerRadius = 10
        containerStackView.addArrangedSubview(detailTextView)
    }
    
    private func configureSaveButton() {
        containerStackView.addArrangedSubview(saveButton)
        saveButton.addTarget(self, action: #selector(saveButtonDidPress), for: .touchUpInside)
    }
    
    @objc private func saveButtonDidPress() {
        guard let viewModel = viewModel else { return }
        if let _ = toDo {
            let title = titleTextField.text ?? ""
            let detail = detailTextView.text ?? ""
            let dueDate = dueDateDatePicker.date
            let isCompleted = isCompletedSwitch.isOn
            viewModel.toDoService.updateToDo(toDo: toDo!, title: title, detail: detail, dueDate: dueDate, isCompleted: isCompleted)
            navigationController?.popViewController(animated: true)
        } else {
            let title = titleTextField.text ?? ""
            let detail = detailTextView.text ?? ""
            let dueDate = dueDateDatePicker.date
            let isCompleted = isCompletedSwitch.isOn
            viewModel.toDoService.addToDo(with: title, detail: detail, dueDate: dueDate, isCompleted: isCompleted)
            dismiss(animated: true)
        }
        viewModel.fetchToDos()
    }
}
