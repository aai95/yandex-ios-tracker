import UIKit

protocol CreateHabitViewControllerDelegate: AnyObject {
    func didCreateNewHabit(model: TrackerModel)
    func didCancelNewHabit()
}

final class CreateHabitViewController: UIViewController {
    
    private lazy var nameField: CustomTextField = {
        let field = CustomTextField()
        
        field.placeholder = "Введите название трекера"
        field.font = .systemFont(ofSize: 17, weight: .regular)
        field.backgroundColor = .ypBackgroundDay
        
        field.layer.masksToBounds = true
        field.layer.cornerRadius = 16
        field.heightAnchor.constraint(equalToConstant: 75).isActive = true
        
        field.addTarget(self, action: #selector(setCreateButtonState), for: .editingChanged)
        return field
    }()
    
    private let settingTable: UITableView = {
        let table = UITableView(frame: .zero)
        
        table.register(SettingTableViewCell.self, forCellReuseIdentifier: SettingTableViewCell.identifier)
        table.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        table.isScrollEnabled = false
        
        table.layer.masksToBounds = true
        table.layer.cornerRadius = 16
        table.heightAnchor.constraint(equalToConstant: 150).isActive = true
        
        return table
    }()
    
    private let emojiColorCollection: UICollectionView = {
        let collection = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        
        collection.register(
            EmojiCollectionViewCell.self,
            forCellWithReuseIdentifier: EmojiCollectionViewCell.identifier
        )
        collection.register(
            ColorCollectionViewCell.self,
            forCellWithReuseIdentifier: ColorCollectionViewCell.identifier
        )
        collection.register(
            CollectionViewHeader.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: CollectionViewHeader.identifier
        )
        return collection
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .custom)
        
        button.setTitle("Отменить", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.ypRed, for: .normal)
        
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 16
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.ypRed.cgColor
        
        button.addTarget(self, action: #selector(didTapCancelButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var createButton: UIButton = {
        let button = UIButton(type: .custom)
        
        button.setTitle("Создать", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .ypGray
        button.isEnabled = false
        
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 16
        
        button.addTarget(self, action: #selector(didTapCreateButton), for: .touchUpInside)
        return button
    }()
    
    private let widthParameters = CollectionWidthParameters(cellsNumber: 6, leftInset: 20, rightInset: 20, interCellSpacing: 10)
    
    private let emojis: Array<String> = [
        "🙂", "😻", "🌺", "🐶", "❤️", "😱",
        "😇", "😡", "🥶", "🤔", "🙌", "🍔",
        "🥦", "🏓", "🥇", "🎸", "🏝", "😪"
    ]
    
    private let colors: Array<UIColor> = [
        .ypSelection1, .ypSelection2, .ypSelection3, .ypSelection4, .ypSelection5, .ypSelection6,
        .ypSelection7, .ypSelection8, .ypSelection9, .ypSelection10, .ypSelection11, .ypSelection12,
        .ypSelection13, .ypSelection14, .ypSelection15, .ypSelection16, .ypSelection17, .ypSelection18
    ]
    
    private var settings: Array<SettingOptions> = []
    private var configuredSchedule: Set<WeekDay> = []
    
    weak var delegate: CreateHabitViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        settingTable.dataSource = self
        settingTable.delegate = self
        
        emojiColorCollection.dataSource = self
        emojiColorCollection.delegate = self
        
        appendSettingsToList()
        setupNavigationBar()
        makeViewLayout()
        hideKeyboardWhenDidTap()
    }
    
    @objc private func setCreateButtonState() {
        guard let habitName = nameField.text else {
            return
        }
        if habitName.isEmpty || configuredSchedule.isEmpty {
            createButton.backgroundColor = .ypGray
            createButton.isEnabled = false
        } else {
            createButton.backgroundColor = .ypBlackDay
            createButton.isEnabled = true
        }
    }
    
    @objc private func didTapCancelButton() {
        delegate?.didCancelNewHabit()
    }
    
    @objc private func didTapCreateButton() {
        guard let habitName = nameField.text else {
            return
        }
        let tracker = TrackerModel(
            id: UUID(),
            name: habitName.trimmingCharacters(in: .whitespaces),
            color: colors[Int.random(in: 0..<colors.count)],
            emoji: emojis[Int.random(in: 0..<emojis.count)],
            schedule: configuredSchedule
        )
        delegate?.didCreateNewHabit(model: tracker)
    }
    
    private func appendSettingsToList() {
        settings.append(
            SettingOptions(
                name: "Категория",
                handler: { [weak self] in
                    guard let self = self else {
                        return
                    }
                    self.configureCategory()
                }
            )
        )
        settings.append(
            SettingOptions(
                name: "Расписание",
                handler: { [weak self] in
                    guard let self = self else {
                        return
                    }
                    self.configureSchedule()
                }
            )
        )
    }
    
    private func configureCategory() {}
    
    private func configureSchedule() {
        let configureScheduleController = ConfigureScheduleViewController()
        configureScheduleController.delegate = self
        present(UINavigationController(rootViewController: configureScheduleController), animated: true)
    }
    
    private func setupNavigationBar() {
        let titleAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.ypBlackDay,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .medium)
        ]
        navigationController?.navigationBar.titleTextAttributes = titleAttributes
        navigationController?.navigationBar.topItem?.title = "Новая привычка"
    }
    
