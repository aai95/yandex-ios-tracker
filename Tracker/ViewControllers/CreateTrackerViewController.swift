import UIKit

final class CreateTrackerViewController: UIViewController {
    
    private let createHabitButton: UIButton = {
        let button = UIButton(type: .custom)
        
        button.setTitle("Привычка", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .ypBlackDay
        
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 16
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        button.addTarget(self, action: #selector(createHabitTracker), for: .touchUpInside)
        return button
    }()
    
    private let createEventButton: UIButton = {
        let button = UIButton(type: .custom)
        
        button.setTitle("Нерегулярное событие", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .ypBlackDay
        
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 16
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        button.addTarget(self, action: #selector(createEventTracker), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        makeCreateTrackerViewLayout()
    }
    
    @objc private func createHabitTracker() {}
    @objc private func createEventTracker() {}
    
    private func setupNavigationBar() {
        let titleAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.ypBlackDay,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .medium)
        ]
        navigationController?.navigationBar.titleTextAttributes = titleAttributes
        navigationController?.navigationBar.topItem?.title = "Создание трекера"
    }
    
    private func makeCreateTrackerViewLayout() {
        view.backgroundColor = .ypWhiteDay
        
        let buttonStack = makeVerticalStack()
        
        view.addSubview(buttonStack)
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            buttonStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            buttonStack.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func makeVerticalStack() -> UIStackView {
        let vStack = UIStackView()
        
        vStack.axis = .vertical
        vStack.spacing = 16
        
        vStack.addArrangedSubview(createHabitButton)
        vStack.addArrangedSubview(createEventButton)
        
        return vStack
    }
}
