import Foundation

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
}

extension URLSession {
    func data(
        for request: URLRequest,
        completion: @escaping (Result<Data, Error>) -> Void) -> URLSessionTask {
            let fulfillCompletionOnTheMainThread: (Result<Data, Error>) -> Void = {result in
                DispatchQueue.main.async {
                    completion(result)
                }
            }
            
            let task = dataTask(with: request, completionHandler: { data, response, error in
                if let data = data, let response = response, let statusCode = (response as? HTTPURLResponse)?.statusCode {
                    if 200 ..< 300 ~= statusCode {
                        fulfillCompletionOnTheMainThread(.success(data))
                        print("Успешное получение данных сервера с кодом \(statusCode)")
                    } else {
                        fulfillCompletionOnTheMainThread(.failure(NetworkError.httpStatusCode(statusCode)))
                        print("Ошибка получение данных сервера с кодом \(statusCode)")
                    }
                } else if let error = error {
                    fulfillCompletionOnTheMainThread(.failure(NetworkError.urlRequestError(error)))
                    print("Ошибка получение url \(error)")
                } else {
                    fulfillCompletionOnTheMainThread(.failure(NetworkError.urlSessionError))
                    print("Ошибка получение url ")
                }
            })
            task.resume()
            return task
        }
    func objectTask<T: Decodable>(
        for request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let task = data(for: request) { (result: Result<Data, Error>) in
            switch result {
            case .success(let data):
                do {
                    let response = try decoder.decode(T.self, from: data)
                    DispatchQueue.main.async{
                        completion(.success(response))
                        print("декодирование прошло успешно ")
                    }
                }
                catch {
                    DispatchQueue.main.async{
                        completion(.failure(error))
                        print("Ошибка декодирования: \(error.localizedDescription), Данные: \(String(data: data, encoding: .utf8) ?? "")")
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async{
                    completion(.failure(error))
                    print("получение данных \(error.localizedDescription)")
                }
            }
        }
        return task
    }
}
