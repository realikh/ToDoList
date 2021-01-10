//
//  ToDoTableViewCell.swift
//  ToDoList
//
//  Created by Alikhan Khassen on 08.01.2021.
//

import SnapKit

class ToDoTableViewCell: UITableViewCell {
    
    var toDo: ToDo? {
        didSet {
            configureCell()
        }
    }

    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 17)
        return label
    }()

    let detailLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 15)
        label.textColor = .darkGray
        return label
    }()
    
    let dueDateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 15)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        layoutCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func layoutCell() {
        self.backgroundColor = .clear
        configureTitleLabel()
        configureDetailLabel()
        configureDueDateLabel()
    }
    
    private func configureTitleLabel() {
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.left.equalToSuperview().offset(20)
            $0.top.equalToSuperview().offset(10)
        }
    }
    
    private func configureDetailLabel() {
        contentView.addSubview(detailLabel)
        detailLabel.snp.makeConstraints {
            $0.left.equalToSuperview().offset(20)
            $0.top.equalTo(titleLabel.snp.bottom).offset(10)
            $0.right.equalToSuperview().offset(-20)
            $0.bottom.equalToSuperview().offset(-10)
        }
    }
    
    private func configureDueDateLabel() {
        contentView.addSubview(dueDateLabel)
        dueDateLabel.textAlignment = .center
        dueDateLabel.layer.cornerRadius = 4.0
        dueDateLabel.layer.masksToBounds = true
        
        dueDateLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.right.equalToSuperview().offset(-20)
            $0.bottom.lessThanOrEqualToSuperview().offset(-10)
            $0.height.equalTo(30)
            $0.width.equalTo(85)
        }
        titleLabel.snp.makeConstraints {
            $0.right.lessThanOrEqualTo(dueDateLabel.snp.left).offset(-10)
        }
    }
    
    private func configureCell() {
        guard let toDo = toDo else { return }
        
        titleLabel.text = toDo.title
        detailLabel.text = toDo.detail
        let currentDate = Date()
        let distance = currentDate.distance(to: toDo.dueDate ?? Date())
        
        if !toDo.isCompleted &&  distance < 24*3600  {
            let hoursLeft = Int(distance/3600)
            let minutesLeft = Int(distance - Double(hoursLeft * 3600))/60
            if hoursLeft > 0 {
                dueDateLabel.text = "\(hoursLeft)h left"
                dueDateLabel.backgroundColor = .systemOrange
            } else if minutesLeft > 0 {
                dueDateLabel.text = "\(minutesLeft)m left"
                dueDateLabel.backgroundColor = .systemOrange
            } else {
                dueDateLabel.text = "Missing"
                dueDateLabel.backgroundColor = .red
            }
    
        } else if toDo.isCompleted {
            dueDateLabel.text = "Completed"
            dueDateLabel.backgroundColor = UIColor(red: 0.05, green: 0.7, blue: 0.05, alpha: 1)
        } else {
            dueDateLabel.text = formattedString(from: toDo.dueDate ?? Date())
            dueDateLabel.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1)
        }
    }
    
    private func formattedString(from date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        return dateFormatter.string(from: date)
    }
}
