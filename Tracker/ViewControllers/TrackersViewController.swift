import UIKit

final class TrackersViewController: UIViewController {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        
        label.text = "Трекеры"
        label.textColor = .ypBlackDay
        label.font = .systemFont(ofSize: 34, weight: .bold)
        
        return label
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .compact
        picker.addTarget(self, action: #selector(didChangeSelectedDate), for: .valueChanged)
        
        return picker
    }()
    
    private lazy var searchField: UISearchTextField = {
        let field = UISearchTextField()
        
        field.placeholder = "Поиск"
        field.heightAnchor.constraint(equalToConstant: 36).isActive = true
        field.addTarget(self, action: #selector(didChangeSearchText), for: .editingChanged)
        
        return field
    }()
    
    private let trackerCollection: UICollectionView = {
        let collection = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        
        collection.register(
            TrackerCollectionViewCell.self,
            forCellWithReuseIdentifier: TrackerCollectionViewCell.identifier
        )
        collection.register(
            CollectionViewHeader.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: CollectionViewHeader.identifier
        )
        return collection
    }()
    
    private let placeholderView = PlaceholderView()
    private let widthParameters = CollectionWidthParameters(cellsNumber: 2, leftInset: 16, rightInset: 16, interCellSpacing: 10)
    private let categoryStore = CategoryStore()
    private let trackerStore = TrackerStore()
    private let recordStore = RecordStore()
    
    private var categories: Array<CategoryModel> = []
    private var visibleCategories: Array<CategoryModel> = []
    private var completedRecords: Array<RecordModel> = []
    private var selectedDate = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        trackerCollection.dataSource = self
        trackerCollection.delegate = self
        
        trackerStore.delegate = self
        recordStore.delegate = self
        
        TestDataLoader.shared.loadTestData()
        
        setupNavigationBar()
        makeViewLayout()
        hideKeyboardWhenDidTap()
        
        categories = categoryStore.fetchedCategories
        completedRecords = recordStore.fetchedRecords
        visibleCategories.append(contentsOf: categories)
        
        didChangeSelectedDate()
    }
    
    private func isMatchRecord(model: RecordModel, with trackerID: UUID) -> Bool {
        return model.trackerID == trackerID && Calendar.current.isDate(model.completionDate, inSameDayAs: selectedDate)
    }
    
    @objc private func didTapAddButton() {
        let trackerController = AddTrackerViewController()
        trackerController.delegate = self
        present(UINavigationController(rootViewController: trackerController), animated: true)
    }
    
    private func setupNavigationBar() {
        let addButton = UIBarButtonItem(
            image: UIImage(named: "PlusButton"),
            style: .plain,
            target: self,
            action: #selector(didTapAddButton)
        )
        navigationController?.navigationBar.topItem?.setLeftBarButton(addButton, animated: false)
        navigationController?.navigationBar.tintColor = .ypBlackDay
    }
    
    private func makeViewLayout() {
        view.backgroundColor = .ypWhiteDay
        
        let headerStack = makeHeaderStack()
        
        view.addSubview(headerStack)
        view.addSubview(trackerCollection)
        view.addSubview(placeholderView)
        
        headerStack.translatesAutoresizingMaskIntoConstraints = false
        trackerCollection.translatesAutoresizingMaskIntoConstraints = false
        placeholderView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            headerStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            headerStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            trackerCollection.topAnchor.constraint(equalTo: headerStack.bottomAnchor, constant: 10),
            trackerCollection.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            trackerCollection.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            trackerCollection.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            placeholderView.topAnchor.constraint(equalTo: headerStack.bottomAnchor),
            placeholderView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            placeholderView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            placeholderView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
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
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.item]
        let isCompleted = completedRecords.contains { isMatchRecord(model: $0, with: tracker.id) }
        let completedDays = completedRecords.filter { $0.trackerID == tracker.id }.count
        
        trackerCell.delegate = self
        trackerCell.configure(model: tracker, at: indexPath, isCompleted: isCompleted, completedDays: completedDays)
        
        return trackerCell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView
            .dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: CollectionViewHeader.identifier, for: indexPath) as? CollectionViewHeader
        else {
            preconditionFailure("Failed to cast UICollectionReusableView as CollectionViewHeader")
        }
        header.configure(model: visibleCategories[indexPath.section])
        return header
    }
}

extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.bounds.width - widthParameters.widthInsets
        let cellWidth =  availableWidth / CGFloat(widthParameters.cellsNumber)
        return CGSize(width: cellWidth, height: 132)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 12, left: widthParameters.leftInset, bottom: 8, right: widthParameters.rightInset)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        let indexPath = IndexPath(row: 0, section: section)
        let headerView = self.collectionView(collectionView, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, at: indexPath)
        let targetSize = CGSize(width: collectionView.bounds.width, height: 42)
        
        return headerView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .required)
    }
}

extension TrackersViewController: TrackerCollectionViewCellDelegate {
    
    func completeTracker(with id: UUID, at indexPath: IndexPath) {
        guard selectedDate <= Date() else {
            return
        }
        try! recordStore.addRecord(model: RecordModel(trackerID: id, completionDate: selectedDate))
        trackerCollection.reloadItems(at: [indexPath])
    }
    
    func uncompleteTracker(with id: UUID, at indexPath: IndexPath) {
        try! recordStore.deleteRecord(model: completedRecords.filter( { isMatchRecord(model: $0, with: id) } )[0])
        trackerCollection.reloadItems(at: [indexPath])
    }
}

extension TrackersViewController: AddTrackerViewControllerDelegate {
    
    func didAddNewTracker(model: TrackerModel) {
        var model = model
        if model.schedule.isEmpty {
            model.date = selectedDate
        }
        try! trackerStore.addTracker(model: model, to: categories[0].title)
        didChangeSelectedDate()
        dismiss(animated: true)
    }
}

extension TrackersViewController: TrackerStoreDelegate {
    
    func storeDidChangeTrackers() {
        categories = categoryStore.fetchedCategories
    }
}

extension TrackersViewController: RecordStoreDelegate {
    
    func storeDidChangeRecords() {
        completedRecords = recordStore.fetchedRecords
    }
}

private extension TrackersViewController {
    
    @objc func didChangeSelectedDate() {
        presentedViewController?.dismiss(animated: false)
        selectedDate = datePicker.date
        didChangeSearchText()
    }
    
    @objc func didChangeSearchText() {
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
        showAppropriatePlaceholder()
        trackerCollection.reloadData()
    }
    
    func updateVisibleTrackers() {
        visibleCategories = []
        
        for category in categories {
            var visibleTrackers: Array<TrackerModel> = []
            
            for tracker in category.trackers {
                if isVisibleHabit(model: tracker) || isVisibleEvent(model: tracker) {
                    visibleTrackers.append(tracker)
                }
            }
            if !visibleTrackers.isEmpty {
                visibleCategories.append(CategoryModel(title: category.title, trackers: visibleTrackers))
            }
        }
        showAppropriatePlaceholder()
        trackerCollection.reloadData()
    }
    
    func isVisibleHabit(model: TrackerModel) -> Bool {
        if let weekDay = WeekDay(rawValue: calculateWeekDayNumber(for: selectedDate)),
           model.schedule.contains(weekDay)
        {
            return true
        }
        return false
    }
    
    func isVisibleEvent(model: TrackerModel) -> Bool {
        if let date = model.date,
           Calendar.current.isDate(date, inSameDayAs: selectedDate)
        {
            return true
        }
        return false
    }
    
    func calculateWeekDayNumber(for date: Date) -> Int {
        let calendar = Calendar.current
        let weekDayNumber = calendar.component(.weekday, from: date) // first day of week is Sunday
        let daysInWeek = 7
        return (weekDayNumber - calendar.firstWeekday + daysInWeek) % daysInWeek + 1
    }
    
    func showAppropriatePlaceholder() {
        if categories.isEmpty {
            placeholderView.isHidden = false
            placeholderView.configure(
                image: UIImage(named: "TrackersPlaceholder"),
                caption: "Что будем отслеживать?"
            )
        } else if visibleCategories.isEmpty {
            placeholderView.isHidden = false
            placeholderView.configure(
                image: UIImage(named: "SearchPlaceholder"),
                caption: "Ничего не найдено"
            )
        } else {
            placeholderView.isHidden = true
        }
    }
}
