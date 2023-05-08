import UIKit

final class ConfigureScheduleViewController: UIViewController {
    
    private let switchTable: UITableView = {
        let table = UITableView(frame: .zero)
        
        table.register(SwitchTableViewCell.self, forCellReuseIdentifier: SwitchTableViewCell.identifier)
        table.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        table.isScrollEnabled = false
        
        table.layer.masksToBounds = true
        table.layer.cornerRadius = 16
        table.heightAnchor.constraint(equalToConstant: 525).isActive = true
        
        return table
    }()
    
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
    
    private let switches: Array<SwitchOptions> = [
        SwitchOptions(name: "Понедельник"),
        SwitchOptions(name: "Вторник"),
        SwitchOptions(name: "Среда"),
        SwitchOptions(name: "Четверг"),
        SwitchOptions(name: "Пятница"),
        SwitchOptions(name: "Суббота"),
        SwitchOptions(name: "Воскресенье")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switchTable.dataSource = self
        switchTable.delegate = self
        
        setupNavigationBar()
        makeViewLayout()
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
    
    private func makeViewLayout() {
        view.backgroundColor = .ypWhiteDay
        
        view.addSubview(switchTable)
        view.addSubview(doneButton)
        
        switchTable.translatesAutoresizingMaskIntoConstraints = false
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            switchTable.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            switchTable.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            switchTable.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
}

extension ConfigureScheduleViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return switches.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let switchCell = tableView
            .dequeueReusableCell(withIdentifier: SwitchTableViewCell.identifier, for: indexPath) as? SwitchTableViewCell
        else {
            preconditionFailure("Failed to cast UITableViewCell as SwitchTableViewCell")
        }
        switchCell.configure(options: switches[indexPath.row])
        
        if indexPath.row == switches.count - 1 { // hide separator for last cell
            let centerX = switchCell.bounds.width / 2
            switchCell.separatorInset = UIEdgeInsets(top: 0, left: centerX, bottom: 0, right: centerX)
        }
        return switchCell
    }
}

extension ConfigureScheduleViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