    private func makeViewLayout() {
        view.backgroundColor = .ypWhiteDay
        
        let scrollView = UIScrollView()
        let mainStack = makeMainStack()
        
        view.addSubview(scrollView)
        scrollView.addSubview(mainStack)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            scrollView.contentLayoutGuide.topAnchor.constraint(equalTo: scrollView.topAnchor),
            scrollView.contentLayoutGuide.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            scrollView.contentLayoutGuide.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            
            mainStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 24),
            mainStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -16),
            mainStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            mainStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor)
        ])
        
        view.layoutIfNeeded()
        let contentHeight = emojiColorCollection.collectionViewLayout.collectionViewContentSize.height
        emojiColorCollection.heightAnchor.constraint(equalToConstant: contentHeight).isActive = true
    }
    
    private func makeMainStack() -> UIStackView {
        let mainStack = UIStackView()
        let buttonStack = makeButtonStack()
        
        mainStack.axis = .vertical
        mainStack.alignment = .center
        
        mainStack.addArrangedSubview(nameField)
        mainStack.addArrangedSubview(settingTable)
        mainStack.addArrangedSubview(emojiColorCollection)
        mainStack.addArrangedSubview(buttonStack)
        
        mainStack.setCustomSpacing(24, after: nameField)
        mainStack.setCustomSpacing(32, after: settingTable)
        
        NSLayoutConstraint.activate([
            nameField.leadingAnchor.constraint(equalTo: mainStack.leadingAnchor, constant: 16),
            nameField.trailingAnchor.constraint(equalTo: mainStack.trailingAnchor, constant: -16),
            
            settingTable.leadingAnchor.constraint(equalTo: mainStack.leadingAnchor, constant: 16),
            settingTable.trailingAnchor.constraint(equalTo: mainStack.trailingAnchor, constant: -16),
            
            emojiColorCollection.leadingAnchor.constraint(equalTo: mainStack.leadingAnchor),
            emojiColorCollection.trailingAnchor.constraint(equalTo: mainStack.trailingAnchor),
            
            buttonStack.leadingAnchor.constraint(equalTo: mainStack.leadingAnchor, constant: 20),
            buttonStack.trailingAnchor.constraint(equalTo: mainStack.trailingAnchor, constant: -20)
        ])
        return mainStack
    }
    
    private func makeButtonStack() -> UIStackView {
        let stack = UIStackView()
        
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 10
        stack.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        stack.addArrangedSubview(cancelButton)
        stack.addArrangedSubview(createButton)
        
        return stack
    }
}

extension CreateHabitViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let settingCell = tableView
            .dequeueReusableCell(withIdentifier: SettingTableViewCell.identifier, for: indexPath) as? SettingTableViewCell
        else {
            preconditionFailure("Failed to cast UITableViewCell as SettingTableViewCell")
        }
        settingCell.configure(options: settings[indexPath.row])
        
        if indexPath.row == settings.count - 1 { // hide separator for last cell
            let centerX = settingCell.bounds.width / 2
            settingCell.separatorInset = UIEdgeInsets(top: 0, left: centerX, bottom: 0, right: centerX)
        }
        return settingCell
    }
}

extension CreateHabitViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        settings[indexPath.row].handler()
    }
}

extension CreateHabitViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return emojis.count
        case 1:
            return colors.count
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {
        case 0:
            guard let emojiCell = collectionView
                .dequeueReusableCell(withReuseIdentifier: EmojiCollectionViewCell.identifier, for: indexPath) as? EmojiCollectionViewCell
            else {
                preconditionFailure("Failed to cast UICollectionViewCell as EmojiCollectionViewCell")
            }
            emojiCell.configure(emoji: emojis[indexPath.item])
            return emojiCell
        case 1:
            guard let colorCell = collectionView
                .dequeueReusableCell(withReuseIdentifier: ColorCollectionViewCell.identifier, for: indexPath) as? ColorCollectionViewCell
            else {
                preconditionFailure("Failed to cast UICollectionViewCell as ColorCollectionViewCell")
            }
            colorCell.configure(color: colors[indexPath.item])
            return colorCell
        default:
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView
            .dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: CollectionViewHeader.identifier, for: indexPath) as? CollectionViewHeader
        else {
            preconditionFailure("Failed to cast UICollectionReusableView as CollectionViewHeader")
        }
        switch indexPath.section {
        case 0:
            header.configure(title: "Emoji")
        case 1:
            header.configure(title: "Цвет")
        default:
            return UICollectionReusableView()
        }
        return header
    }
}

extension CreateHabitViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.bounds.width - widthParameters.widthInsets
        let cellWidth =  availableWidth / CGFloat(widthParameters.cellsNumber)
        return CGSize(width: cellWidth, height: 52)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 24, left: widthParameters.leftInset, bottom: 40, right: widthParameters.rightInset)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        let indexPath = IndexPath(row: 0, section: section)
        let headerView = self.collectionView(collectionView, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, at: indexPath)
        let targetSize = CGSize(width: collectionView.bounds.width, height: 18)
        
        return headerView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .required)
    }
}

extension CreateHabitViewController: ConfigureScheduleViewControllerDelegate {
    
    func didConfigure(schedule: Set<WeekDay>) {
        configuredSchedule = schedule
        setCreateButtonState()
        dismiss(animated: true)
    }
}
