import YandexMobileMetrica

final class AnalyticService {
    
    static let shared = AnalyticService()
    
    private let apiKey = "0fa15d7a-eed2-43b4-8b20-cf65f47eea38"
    
    private init() {}
    
    func activate() {
        guard let configuration = YMMYandexMetricaConfiguration(apiKey: apiKey) else {
            return
        }
        YMMYandexMetrica.activate(with: configuration)
    }
    
    func report(event name: String, with parameters: Dictionary<AnyHashable, Any>) {
        YMMYandexMetrica.reportEvent(name, parameters: parameters) { error in
            print("Failed to report event \(name) with \(error)")
        }
    }
}
