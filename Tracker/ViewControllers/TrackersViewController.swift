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
        picker.addTarget(self, action: #selector(changeCurrentDate), for: .valueChanged)
        
        return picker
    }()
    
    private let searchField: UISearchTextField = {
        let field = UISearchTextField()
        
        field.placeholder = "Поиск"
        field.heightAnchor.constraint(equalToConstant: 36).isActive = true
        field.addTarget(self, action: #selector(changeSearchText), for: .editingChanged)
        
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
    
    private let trackerCollection: UICollectionView = {
        let collection = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        
        collection.register(
            TrackerCollectionViewCell.self,
            forCellWithReuseIdentifier: TrackerCollectionViewCell.identifier
        )
        collection.register(
            TrackerCollectionViewHeader.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: TrackerCollectionViewHeader.identifier
        )
        return collection
    }()
    
    private let widthParameters = CollectionWidthParameters(cellsNumber: 2, leftInset: 16, rightInset: 16, interCellSpacing: 10)
    
    private let emojis: Array<String> = [
        "🍇", "🍈", "🍉", "🍊", "🍋", "🍌", "🍍", "🥭", "🍎", "🍏",
        "🍐", "🍒", "🍓", "🫐", "🥝", "🍅", "🫒", "🥥", "🥑", "🍆",
        "🥔", "🥕", "🌽", "🌶️", "🫑", "🥒", "🥬", "🥦", "🧄", "🧅",
    ]
    
    private var categories: Array<CategoryModel> = [
        CategoryModel(
            title: "Тестовая категория",
            trackers: [
                TrackerModel(
                    id: UUID(),
                    name: "Тестовый трекер",
                    color: .ypSelection2,
                    emoji: "🍏",
                    schedule: [
                        .monday: true,
                        .tuesday: true,
                        .wednesday: true,
                        .thursday: true,
                        .friday: true,
                        .saturday: false,
                        .sunday: false
                    ]
                )
            ]
        )
    ]
    
    private var visibleCategories: Array<CategoryModel> = []
    
    private var currentDate = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        trackerCollection.dataSource = self
        trackerCollection.delegate = self
        
        visibleCategories.append(contentsOf: categories)
        
        setupNavigationBar()
        makeViewLayout()
    }
    
    @objc private func addTracker() {
        let createTrackerController = UINavigationController(rootViewController: CreateTrackerViewController())
        present(createTrackerController, animated: true)
    }
    
    private func setupNavigationBar() {
        let addButton = UIBarButtonItem(
            image: UIImage(named: "PlusButton"),
            style: .plain,
            target: self,
            action: #selector(addTracker)
        )
        navigationController?.navigationBar.topItem?.setLeftBarButton(addButton, animated: false)
        navigationController?.navigationBar.tintColor = .ypBlackDay
    }
    
    private func makeViewLayout() {
        view.backgroundColor = .ypWhiteDay
        
        let headerStack = makeHeaderStack()
        
        view.addSubview(headerStack)
        view.addSubview(trackerCollection)
        view.addSubview(placeholderImage)
        view.addSubview(placeholderLabel)
        
        headerStack.translatesAutoresizingMaskIntoConstraints = false
        trackerCollection.translatesAutoresizingMaskIntoConstraints = false
        placeholderImage.translatesAutoresizingMaskIntoConstraints = false
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            headerStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            headerStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            trackerCollection.topAnchor.constraint(equalTo: headerStack.bottomAnchor),
            trackerCollection.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            trackerCollection.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            trackerCollection.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            placeholderImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderImage.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            
            placeholderLabel.centerXAnchor.constraint(equalTo: placeholderImage.centerXAnchor),
            placeholderLabel.topAnchor.constraint(equalTo: placeholderImage.bottomAnchor, constant: 8)
        ])
        
        placeholderImage.isHidden = true
        placeholderLabel.isHidden = true
    }
    
    private func makeHeaderStack() -> UIStackView {
        let hStack = UIStackView()
        
        hStack.axis = .horizontal
        hStack.distribution = .equalSpacing
        
        hStack.addArrangedSubview(titleLabel)
        hStack.addArrangedSubview(datePicker)
        
        let vStack = UIStackView()
        
        vStack.axis = .vertical
        vStack.spacing = 8
        
        vStack.addArrangedSubview(hStack)
        vStack.addArrangedSubview(searchField)
        
        return vStack
    }
}

