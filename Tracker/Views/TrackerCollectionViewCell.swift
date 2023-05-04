import UIKit

final class TrackerCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "TrackerCollectionViewCell"
    
    private let canvasView: UIView = {
        let view = UIView()
        
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 16
        view.heightAnchor.constraint(equalToConstant: 90).isActive = true
        
        return view
    }()
    
    private let emojiView: UIView = {
        let view = UIView()
        view.backgroundColor = .ypBackgroundDay
        
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 12
        view.widthAnchor.constraint(equalToConstant: 24).isActive = true
        view.heightAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        
        return view
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        
        label.textColor = .ypWhiteDay
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.numberOfLines = 2
        
        return label
    }()
    
    private let counterLabel: UILabel = {
        let label = UILabel()
        
        label.textColor = .ypBlackDay
        label.font = .systemFont(ofSize: 12, weight: .medium)
        
        return label
    }()
    
    private let incrementButton: UIButton = {
        let button = UIButton(type: .custom)
        
        button.setImage(UIImage(named: "PlusButton")?.withTintColor(.ypWhiteDay), for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 17
        button.widthAnchor.constraint(equalToConstant: 34).isActive = true
        button.heightAnchor.constraint(equalTo: button.widthAnchor).isActive = true
        
        button.addTarget(self, action: #selector(incrementDayCounter), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeViewLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(model: TrackerModel) {
        nameLabel.text = model.name
        
        canvasView.backgroundColor = model.color
        incrementButton.backgroundColor = model.color
        
        let label = UILabel()
        label.text = model.emoji
        label.font = .systemFont(ofSize: 16, weight: .medium)
        
        emojiView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.centerXAnchor.constraint(equalTo: emojiView.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: emojiView.centerYAnchor).isActive = true
    }
    
    func setCounter(value: Int) {
        let remainder = value % 100
        
        if (11...14).contains(remainder) {
            counterLabel.text = "\(value) дней"
        } else {
            switch remainder % 10 {
            case 1:
                counterLabel.text = "\(value) день"
            case 2...4:
                counterLabel.text = "\(value) дня"
            default:
                counterLabel.text = "\(value) дней"
            }
        }
    }
    
    @objc private func incrementDayCounter() {}
    
    private func makeViewLayout() {
        contentView.addSubview(canvasView)
        contentView.addSubview(emojiView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(counterLabel)
        contentView.addSubview(incrementButton)
        
        canvasView.translatesAutoresizingMaskIntoConstraints = false
        emojiView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        counterLabel.translatesAutoresizingMaskIntoConstraints = false
        incrementButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            canvasView.topAnchor.constraint(equalTo: contentView.topAnchor),
            canvasView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            canvasView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            emojiView.topAnchor.constraint(equalTo: canvasView.topAnchor, constant: 12),
            emojiView.leadingAnchor.constraint(equalTo: canvasView.leadingAnchor, constant: 12),
            
            nameLabel.bottomAnchor.constraint(equalTo: canvasView.bottomAnchor, constant: -12),
            nameLabel.leadingAnchor.constraint(equalTo: canvasView.leadingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: canvasView.trailingAnchor, constant: -12),
            
            counterLabel.centerYAnchor.constraint(equalTo: incrementButton.centerYAnchor),
            counterLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            
            incrementButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            incrementButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12)
        ])
    }
}
