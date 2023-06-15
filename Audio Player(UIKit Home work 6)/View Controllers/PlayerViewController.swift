import UIKit
import AVFoundation



class PlayerViewController: UIViewController {
    
    var timer: Timer?
    
    // MARK: - Storied properties
    /*==============================================================================*/
    /*==============================================================================*/
    // Объект вью контроллера списка песен
    weak var songsListVC: SongsListViewController?
    
    // Песня для плеера
    weak var playingSong: Music?
    
    // MARK: Аудио плеер
    private var player = AVAudioPlayer()
    
    // MARK: UIImageView для изображения обложки песни
    private var uiImageViewForSongImage = UIImageView()
    
    // MARK: Метка с названием исполняемой песни
    private let nameLabel = UILabel()
    
    // MARK: Подложка для кнопок управления плеером
    let layerForPlayerButtons = UIView()
    
    // MARK: Кнопки управления плеером
    var playButoon     = UIButton()  // Кнопка "Play"/"Pause"
    var nextButton     = UIButton()  // Кнопка перехода к следующей песне
    var previousButton = UIButton()  // Кнопка перехода к предыдущей песне
    
    // Цвет кнопок управления плеером
    let colorForPlayerButtons = UIColor(red: 1, green: 1, blue: 1, alpha: 0.4)
    
    // MARK: Слайдеры управления
    // Слайдер управления громкостью
    private let volumeSlider = UISlider()
    
    // Слайдер управления интервалом проигрывателя
    private let durationSlider = UISlider()
    
    // MARK: Изображения
    
    // Изображение "Play" для кнопки "Play"/"Pause"
    private var playImage: UIImage? {
        UIImage(named: "play.png")?.scaleImage(targetWidth: 60,
                                               targetHeight: nil).withTintColor(self.colorForPlayerButtons)
    }
    
    // Изображение "Pause" для кнопки "Play"/"Pause"
    private var pauseImage: UIImage? {
        UIImage(named: "pause.png")?.scaleImage(targetWidth: 60,
                                                               targetHeight: nil).withTintColor(self.colorForPlayerButtons)
    }
    
    // MARK: Сегментный контроллер
    var favouriteSongsSegmentControl = UISegmentedControl()
    
    //MARK: Указатель по какому списку исполяются песни (все или избранные)
    var isFavouriteList = Bool()
    /*==============================================================================*/
    /*==============================================================================*/
    
    
    
    // MARK: - "viewDidLoad" method
    /*==============================================================================*/
    /*==============================================================================*/
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initializePlayer(player: self.player, music: playingSong)
        
        
        
        //MARK: Настройка корневого вью
        /*- - - - - - - - - - - - - - - - - - - - - - - - - - - -*/
        // Создание и инициализация объекта
        let imageViewForRoutView = UIImageView(frame: CGRect(x: 0,
                                                             y: 0,
                                                             width: self.view.bounds.width,
                                                             height: self.view.bounds.height))
        
        // Добавление изображения для заднего фона корневого вью
        imageViewForRoutView.image = UIImage(named: "wallpaperForPlayer.png")
        
        // Добавление объекта к родительскому вью
        self.view.addSubview(imageViewForRoutView)
        
        // Обрезка изображения по границам вью
        self.view.clipsToBounds = true
        /*- - - - - - - - - - - - - - - - - - - - - - - - - - - -*/
        
        
        
        //MARK: Настройка сегментного контроллера избранных песен
        /*- - - - - - - - - - - - - - - - - - - - - - - - - - - -*/
        // Добавление первого сегмента к сегментному контроллеру
        self.favouriteSongsSegmentControl.insertSegment(withTitle: "Все",
                                                        at: 0,
                                                        animated: false)
        // Добавление второго сегмента к сегментному контроллера
        self.favouriteSongsSegmentControl.insertSegment(withTitle: "Избранные",
                                                        at: 1,
                                                        animated: false)
        
