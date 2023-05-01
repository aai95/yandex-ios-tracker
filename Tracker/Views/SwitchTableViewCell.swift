import UIKit

final class SwitchTableViewCell: UITableViewCell {
    
    static let identifier = "SwitchTableViewCell"
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        
        label.textColor = .ypBlackDay
        label.font = .systemFont(ofSize: 17, weight: .regular)
        
        return label
    }()
    
    private let switcher: UISwitch = {
        let switcher = UISwitch()
        
        switcher.onTintColor = .ypBlue
        
        return switcher
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        makeSwitchTableViewCellLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(model: SettingModel) {
        nameLabel.text = model.name
    }
    
    private func makeSwitchTableViewCellLayout() {
        contentView.backgroundColor = .ypBackgroundDay
        contentView.heightAnchor.constraint(equalToConstant: 75).isActive = true
        
        contentView.addSubview(nameLabel)
        contentView.addSubview(switcher)
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        switcher.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            switcher.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            switcher.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }
}
