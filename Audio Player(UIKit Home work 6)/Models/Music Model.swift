import UIKit
import AVFoundation



class Music {
    
    let fullName: String
    let albumImage: UIImage?
    
    var isFavourite: Bool = false
    
    var musicUrl: URL? {
        return getMusicUrl()
    }
    
    var duration: Double {
        if let musicUrl {
            do {
                var player = AVAudioPlayer()
                try player = AVAudioPlayer(contentsOf: musicUrl)
                return player.duration
            } catch { print("Error"); return 0.0 }
        }
        return 0.0
    }
    
    private func getMusicUrl() -> URL? {
        let mainBundle = Bundle.main
        if let musicPath = mainBundle.path(forResource: self.fullName, ofType: "mp3") {
            return URL(filePath: musicPath)
        }
        return nil
    }
    
    init(fullName: String, albumImage: UIImage? = nil) {
        self.fullName = fullName
        self.albumImage = albumImage
    }
}

extension Music: Equatable {
    static func == (lhs: Music, rhs: Music) -> Bool {
        (lhs.fullName == rhs.fullName) &&
        (lhs.duration == rhs.duration) &&
        (lhs.musicUrl == rhs.musicUrl)
    }
}

extension Music: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.fullName)
        hasher.combine(self.duration)
        hasher.combine(self.musicUrl)
    }
}
