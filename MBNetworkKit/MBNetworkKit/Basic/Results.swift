//
//  Copyright © 2019 MBition GmbH. All rights reserved.
//

/// Convenience type for results with no processable return value.
///
/// Should be used as completion return result for requests.
///
/// - failure: Contains a MBError
/// - success: Successful completion
@available(*, deprecated, message: "Will be removed in the future in favor of Swift.Result. Use Result<Void, MBError> instead. Kept for now for compatibility reasons with old UserService")
public enum EmptyResult {
    case failure(MBError)
    case success
    
    public var isSuccess: Bool {
        switch self {
        case .failure:    return false
        case .success:    return true
        }
    }
}

/// Convenience type for results with no processable return value and an additional case for a progress value.
///
/// Should be used as completion return result for requests.
///
/// - failure: Contains a ResponseError with a specific type
/// - progress: Progress value of the running task (e.g. download, upload, etc.)
/// - success: Successful completion
@available(*, deprecated, message: """
    Will be removed in the future in favor of Swift.Result. Progress updates will no longer be transferred via Result.
    Kept for now for compatibility reasons with old NetworkLayer and UserService
""")
public enum ProgressResult {
    case failure(MBError)
    case progress(Double)
    case success
    
    public var isSuccess: Bool {
        switch self {
        case .failure:    return false
        case .progress:   return false
        case .success:    return true
        }
    }
}
