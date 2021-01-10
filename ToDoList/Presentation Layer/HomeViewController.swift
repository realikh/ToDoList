//
//  ViewController.swift
//  ToDoList
//
//  Created by Alikhan Khassen on 08.01.2021.
//

import SnapKit
import CoreData

final class HomeViewController: UIViewController {
    
    private var viewModel = HomeViewModel()

    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.tableFooterView = UIView()
        return tableView
    }()
    
    private let undoView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.backgroundColor = .darkGray
        return view
        
    }()
    
    private let undoButton: UIButton = {
        let button = UIButton()
        button.setTitle("Undo Delete", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.addTarget(self, action: #selector(undoButtonDidPress), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        layoutUI()
        viewModel.fetchToDos()
        bindViewModel()
        
    }
    
    private func bindViewModel() {
        viewModel.didFetchToDos = {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: Layout
    func layoutUI() {
        configureNavigationBar()
        configureTableView()
        configureUndoView()
        configureAppearance()
    }
    
    private func configureNavigationBar() {
        
        title = "Todos"
        let addBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addBarButtonItemDidPress))
        navigationItem.rightBarButtonItem = addBarButtonItem
    }
    
    private func configureTableView() {
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ToDoTableViewCell.self, forCellReuseIdentifier: String(describing: ToDoTableViewCell.self))
        
        view.addSubview(tableView)
        tableView.backgroundColor = view.backgroundColor
        tableView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    private func configureUndoView() {
        undoView.addSubview(undoButton)
        undoButton.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        view.addSubview(undoView)
        undoView.isHidden = true
        undoView.snp.makeConstraints {
            $0.width.equalToSuperview().offset(-40)
            $0.height.equalTo(44)
            $0.centerX.equalTo(view.snp.centerX)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
        }
    }
    
    private func configureAppearance() {
        view.backgroundColor = .black
        tableView.separatorColor = .gray
        navigationController!.navigationBar.barTintColor = .black
        navigationController!.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
    }
    
    // MARK: Helper
    private func formatDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        return dateFormatter.string(from: date)
    }
    
    private func animateUndoView() {
        DispatchQueue.main.async {
            self.undoView.isHidden = false
            self.undoView.alpha = 1
            UIView.animate(withDuration: 0.3, delay: 3, options: .allowUserInteraction) {
                self.undoView.alpha = 0.1
            } completion: { (completed) in
                if completed {
                    self.undoView.isHidden = true
                }
            }
        }
    }
    
    // MARK: User Interaction
    @objc private func addBarButtonItemDidPress() {
        let addToDoViewController = AddEditToDoViewController()
        addToDoViewController.viewModel = viewModel
        present(addToDoViewController, animated: true, completion: nil)
    }
    
    @objc private func undoButtonDidPress() {
        viewModel.toDoService.undoRemove()
        viewModel.fetchToDos()
        undoView.isHidden = true
    }
}

// MARK: TableViewDataSource
extension HomeViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.dataToDisplay.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.dataToDisplay[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let toDo = viewModel.dataToDisplay[indexPath.section][indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ToDoTableViewCell.self)) as? ToDoTableViewCell
        cell?.toDo = toDo
        
        return cell!
    }
}

//MARK: TableViewDelegate
extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let editToDoViewController = AddEditToDoViewController()
        let toDo = viewModel.dataToDisplay[indexPath.section][indexPath.row]
        
        editToDoViewController.toDo = toDo
        editToDoViewController.viewModel = viewModel
        
        tableView.deselectRow(at: indexPath, animated: true)
        navigationController?.pushViewController(editToDoViewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let toDo = self.viewModel.dataToDisplay[indexPath.section][indexPath.row]
        
        var title: String {
            if toDo.isCompleted {
                return "Mark as incomplete"
            }
            return "Mark as completed"
        }
        
        let action = UIContextualAction(style: .normal, title: title) {_,_,_ in
            self.viewModel.toDoService.toggleIsCompleted(toDo: toDo)
            self.viewModel.fetchToDos()
        }
        
        action.backgroundColor = .systemBlue
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let action = UIContextualAction(style: .destructive, title: "Delete") {_,_,_ in
            
            let toDo = self.viewModel.dataToDisplay[indexPath.section][indexPath.row]
            self.viewModel.toDoService.removeToDo(toDo: toDo)
            self.viewModel.fetchToDos()
            self.animateUndoView()
        }
        
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if !viewModel.dataToDisplay[section].isEmpty {
            
            var headerTitle: String {
                switch section {
                case 0:
                    return "Current"
                case 1:
                    return "Completed"
                default:
                    return "??"
                }
            }
            
            let headerView: UIView = {
                let view = UIView()
                view.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.1)
                return view
            }()
            
            let headerTitleLabel: UILabel = {
                let label = UILabel()
                label.text = headerTitle
                label.textColor = .white
                label.font = .boldSystemFont(ofSize: 15)
                return label
            }()
            
            headerView.addSubview(headerTitleLabel)

            headerTitleLabel.snp.makeConstraints {
                $0.left.equalToSuperview().offset(15)
                $0.top.equalToSuperview().offset(10)
                $0.right.equalToSuperview()
                $0.bottom.equalToSuperview().offset(-10)
            }
            return headerView
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if !viewModel.dataToDisplay[section].isEmpty {
            return 35
        }
        return 0
    }
}
