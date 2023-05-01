import UIKit

final class CreateEventViewController: UIViewController {
    
    private let nameField: CustomTextField = {
        let field = CustomTextField()
        
        field.placeholder = "Введите название трекера"
        field.font = .systemFont(ofSize: 17, weight: .regular)
        field.backgroundColor = .ypBackgroundDay
        
        field.layer.masksToBounds = true
        field.layer.cornerRadius = 16
        field.heightAnchor.constraint(equalToConstant: 75).isActive = true
        
        return field
    }()
    
    private let settingsTable: UITableView = {
        let table = UITableView(frame: .zero)
        
        table.register(SettingTableViewCell.self, forCellReuseIdentifier: SettingTableViewCell.identifier)
        table.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        table.isScrollEnabled = false
        
        table.layer.masksToBounds = true
        table.layer.cornerRadius = 16
        table.heightAnchor.constraint(equalToConstant: 75).isActive = true
        
        return table
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton(type: .custom)
        
        button.setTitle("Отменить", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.ypRed, for: .normal)
        
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 16
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.ypRed.cgColor
        
        button.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        return button
    }()
    
    private let createButton: UIButton = {
        let button = UIButton(type: .custom)
        
        button.setTitle("Создать", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .ypGray
        
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 16
        
        button.addTarget(self, action: #selector(create), for: .touchUpInside)
        return button
    }()
    
    private let settings: Array<SettingModel> = [
        SettingModel(name: "Категория")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        settingsTable.dataSource = self
        
        setupNavigationBar()
        makeCreateEventViewLayout()
    }
    
    @objc private func cancel() {
        dismiss(animated: true)
    }
    
    @objc private func create() {}
    
    private func setupNavigationBar() {
        let titleAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.ypBlackDay,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .medium)
        ]
        navigationController?.navigationBar.titleTextAttributes = titleAttributes
        navigationController?.navigationBar.topItem?.title = "Новое нерегулярное событие"
    }
    
    private func makeCreateEventViewLayout() {
        view.backgroundColor = .ypWhiteDay
        
        let footerStack = makeHorizontalStack()
        
        view.addSubview(nameField)
        view.addSubview(settingsTable)
        view.addSubview(footerStack)
        
        nameField.translatesAutoresizingMaskIntoConstraints = false
        settingsTable.translatesAutoresizingMaskIntoConstraints = false
        footerStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            nameField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            nameField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nameField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            settingsTable.topAnchor.constraint(equalTo: nameField.bottomAnchor, constant: 24),
            settingsTable.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            settingsTable.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            footerStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            footerStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            footerStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func makeHorizontalStack() -> UIStackView {
        let hStack = UIStackView()
        
        hStack.axis = .horizontal
        hStack.distribution = .fillEqually
        hStack.spacing = 10
        hStack.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        hStack.addArrangedSubview(cancelButton)
        hStack.addArrangedSubview(createButton)
        
        return hStack
    }
}

extension CreateEventViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let settingCell = tableView
            .dequeueReusableCell(withIdentifier: SettingTableViewCell.identifier, for: indexPath) as? SettingTableViewCell
        else {
            preconditionFailure("Failed to cast UITableViewCell as SettingTableViewCell")
        }
        settingCell.configure(model: settings[indexPath.row])
        
        if indexPath.row == settings.count - 1 { // hide separator for last cell
            let centerX = settingCell.bounds.width / 2
            settingCell.separatorInset = UIEdgeInsets(top: 0, left: centerX, bottom: 0, right: centerX)
        }
        return settingCell
    }
}
