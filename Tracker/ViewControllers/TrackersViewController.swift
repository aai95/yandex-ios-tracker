import UIKit

final class TrackersViewController: UIViewController {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        
        label.text = "Трекеры"
        label.textColor = .ypBlackDay
        label.font = .systemFont(ofSize: 34, weight: .bold)
        
        return label
    }()
    
    private let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .compact
        
        return picker
    }()
    
    private let searchField: UISearchTextField = {
        let field = UISearchTextField()
        
        field.placeholder = "Поиск"
        field.heightAnchor.constraint(equalToConstant: 36).isActive = true
        
        return field
    }()
    
    private let placeholderImage: UIImageView = {
        let image = UIImageView(image: UIImage(named: "TrackersPlaceholder"))
        
        image.widthAnchor.constraint(equalToConstant: 80).isActive = true
        image.heightAnchor.constraint(equalTo: image.widthAnchor).isActive = true
        
        return image
    }()
    
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        
        label.text = "Что будем отслеживать?"
        label.textColor = .ypBlackDay
        label.font = .systemFont(ofSize: 12, weight: .medium)
        
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        makeTrackersViewLayout()
    }
    
    @objc private func addTracker() {}
    
    private func setupNavigationBar() {
        let addButton = UIBarButtonItem(
            image: UIImage(named: "AddTrackerButton"),
            style: .plain,
            target: self,
            action: #selector(addTracker)
        )
        navigationController?.navigationBar.topItem?.setLeftBarButton(addButton, animated: false)
        navigationController?.navigationBar.tintColor = .ypBlackDay
    }
    
    private func makeTrackersViewLayout() {
        view.backgroundColor = UIColor.ypWhiteDay
        
        let topStack = makeVerticalStack()
        
        view.addSubview(topStack)
        view.addSubview(placeholderImage)
        view.addSubview(placeholderLabel)
        
        topStack.translatesAutoresizingMaskIntoConstraints = false
        placeholderImage.translatesAutoresizingMaskIntoConstraints = false
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            topStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            topStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            topStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            placeholderImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderImage.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            
            placeholderLabel.centerXAnchor.constraint(equalTo: placeholderImage.centerXAnchor),
            placeholderLabel.topAnchor.constraint(equalTo: placeholderImage.bottomAnchor, constant: 8)
        ])
    }
    
    private func makeVerticalStack() -> UIStackView {
        let vStack = UIStackView()
        
        vStack.axis = .vertical
        vStack.spacing = 8
        
        vStack.addArrangedSubview(makeHorizontalStack())
        vStack.addArrangedSubview(searchField)
        
        return vStack
    }
    
    private func makeHorizontalStack() -> UIStackView {
        let hStack = UIStackView()
        
        hStack.axis = .horizontal
        hStack.distribution = .equalSpacing
        
        hStack.addArrangedSubview(titleLabel)
        hStack.addArrangedSubview(datePicker)
        
        return hStack
    }
}
