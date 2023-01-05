import Foundation

public struct PiNetworking {
    public static let shared = NetworkService()
    
    private let urlSession = URLSession.shared
    private let jsonDecoder = JSONDecoder()
    
    public init() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        jsonDecoder.dateDecodingStrategy = .formatted(dateFormatter)
    }
    
    public func sendRequest<T: Decodable>(endpoint: Endpoint,
                                   params: [String: Any],
                                   responseType: T.Type?) async -> Result<T, APIError>  {
        guard let request = urlRequest(for: endpoint, params: params) else {
            return .failure(.urlError)
        }
        
        do {
            let (data, _) = try await urlSession.data(for: request)
            
            if let decodedResponse = try? jsonDecoder.decode(T.self, from: data) {
                return .success(decodedResponse)
            } else if let error = try? jsonDecoder.decode(ErrorResponse.self, from: data) {
                return .failure(.known(error))
            } else {
                return .failure(.decoding)
            }
        } catch {
            return .failure(.unknown)
        }
    }
    
    public func sendRequest(endpoint: Endpoint, params: [String: Any] = [:]) async -> Result<Void, APIError>  {
        guard let request = urlRequest(for: endpoint, params: params) else {
            return .failure(.urlError)
        }
        
        do {
            let (data, _) = try await urlSession.data(for: request)
            
            if let error = try? jsonDecoder.decode(ErrorResponse.self, from: data) {
                print(error.error.message)
                return .failure(.known(error))
            } else {
                return .success(())
            }
        } catch {
            print(error.localizedDescription)
            return .failure(.unknown)
        }
    }
    
    func url(host: String, _ url: String) -> URL {
        return URL(string: "\(host)\(url)")!
    }
    
    func urlRequest(for endpoint: Endpoint, params: [String: Any] = [:]) -> URLRequest? {
        var urlComponents = URLComponents()
        urlComponents.scheme = endpoint.scheme
        urlComponents.host = endpoint.host
        urlComponents.path = endpoint.url
        
        guard let url = urlComponents.url else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.allHTTPHeaderFields = endpoint.headers
        
        if !params.isEmpty {
            request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])
        }
        return request
    }
}