extension TrackersViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return visibleCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return visibleCategories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let trackerCell = collectionView
            .dequeueReusableCell(withReuseIdentifier: TrackerCollectionViewCell.identifier, for: indexPath) as? TrackerCollectionViewCell
        else {
            preconditionFailure("Failed to cast UICollectionViewCell as TrackerCollectionViewCell")
        }
        trackerCell.configure(model: visibleCategories[indexPath.section].trackers[indexPath.item])
        trackerCell.setCounter(value: 0)
        return trackerCell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let trackerHeader = collectionView
            .dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TrackerCollectionViewHeader.identifier, for: indexPath) as? TrackerCollectionViewHeader
        else {
            preconditionFailure("Failed to cast UICollectionReusableView as TrackerCollectionViewHeader")
        }
        trackerHeader.configure(model: visibleCategories[indexPath.section])
        return trackerHeader
    }
}

extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.bounds.width - widthParameters.widthInsets
        let cellWidth =  availableWidth / CGFloat(widthParameters.cellsNumber)
        return CGSize(width: cellWidth, height: 144)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: widthParameters.leftInset, bottom: 10, right: widthParameters.rightInset)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        let indexPath = IndexPath(row: 0, section: section)
        let headerView = self.collectionView(collectionView, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, at: indexPath)
        let targetSize = CGSize(width: collectionView.bounds.width, height: 50)
        
        return headerView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .required)
    }
}

private extension TrackersViewController {
    
    @objc func changeCurrentDate() {
        currentDate = datePicker.date
        changeSearchText()
    }
    
    @objc func changeSearchText() {
        updateVisibleTrackers()
        
        guard let searchText = searchField.text,
              !searchText.isEmpty
        else {
            return
        }
        var searchedCategories: Array<CategoryModel> = []
        
        for category in visibleCategories {
            var searchedTrackers: Array<TrackerModel> = []
            
            for tracker in category.trackers {
                if tracker.name.localizedCaseInsensitiveContains(searchText) {
                    searchedTrackers.append(tracker)
                }
            }
            if !searchedTrackers.isEmpty {
                searchedCategories.append(CategoryModel(title: category.title, trackers: searchedTrackers))
            }
        }
        visibleCategories = searchedCategories
        visibleCategories.isEmpty ? showPlaceholder() : hidePlaceholder()
        trackerCollection.reloadData()
    }
    
    func updateVisibleTrackers() {
        visibleCategories = []
        
        for category in categories {
            var visibleTrackers: Array<TrackerModel> = []
            
            for tracker in category.trackers {
                guard let weekDay = WeekDay(rawValue: calculateWeekDayNumber(for: currentDate)),
                      let isInSchedule = tracker.schedule[weekDay],
                      isInSchedule
                else {
                    continue
                }
                visibleTrackers.append(tracker)
            }
            if !visibleTrackers.isEmpty {
                visibleCategories.append(CategoryModel(title: category.title, trackers: visibleTrackers))
            }
        }
        visibleCategories.isEmpty ? showPlaceholder() : hidePlaceholder()
        trackerCollection.reloadData()
    }
    
    func calculateWeekDayNumber(for date: Date) -> Int {
        let calendar = Calendar.current
        let weekDayNumber = calendar.component(.weekday, from: date) // first day of week is Sunday
        let daysInWeek = 7
        return (weekDayNumber - calendar.firstWeekday + daysInWeek) % daysInWeek + 1
    }
    
    func showPlaceholder() {
        placeholderImage.isHidden = false
        placeholderLabel.isHidden = false
    }
    
    func hidePlaceholder() {
        placeholderImage.isHidden = true
        placeholderLabel.isHidden = true
    }
}