        // Настройка цвета выбранного сегмента
        self.favouriteSongsSegmentControl.selectedSegmentTintColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.3)
        
        // Настройка цвета заднего фона сегментного контроллера
        self.favouriteSongsSegmentControl.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.05)
        
        // Установка начального выбора сегментного контроллера
        if self.isFavouriteList {
            self.favouriteSongsSegmentControl.selectedSegmentIndex = 1
        } else {
            self.favouriteSongsSegmentControl.selectedSegmentIndex = 0
        }
        
        // Добавление обработчика в/д пользователя с сегментным контроллером
        self.favouriteSongsSegmentControl.addTarget(self, action: #selector(changeTheSongsList(sender:)), for: .valueChanged)
        
        // Добавление сегментного контроллера к родительскому вью
        self.view.addSubview(self.favouriteSongsSegmentControl)
        
        self.favouriteSongsSegmentControl.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.favouriteSongsSegmentControl.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 10),
            self.favouriteSongsSegmentControl.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor)
        ])
        /*- - - - - - - - - - - - - - - - - - - - - - - - - - - -*/
        
        
        
        //MARK: Настройка UIImageView для обложки песни
        /*- - - - - - - - - - - - - - - - - - - - - - - - - - - -*/
        // Размер левого отступа для UIImageView
        let uiImageViewOfSongImageTraillingSpace: CGFloat = 50
        
        // Цвет для UIImageView
        self.uiImageViewForSongImage.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.1)
        
        // Добавление UIImageView к корневому вью
        self.view.addSubview(self.uiImageViewForSongImage)
        
        // Отсклюяение автоматических системных ограничений
        self.uiImageViewForSongImage.translatesAutoresizingMaskIntoConstraints = false
        
        // Установка ограничений
        NSLayoutConstraint.activate([
            self.uiImageViewForSongImage.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.uiImageViewForSongImage.leftAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor,
                                                               constant: uiImageViewOfSongImageTraillingSpace),
            self.uiImageViewForSongImage.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor,
                                                              constant: 80),
            self.uiImageViewForSongImage.heightAnchor.constraint(equalTo: self.uiImageViewForSongImage.widthAnchor,
                                                                 multiplier: 1)
        ])
        
        // Настройка изображения для обложки песни
        self.setSongImage()
        /*- - - - - - - - - - - - - - - - - - - - - - - - - - - -*/
        
        
        
        //MARK: Настройка метки с названием песни
        /*- - - - - - - - - - - - - - - - - - - - - - - - - - - -*/
        // Настройка шрифта
        self.nameLabel.font = .systemFont(ofSize: 17, weight: .regular)
        
        // Настройка цвета
        self.nameLabel.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5)
        
        // Настройка размещения текста внутри области метки
        self.nameLabel.textAlignment = .center
        self.nameLabel.numberOfLines = 2
        
        // Установка текстого значения
        self.setNameLabel()
        
        //Добавление метки к корневому вью
        self.view.addSubview(self.nameLabel)

        // Отключение автоматических системных ограничений
        self.nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Установка ограничений
        NSLayoutConstraint.activate([
            self.nameLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.nameLabel.leftAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor,
                                                 constant: 10),
            self.nameLabel.topAnchor.constraint(equalTo: self.uiImageViewForSongImage.bottomAnchor, constant: 10)
        ])
        /*- - - - - - - - - - - - - - - - - - - - - - - - - - - -*/
        
        
        
        //MARK: Настройка подложки кнопок управления плеером
        /*- - - - - - - - - - - - - - - - - - - - - - - - - - - -*/
        // Установка цвета фона подложки
        self.layerForPlayerButtons.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.05)
        
        // Значения размеров и позиционирования подложки
        let layerForPlayerButtonsTraillingSpace: CGFloat = 20    // Отступ от левого края подложки
        let layerForPlayerButtonsRadius        : CGFloat = 12.5  // Радиус закругления сопряжения сторон подложки
        let layerForPlayerButtonsHeight        : CGFloat = 80    // Высота подложки
        let layerForPlayerButtonsVerticalSpace : CGFloat = 500   // Отступ от верхнего края подложки
        
        //Установка радиуса закругления сопряжения сторон подложки
        self.layerForPlayerButtons.layer.cornerRadius = layerForPlayerButtonsRadius
        
        // Добавление подложки к корневому вью
        self.view.addSubview(self.layerForPlayerButtons)
        
        // Отключение автоматических системных ограничений
        self.layerForPlayerButtons.translatesAutoresizingMaskIntoConstraints = false
        
        // Установка ограничений
        NSLayoutConstraint.activate([
            self.layerForPlayerButtons.heightAnchor.constraint(equalToConstant: layerForPlayerButtonsHeight),
            self.layerForPlayerButtons.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor,
                                                            constant: layerForPlayerButtonsVerticalSpace),
            self.layerForPlayerButtons.leftAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor,
                                                             constant: layerForPlayerButtonsTraillingSpace),
            self.layerForPlayerButtons.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
        ])
        /*- - - - - - - - - - - - - - - - - - - - - - - - - - - -*/
        
        
        
        
        //MARK: Кнопка "Play"/"Pause"
        /*- - - - - - - - - - - - - - - - - - - - - - - - - - - -*/
        // Установка изображения к кнопке "Play"
        self.playButoon.setImage(playImage, for: .normal)
        
        // Добавление кнопки к корневому вью
        self.view.addSubview(self.playButoon)
        
        // Добавление обработчика нажатия на кнопку
        self.playButoon.addTarget(self, action: #selector(playOrPause(sender:)), for: .touchUpInside)
        
        // Отключение автоматических системных ограничений
        self.playButoon.translatesAutoresizingMaskIntoConstraints = false
        
        // Установка ограничений
        NSLayoutConstraint.activate([
            self.playButoon.centerXAnchor.constraint(equalTo: self.layerForPlayerButtons.centerXAnchor),
            self.playButoon.centerYAnchor.constraint(equalTo: self.layerForPlayerButtons.centerYAnchor)
        ])
        /*- - - - - - - - - - - - - - - - - - - - - - - - - - - -*/
        
        
        
        //MARK: Кнопка перехода к следующей песне
        /*- - - - - - - - - - - - - - - - - - - - - - - - - - - -*/
        // Установка изображения к кнопке "Play"
        self.nextButton.setImage(UIImage(named: "next.png")?.scaleImage(targetWidth: 40, targetHeight: nil).withTintColor(self.colorForPlayerButtons) , for: .normal)
        
        // Добавление кнопки к корневому вью
        self.view.addSubview(self.nextButton)
        
        // Добавление обработчика нажатия на кнопку
        self.nextButton.addTarget(self, action: #selector(goToOtherSong(sender:)), for: .touchUpInside)
        
        // Отключение автоматических системных ограничений
        self.nextButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Установка ограничений
        NSLayoutConstraint.activate([
            self.nextButton.centerYAnchor.constraint(equalTo: self.playButoon.centerYAnchor),
            self.nextButton.leftAnchor.constraint(equalTo: self.playButoon.rightAnchor, constant: 10)
        ])
        /*- - - - - - - - - - - - - - - - - - - - - - - - - - - -*/
        
        
        
        //MARK: Кнопка перехода к предыдущей песне
        /*- - - - - - - - - - - - - - - - - - - - - - - - - - - -*/
        // Установка изображения к кнопке "Play"
        self.previousButton.setImage(UIImage(named: "previous.png")?.scaleImage(targetWidth: 40, targetHeight: nil).withTintColor(self.colorForPlayerButtons) , for: .normal)
        
        // Добавление кнопки к корневому вью
        self.view.addSubview(self.previousButton)
        
        // Добавление обработчика нажатия на кнопку
        self.previousButton.addTarget(self, action: #selector(goToOtherSong(sender:)), for: .touchUpInside)
        
        // Отключение автоматических системных ограничений
        self.previousButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Установка ограничений
        NSLayoutConstraint.activate([
            self.previousButton.centerYAnchor.constraint(equalTo: self.playButoon.centerYAnchor),
            self.previousButton.rightAnchor.constraint(equalTo: self.playButoon.leftAnchor, constant: -10)
        ])
        /*- - - - - - - - - - - - - - - - - - - - - - - - - - - -*/
        
        
        
        //MARK: Слайдер управления громкостью
        /*- - - - - - - - - - - - - - - - - - - - - - - - - - - -*/
        // Настройка цвета слайдера
        self.volumeSlider.thumbTintColor = .darkGray
        self.volumeSlider.maximumTrackTintColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.1)
        self.volumeSlider.minimumTrackTintColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.4)
        
        // Настройка изображений для минимального и максимального значений слайдера
        self.volumeSlider.minimumValueImage = UIImage(systemName: "volume.slash.fill")
        self.volumeSlider.maximumValueImage = UIImage(systemName: "volume.3.fill")
        self.volumeSlider.tintColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.4)
        
        //Установка максимального и минимального значений
        self.volumeSlider.minimumValue = 0.0
        self.volumeSlider.maximumValue = 1.0
        
        // Установка текущего значения ползунка
        self.volumeSlider.value = 1.0
        
        self.volumeSlider.addTarget(self, action: #selector(changeVolume(sender:)), for: .valueChanged)
        
        // Добавление слайдера к корневому вью
        self.view.addSubview(self.volumeSlider)
        
        // Отключение автоматических ограничений
        self.volumeSlider.translatesAutoresizingMaskIntoConstraints = false
        
        //Установка ограничений
        NSLayoutConstraint.activate([
            self.volumeSlider.widthAnchor.constraint(equalToConstant: 280),
            self.volumeSlider.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.volumeSlider.topAnchor.constraint(equalTo: self.layerForPlayerButtons.bottomAnchor, constant: 10)
        ])
        /*- - - - - - - - - - - - - - - - - - - - - - - - - - - -*/
        
        
        
        //MARK: Слайдер управления позицией проигрывателя
        /*- - - - - - - - - - - - - - - - - - - - - - - - - - - -*/
        // Настройка цвета слайдера
        self.durationSlider.thumbTintColor = .darkGray
        self.durationSlider.maximumTrackTintColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.1)
        self.durationSlider.minimumTrackTintColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.4)
        
        // Установка максимального и минимального значений
        self.durationSlider.minimumValue = 0.0
        self.durationSlider.maximumValue = Float(self.player.duration)
        
        // Установка изображения ползунка
        self.durationSlider.setThumbImage(UIImage(systemName: "circle.fill"), for: .normal)
        self.durationSlider.setThumbImage(UIImage(systemName: "circle.fill"), for: .highlighted)
        self.durationSlider.tintColor = .darkGray
        
        // Установка текущего значения ползунка
        self.durationSlider.value = 0
        
         // Установка обработчика взаимодействия
        self.durationSlider.addTarget(self, action: #selector(rewideTheSong(sender:)), for: .valueChanged)
        
        // Добавление слайдера к корневому вью
        self.view.addSubview(self.durationSlider)
        
        // Отключение автоматических ограничений
        self.durationSlider.translatesAutoresizingMaskIntoConstraints = false
        
        //Установка ограничений
        NSLayoutConstraint.activate([
            self.durationSlider.widthAnchor.constraint(equalToConstant: 280),
            self.durationSlider.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.durationSlider.bottomAnchor.constraint(equalTo: self.layerForPlayerButtons.topAnchor, constant: -10)
        ])
        /*- - - - - - - - - - - - - - - - - - - - - - - - - - - -*/
        
        
        
        
    }
    /*==============================================================================*/
    /*==============================================================================*/
    
    
    
    // MARK: - метод "Play/Pause" - Обработчик нажатия на кнопку "Play/Pause"
    /*==============================================================================*/
    /*==============================================================================*/
    @objc func playOrPause(sender: UIButton) -> Void {
        if sender === self.playButoon {
            
            // Если плеер находится в состоянии "готов к проигрыванию", это значит, что в плеере отсутствует песня. Если это так, то его необходимо инициализировать, передав ему песню.
            if !player.prepareToPlay() {
                initializePlayer(player: self.player, music: playingSong)
            }
            
            if !player.isPlaying {
                player.play()
                
                // Запуск таймера
                if timer == nil {
                    timer = Timer.scheduledTimer(withTimeInterval: 0.1,  repeats: true, block: { timer in
                        if self.player.isPlaying {
                            self.durationSlider.value = Float(self.player.currentTime)
                        }
                    })
                }
                
                // Анимированное увеличение
                UIView.animate(withDuration: 1, animations: {
                    self.uiImageViewForSongImage.transform = .init(scaleX: 1.2, y: 1.2)
                    self.nameLabel.transform = .init(translationX: 0, y: 25)
                })
                self.playButoon.setImage(self.pauseImage, for: .normal)
            } else {
                player.pause()
                
                // Остановка и удаление таймера
                if timer != nil {
                    timer!.invalidate()
                    timer = nil
                }
                
                // Анимированное уменьшение
                UIView.animate(withDuration: 1, animations: {
                    self.uiImageViewForSongImage.transform = .identity
                    self.nameLabel.transform = .identity
                })
                self.playButoon.setImage(self.playImage, for: .normal)
            }
        }
    }
    /*==============================================================================*/
    /*==============================================================================*/
    
    
    
    // MARK: - метод для перехода к другой песне
    /*==============================================================================*/
    /*==============================================================================*/
    @objc func goToOtherSong(sender: UIButton) -> Void {
        if (self.songsListVC != nil) && (self.playingSong != nil) {
            switch self.isFavouriteList {
            case true:
                if let songsListVC = self.songsListVC {
                    goNextOrPrevious(musicList: songsListVC.sortedFavouriteMusicArray)
                }
            case false:
                if let songsListVC = self.songsListVC {
                    goNextOrPrevious(musicList: songsListVC.sortedAllMusicArray)
                }
            }
        }
        
        /*--------------BEGIN FUNCTION---------------*/
        func goNextOrPrevious(musicList: [Music]) -> Void {
            for i in 0..<musicList.count {
                if self.playingSong! == musicList[i] {
                    
                    /*- - - - - - - - - - - - - - - - - - - -*/
                    switch sender {
                        
                    case self.nextButton:
                        if musicList.count > (i + 1) {
                            self.playingSong = musicList[i + 1]
                        } else {
                            self.playingSong = musicList[0]
                        }
                        
                    case self.previousButton:
                        if (i - 1) >= 0 {
                            self.playingSong = musicList[i - 1]
                        } else {
                            self.playingSong = musicList.last!
                        }
                        
                    default:
                        return
                    }
                    /*- - - - - - - - - - - - - - - - - - - -*/
                    
                    if self.player.isPlaying {
                        self.initializePlayer(player: self.player, music: self.playingSong)
                        self.player.play()
                        self.player.volume = self.volumeSlider.value
                        self.setSongImage()
                        self.setNameLabel()
                        return
                    } else {
                        self.initializePlayer(player: self.player, music: self.playingSong)
                        self.setSongImage()
                        self.setNameLabel()
                        self.player.volume = self.volumeSlider.value
                        return
                    }
                }
            }
        }
        /*--------------END FUNCTION---------------*/
        
    }
    
    /*==============================================================================*/
    /*==============================================================================*/
    
    
    
    // MARK: - метод для инициализация аудио плеера с помощью URL-адреса песни
    /*==============================================================================*/
    /*==============================================================================*/
    func initializePlayer(player: AVAudioPlayer?, music: Music?) {
        if let music {
            if let musicUrl = music.musicUrl {
                do {
                    try self.player = AVAudioPlayer(contentsOf: musicUrl)
                } catch {
                    print("ERROR. Player does not can be strated")
                }
            }
        }
    }
    /*==============================================================================*/
    /*==============================================================================*/
    
    
    
    // MARK: - метод для установки обложки песни
    /*==============================================================================*/
    /*==============================================================================*/
    func setSongImage() {
        if let playingSong = self.playingSong {
            if let image = playingSong.albumImage {
                self.uiImageViewForSongImage.image = image
            }
        }
    }
    /*==============================================================================*/
    /*==============================================================================*/
    
    
    
    // MARK: - метод для изменения метки с названием песни.
    /*==============================================================================*/
    /*==============================================================================*/
    func setNameLabel() {
        if let playingSong = self.playingSong {
            let name: String = playingSong.fullName
            let minutes = Int(playingSong.duration) / 60
            let seconds = Int(playingSong.duration) % 60
            
            self.nameLabel.text = "\(name), \(minutes):\(seconds)"
        }
    }
    /*==============================================================================*/
    /*==============================================================================*/

    
    
    
    // MARK: - метод для регулировки громкости звука
    /*==============================================================================*/
    /*==============================================================================*/
    @objc func changeVolume(sender: UISlider) -> Void {
        if sender === self.volumeSlider {
            player.volume = self.volumeSlider.value
        }
    }
    /*==============================================================================*/
    /*==============================================================================*/
    
    
    
    // MARK: - метод перематывания песни
    /*==============================================================================*/
    /*==============================================================================*/
    @objc func rewideTheSong(sender: UISlider) {
        if sender === self.durationSlider {
            self.player.currentTime = TimeInterval(self.durationSlider.value)
        }
    }
    /*==============================================================================*/
    /*==============================================================================*/
    
    
    
    // MARK: - Метод смены списка песен (Все/Избранные)
    /*==============================================================================*/
    /*==============================================================================*/
    @objc func changeTheSongsList(sender: UISegmentedControl) {
        if sender === self.favouriteSongsSegmentControl {
            if self.favouriteSongsSegmentControl.selectedSegmentIndex == 0 {
                self.isFavouriteList = false
            } else {
                self.isFavouriteList = true
            }
        }
    }
    /*==============================================================================*/
    /*==============================================================================*/
    

    
}
