import UIKit

final class ConfigureScheduleViewController: UIViewController {
    
    private let doneButton: UIButton = {
        let button = UIButton(type: .custom)
        
        button.setTitle("Готово", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .ypBlackDay
        
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 16
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        button.addTarget(self, action: #selector(done), for: .touchUpInside)
        return button
    }()
    
    private let settingsTable: UITableView = {
        let table = UITableView(frame: .zero)
        
        table.register(SwitchTableViewCell.self, forCellReuseIdentifier: SwitchTableViewCell.identifier)
        table.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        table.isScrollEnabled = false
        
        table.layer.masksToBounds = true
        table.layer.cornerRadius = 16
        table.heightAnchor.constraint(equalToConstant: 525).isActive = true
        
        return table
    }()
    
    private let settings: Array<SettingModel> = [
        SettingModel(name: "Понедельник"),
        SettingModel(name: "Вторник"),
        SettingModel(name: "Среда"),
        SettingModel(name: "Четверг"),
        SettingModel(name: "Пятница"),
        SettingModel(name: "Суббота"),
        SettingModel(name: "Воскресенье")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        settingsTable.dataSource = self
        
        setupNavigationBar()
        makeConfigureScheduleViewLayout()
    }
    
    @objc private func done() {
        dismiss(animated: true)
    }
    
    private func setupNavigationBar() {
        let titleAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.ypBlackDay,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .medium)
        ]
        navigationController?.navigationBar.titleTextAttributes = titleAttributes
        navigationController?.navigationBar.topItem?.title = "Расписание"
    }
    
    private func makeConfigureScheduleViewLayout() {
        view.backgroundColor = .ypWhiteDay
        
        view.addSubview(settingsTable)
        view.addSubview(doneButton)
        
        settingsTable.translatesAutoresizingMaskIntoConstraints = false
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            settingsTable.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            settingsTable.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            settingsTable.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
}

extension ConfigureScheduleViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let settingCell = tableView
            .dequeueReusableCell(withIdentifier: SwitchTableViewCell.identifier, for: indexPath) as? SwitchTableViewCell
        else {
            preconditionFailure("Failed to cast UITableViewCell as SwitchTableViewCell")
        }
        settingCell.configure(model: settings[indexPath.row])
        
        if indexPath.row == settings.count - 1 { // hide separator for last cell
            let centerX = settingCell.bounds.width / 2
            settingCell.separatorInset = UIEdgeInsets(top: 0, left: centerX, bottom: 0, right: centerX)
        }
        return settingCell
    }
}
