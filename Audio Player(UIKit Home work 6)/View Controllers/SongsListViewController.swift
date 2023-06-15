import UIKit
import AVFoundation



class SongsListViewController: UIViewController {
    
    
    
    // MARK: - Объявление вложенного типа "SongUI"
    /*==============================================================================*/
    /*==============================================================================*/
    typealias SongUI = (wrapButton         : UIButton,     // Кнопка, по нажатию на которую открывается плеер
                        imageView          : UIImageView,  // imageView для установки икноки с изображением обложки песни
                        albumImage         : UIImage?,     // Изображение с обложкой песни
                        songNameLabel      : UILabel,      // Метка с полным названием песни (название песни и исполнитель)
                        songDurationLabel  : UILabel,      // Метка с продолжительностью проигрывания песни
                        favouriteMarkButton: UIButton)     // Кнопка "Добавить в избранное"
    /*==============================================================================*/
    /*==============================================================================*/
    
    
    
    // MARK: - Storied properties
    /*==============================================================================*/
    /*==============================================================================*/
    var musicDictionary: [Music: SongUI] = [:]                   // Словарь со всеми песнями. Ключ словаря - песня; значение словаря - графическое представление этой песни
    var favouriteSongsSegmentControl     = UISegmentedControl()  // Сегментный контроллер для переключения между отсортированным массивом всех песен и отсортированным массивом избранных песен. (Сортировка в обоих случаях произведена в алфавитном порядке)
    let searchTextField                  = UITextField()         // Текстовое поле для поиска песен либо в отсортированном массиве всех песен, либо в отсортированном массиве избранных песен
    var isFavouriteList                  = false                 // Если значение "false", то отображается список всех песен, а если значение "true", то отображается список только избранных песен
    /*==============================================================================*/
    /*==============================================================================*/
    
    
    
    // MARK: - Computed properties
    /*==============================================================================*/
    /*==============================================================================*/
    //Отсортированный массив всех песен (Сортировка в алфавитном порядке)
    var sortedAllMusicArray: [Music] {
        return getSorterMusicArray()
    }
    
    //Отсортированный массив только избранных песен (Сортировка в алфавитном порядке)
    var sortedFavouriteMusicArray: [Music] {
        return getSortedFavouriteMusicArray()
    }
    /*==============================================================================*/
    /*==============================================================================*/
    
    
    
    // MARK: - "viewDidLoad" method
    /*==============================================================================*/
    /*==============================================================================*/
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        //MARK: Настройка корневого вью
        /*- - - - - - - - - - - - - - - - - - - - - - - - - - - -*/
        // Создание и инициализация объекта
        let imageViewForRoutView = UIImageView(frame: CGRect(x: 0,
                                                             y: 0,
                                                             width: self.view.bounds.width,
                                                             height: self.view.bounds.height))
        
        // Добавление изображения для заднего фона корневого вью
        imageViewForRoutView.image = UIImage(named: "wallpaper.JPEG")
        
        // Добавление объекта к родительскому вью
        self.view.addSubview(imageViewForRoutView)
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
        self.favouriteSongsSegmentControl.selectedSegmentTintColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5)
        
        // Настройка цвета заднего фона сегментного контроллера
        self.favouriteSongsSegmentControl.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.1)
        
        // Установка начального выбора сегментного контроллера
        self.favouriteSongsSegmentControl.selectedSegmentIndex = 0
        
        // Добавление обработчика в/д пользователя с сегментным контроллером
        self.favouriteSongsSegmentControl.addTarget(self, action: #selector(showSongsList), for: .valueChanged)
        
        // Добавление сегментного контроллера к родительскому вью
        self.view.addSubview(self.favouriteSongsSegmentControl)
        
        self.favouriteSongsSegmentControl.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.favouriteSongsSegmentControl.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 50),
            self.favouriteSongsSegmentControl.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor)
        ])
        /*- - - - - - - - - - - - - - - - - - - - - - - - - - - -*/
        
        
        
        //MARK: Добавление текстового поля поиска
        /*- - - - - - - - - - - - - - - - - - - - - - - - - - - -*/
        
        // Настройка цвета заднего фона текстового поля
        self.searchTextField.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.1)
        
        // Настройка цвета текста
        self.searchTextField.textColor = .white
        
        // Настройка шрифта текста
        self.searchTextField.font = .systemFont(ofSize: 15, weight: .regular)
        
        // Настройка стиля текстового поля
        self.searchTextField.borderStyle = .roundedRect
        
        // Добавление текстового поля к корневому вью
        self.view.addSubview(self.searchTextField)
        
        // Отключение автоматических системных ограничений
        self.searchTextField.translatesAutoresizingMaskIntoConstraints = false
        
        // Установка ограничений
        NSLayoutConstraint.activate([
            self.searchTextField.topAnchor.constraint(equalTo: self.favouriteSongsSegmentControl.bottomAnchor, constant: 20),
            self.searchTextField.leftAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor, constant: 50),
            self.searchTextField.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor)
        ])
        
        // Добавление икнопки "Лупа" в качестве левого графического элемента текстового поля
        self.searchTextField.leftView = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        self.searchTextField.leftViewMode = .always
        self.searchTextField.leftView?.tintColor = .systemGray5
        
        // Добавление обработчика изменения значения текста в текстовом поле
        self.searchTextField.addTarget(self, action: #selector(showSongsList), for: .editingChanged)
        /*- - - - - - - - - - - - - - - - - - - - - - - - - - - -*/
        
        
        
        //MARK: Добавление песен
        /*- - - - - - - - - - - - - - - - - - - - - - - - - - - -*/
        // Инициализация песен
        let taylorSwiftShakeItOff = Music(fullName: "Taylor Swift - Shake It Off",
                                          albumImage: UIImage(named: "Taylor Swift - 1989.jpg"))
        
        let mikeShinodaFeatKaileeMorgueInMyHead = Music(fullName: "Mike Shinoda feat. Kailee Morgue - In My Head",
                                                        albumImage: UIImage(named: "Mike Shinoda - In My Head.png"))
        
        // Добавление песен в словарь со всеми песнями
        self.addMusiToTheDictionary(song: taylorSwiftShakeItOff)
        self.addMusiToTheDictionary(song: mikeShinodaFeatKaileeMorgueInMyHead)
        
        // Создание графического представления для отсортированного массива всех песен
        self.createSongsListUI(musicArray: self.sortedAllMusicArray)
        /*- - - - - - - - - - - - - - - - - - - - - - - - - - - -*/
        
    }
    /*==============================================================================*/
    /*==============================================================================*/
    
    
    
    // MARK: - Функция изменения статуса песни (добавлена с список избранных или нет)
    /*==============================================================================*/
    /*==============================================================================*/
    // Описание работы функции: Итерируется циклом "for" отсортированный массив всех песен для того, чтобы узнать, какая кнопка "Добавить в избранное" была нажата (точнее сказать, к какой песне относится нажатая кнопка). Внутри цикла "for" для каждой песни проверяется условие: существует ли такая песня в словаре со всеми песнями. Если да, то идём далее. А далее в каждой итерации сверяются кнопки песен с той кнопкой, которая была нажата пользователем. Как только кнопка находится, то состояние песни изменяется (если песня не была добавлена в избранное, то она добавлется, а если была добавлена, то удаляется из списка избранных песен), а также, изменяется изображение кнопки.
    
    @objc func makeSongTheOneOfTheFavourite(sender: UIButton) {
        for song in self.sortedAllMusicArray {
            if let songUI = self.musicDictionary[song] {
                if songUI.favouriteMarkButton === sender {
                    if song.isFavourite {
                        song.isFavourite = false
                        songUI.favouriteMarkButton.setImage(UIImage(systemName: "heart"), for: .normal)
                    }
                    else {
                        song.isFavourite = true
                        songUI.favouriteMarkButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
                    }
                    songUI.favouriteMarkButton.tintColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5)
                }
            }
        }
    }
    /*==============================================================================*/
    /*==============================================================================*/
    
    
    
    // MARK: - Функция сортировки словаря с песнями для получения массива с отсортированными песнями по алфавиту
    /*==============================================================================*/
    /*==============================================================================*/
    // Описание работы функции: Первым этапом создаётся массив "sortedArrayOfDictionaryElement", тип элементов которого равен типу элементов словаря песен, то есть тип элементов массива "sortedArrayOfDictionaryElement" - это пара "ключ - значение" словаря песен. В этом массиве все его элементы расположены в порядке возрастания строкого значения названия песни, являющейся ключом в каждом элементе массива. И так, "sortedArrayOfDictionaryElement" - это массив с элементами типа "Dictionary<Music, SongsListViewController.SongUI>.Element", в котором элементы высстроены в порядке возрастания строкового значения названия песни, соответствующей элементу. Далее из массива "sortedArrayOfDictionaryElement" создаётся массив "sortedMusicArray", состоящий только из песен, расположенных в установленном ранее порядке (в алфавитном порядке). В самом конце проверяется значение текстового поля поиска песни. Если текстовое поле пустое, то возвращается массив "sortedMusicArray". Если текстовое поле содержит строковое значение, то возвращается отфильтрованный массив на основе "sortedMusicArray", в котором название каждой песни должно содержать префикс, равный значению в текстовом поле поиска.
    
    private func getSorterMusicArray() -> [Music] {
        if let searchText = self.searchTextField.text {
            let sortedArrayOfDictionaryElement: [Dictionary<Music, SongsListViewController.SongUI>.Element] = musicDictionary.sorted { pair1, pair2 in
                let (firstMusic, _) = (pair1.key, pair1.value)
                let (secondMusic, _) = (pair2.key, pair2.value)
                return firstMusic.fullName.uppercased() < (secondMusic.fullName.uppercased())
            }
            let sortedMusicArray = sortedArrayOfDictionaryElement.map { (music: Music, musicUI: SongUI) in
                return music
            }
            if searchText.isEmpty {
                return sortedMusicArray
            } else {
                return sortedMusicArray.filter { music in
                    music.fullName.uppercased().contains(self.searchTextField.text!.uppercased())
                }
            }
        }
        return []
    }
    /*==============================================================================*/
    /*==============================================================================*/
    
    
    
    // MARK: - Функция сортировки словаря с песнями для получения массива избранных песен с отсортированными песнями по алфавиту
    /*==============================================================================*/
    /*==============================================================================*/
    // Описание работы функции: Эта функция практически полностю соответствует предыдущей функции (функция сортировки массива всех песен) за исключением последнего этапа. Последний этап: если текстовое поле поиска песни пустое, то возвращается массив на основе "sortedMusicArray", в котором каждая песня должна быть добавлена в избранное (isFavourite = true). Если текстовое поле содержит строковое значение, то возвращается отфильтрованный массив, созданный на основе "sortedMusicArray", в котором каждая песня должна быть добавлена в избранное, а также, название каждой песни должно содержать префикс, равный значению в текстовом поле поиска,
    
    private func getSortedFavouriteMusicArray() -> [Music] {
        if let searchText = self.searchTextField.text {
            let sortedArrayOfDictionaryElement: [Dictionary<Music, SongsListViewController.SongUI>.Element] = musicDictionary.sorted { pair1, pair2 in
                let (firstMusic, _) = (pair1.key, pair1.value)
                let (secondMusic, _) = (pair2.key, pair2.value)
                return firstMusic.fullName.uppercased() < (secondMusic.fullName.uppercased())
            }
            let sortedMusicArray = sortedArrayOfDictionaryElement.map { (music: Music, musicUI: SongUI) in
                return music
            }
            if searchText.isEmpty {
                return sortedMusicArray.filter { music in
                    music.isFavourite
                }
            } else {
                return sortedMusicArray.filter { music in
                    ( music.fullName.uppercased().contains(self.searchTextField.text!.uppercased()) ) && (music.isFavourite)
                }
            }
        }
        return []
    }
    /*==============================================================================*/
    /*==============================================================================*/
    
    
    
    // MARK: - Функция добавления песни в общий словарь со всеми песнями
    /*==============================================================================*/
    /*==============================================================================*/
    func addMusiToTheDictionary(song: Music) {
        let wrapButton             = UIButton()
        let imageView              = UIImageView()
        let albumImage: UIImage?   = song.albumImage
        let songNameLabel          = UILabel()
        let songDurationLabel      = UILabel()
        let favouriteMarkButton    = UIButton()
        
        self.musicDictionary[song] = (wrapButton: wrapButton,
                                      imageView: imageView,
                                      albumImage: albumImage,
                                      songNameLabel: songNameLabel,
                                      songDurationLabel: songDurationLabel,
                                      favouriteMarkButton: favouriteMarkButton)
    }
    /*==============================================================================*/
    /*==============================================================================*/

    
    
    // MARK: - Функция добавления графического представления песни на сцену
    /*==============================================================================*/
    /*==============================================================================*/
    func addMusicUIToScene(music: Music,
                           anchorOfBaseElement: NSLayoutAnchor<NSLayoutYAxisAnchor>,
                           verticalClearance: CGFloat) {
        if self.sortedAllMusicArray.contains(where: { musicInArray in
            musicInArray == music
        }) {
            
            //MARK: Постоянные значения размеров для настройки позиционирования элементов
            /*- - - - - - - - - - - - - - - - - - - - - - - - - - - -*/
            // Вертикальный зазор между графическими элементами
            let verticalClearance        : CGFloat = verticalClearance
            // Настройка размеров и позиционирования кнопки
            let buttonHeight             : CGFloat = 80
            let buttonTrailingSpace      : CGFloat = 30
            // Настройка размеров и позиционирования изображения
            let imageSize                : CGFloat = 70
            let imageTrailingSpace       : CGFloat = ( (buttonHeight - imageSize) / 2 )
            //Настройка размеров и позиционирования текста с названием песни
            let nameTextSize             : CGFloat = 15
            let nameTextTrailingSpace    : CGFloat = 10
            // Настройка размеров и позиционирования текста с длительностью песни
            let durationTextSize         : CGFloat = 15
            let durationTextTrailingSpace: CGFloat = nameTextTrailingSpace
            // Настройка размеров значка "Избранное"
            let favouriteMarkLeadingSpace: CGFloat = 5
            /*- - - - - - - - - - - - - - - - - - - - - - - - - - - -*/
            
            var musicUI: SongUI
            
            if self.musicDictionary[music] != nil {
                musicUI = self.musicDictionary[music]!
            } else {
                return
            }
            
            
            //MARK: Настройка кнопки перехода к сцене с плеером
            /*- - - - - - - - - - - - - - - - - - - - - - - - - - - -*/
            // Цвет фона кнопки
            musicUI.wrapButton.backgroundColor = .init(red: 1, green: 1, blue: 1, alpha: 0.05)
            
            // Радиус закругления сопряжения сторон прямоугольника кнопки
            musicUI.wrapButton.layer.cornerRadius = 12.5
            
            // добавление обработчика нажатия на кнопку
            musicUI.wrapButton.addTarget(self, action: #selector(goToPlayerViewController(sender:)), for: .touchUpInside)
            
            // Добавление кнопки на родительский вью
            self.view.addSubview(musicUI.wrapButton)
            
            // Отключение автоматических системных ограничений
            musicUI.wrapButton.translatesAutoresizingMaskIntoConstraints = false
            
            // Установка ограничений размера и позиционирования
            NSLayoutConstraint.activate([
                musicUI.wrapButton.topAnchor.constraint(equalTo: anchorOfBaseElement, constant: verticalClearance),
                musicUI.wrapButton.heightAnchor.constraint(equalToConstant: buttonHeight),
                musicUI.wrapButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                musicUI.wrapButton.leftAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor,
                                                         constant: buttonTrailingSpace)
            ])
            /*- - - - - - - - - - - - - - - - - - - - - - - - - - - -*/
            
            
            
            //MARK: Настройка UIImageView для изображения обложки песни
            /*- - - - - - - - - - - - - - - - - - - - - - - - - - - -*/
            // Настройка цвета фона подложки изображения
            musicUI.imageView.backgroundColor = .white
            
            // Добавление подложки изображения на кнопку
            self.view.addSubview(musicUI.imageView)
            
            musicUI.imageView.layer.cornerRadius = (12.5 - ( (buttonHeight - imageSize) / 2 ))
            musicUI.imageView.clipsToBounds = true
            
            // Отключение автоматических системных ограничений
            musicUI.imageView.translatesAutoresizingMaskIntoConstraints = false
            
            // Установка ограничений размера и позиционирования
            NSLayoutConstraint.activate([
                musicUI.imageView.heightAnchor.constraint(equalToConstant: imageSize),
                musicUI.imageView.widthAnchor.constraint(equalToConstant: imageSize),
                musicUI.imageView.centerYAnchor.constraint(equalTo: musicUI.wrapButton.centerYAnchor),
                musicUI.imageView.leftAnchor.constraint(equalTo: musicUI.wrapButton.leftAnchor,
                                                         constant: imageTrailingSpace)
            ])
            /*- - - - - - - - - - - - - - - - - - - - - - - - - - - -*/
            
            
            
            //MARK: Настройка изображения обложки песни
            /*- - - - - - - - - - - - - - - - - - - - - - - - - - - -*/
            if let image = music.albumImage {
                var scaledImage = UIImage()
                if image.size.width > image.size.height {
                    scaledImage = image.scaleImage(targetWidth: imageSize, targetHeight: nil)
                } else {
                    scaledImage = image.scaleImage(targetWidth: nil, targetHeight: imageSize)
                }
                musicUI.imageView.image = scaledImage
            }
            /*- - - - - - - - - - - - - - - - - - - - - - - - - - - -*/
            
            
            
            //MARK: Настройка метки с названием песни
            /*- - - - - - - - - - - - - - - - - - - - - - - - - - - -*/
            musicUI.songNameLabel.font = .systemFont(ofSize: nameTextSize, weight: .medium)
            musicUI.songNameLabel.textColor = .white
            musicUI.songNameLabel.text = music.fullName
            
            self.view.addSubview(musicUI.songNameLabel)
            
            // Отключение автоматических системных ограничений
            musicUI.songNameLabel.translatesAutoresizingMaskIntoConstraints = false
            
            // Установка ограничений размера и позиционирования
            NSLayoutConstraint.activate([
                musicUI.songNameLabel.bottomAnchor.constraint(equalTo: musicUI.imageView.centerYAnchor, constant: -5),
                musicUI.songNameLabel.leftAnchor.constraint(equalTo: musicUI.imageView.rightAnchor,
                                                         constant: nameTextTrailingSpace),
                musicUI.songNameLabel.rightAnchor.constraint(equalTo: musicUI.wrapButton.rightAnchor, constant: -nameTextTrailingSpace)
            ])
            /*- - - - - - - - - - - - - - - - - - - - - - - - - - - -*/
            
            
            
            //MARK: Настройка метки с длительностью песни
            /*- - - - - - - - - - - - - - - - - - - - - - - - - - - -*/
            musicUI.songDurationLabel.font = .systemFont(ofSize: durationTextSize, weight: .regular)
            musicUI.songDurationLabel.textColor = .white
            musicUI.songDurationLabel.text = "\(Int(music.duration) / 60):\((Int(music.duration) % 60))"
            musicUI.songDurationLabel.numberOfLines = 2
            
            self.view.addSubview(musicUI.songDurationLabel)
            
            // Отключение автоматических системных ограничений
            musicUI.songDurationLabel.translatesAutoresizingMaskIntoConstraints = false
            
            // Установка ограничений размера и позиционирования
            NSLayoutConstraint.activate([
                musicUI.songDurationLabel.topAnchor.constraint(equalTo: musicUI.imageView.centerYAnchor, constant: 5),
                musicUI.songDurationLabel.leftAnchor.constraint(equalTo: musicUI.imageView.rightAnchor,
                                                         constant: durationTextTrailingSpace)
            ])
            /*- - - - - - - - - - - - - - - - - - - - - - - - - - - -*/
            
            
            
            //MARK: Настройка кнопки "Добавить в избранное"
            /*- - - - - - - - - - - - - - - - - - - - - - - - - - - -*/
            if !music.isFavourite {
                musicUI.favouriteMarkButton.setImage(UIImage(systemName: "heart"), for: .normal)
            } else {
                musicUI.favouriteMarkButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            }
            musicUI.favouriteMarkButton.tintColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5)
            
            musicUI.favouriteMarkButton.addTarget(self, action: #selector(makeSongTheOneOfTheFavourite(sender:)), for: .touchUpInside)
            
            musicUI.wrapButton.addSubview(musicUI.favouriteMarkButton)
            
            musicUI.favouriteMarkButton.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                musicUI.favouriteMarkButton.centerYAnchor.constraint(equalTo: musicUI.songDurationLabel.centerYAnchor),
                musicUI.favouriteMarkButton.rightAnchor.constraint(equalTo: musicUI.wrapButton.rightAnchor,
                                                                   constant: -favouriteMarkLeadingSpace)
            ])
            /*- - - - - - - - - - - - - - - - - - - - - - - - - - - -*/
            
            
            
            //MARK: Вынос кнопки перехода на экран плеера на передний план
            /*- - - - - - - - - - - - - - - - - - - - - - - - - - - -*/
            
            self.view.bringSubviewToFront(musicUI.wrapButton)
            
            /*- - - - - - - - - - - - - - - - - - - - - - - - - - - -*/
            
        }
    }
    /*==============================================================================*/
    /*==============================================================================*/
    
    
    
    // MARK: - Функция, создающая графическое представление всех песен из отсортированного списка песен
    /*==============================================================================*/
    /*==============================================================================*/
    func createSongsListUI(musicArray: [Music]) -> Void {
        for i in 0..<musicArray.count {
            if i == 0 {
                self.addMusicUIToScene(music: musicArray[i],
                                anchorOfBaseElement: self.searchTextField.bottomAnchor,
                                verticalClearance: 30)
            } else {
                if musicDictionary.keys.contains(musicArray[i - 1]) {
                    self.addMusicUIToScene(music: musicArray[i],
                                    anchorOfBaseElement: musicDictionary[musicArray[i - 1]]!.wrapButton.bottomAnchor,
                                    verticalClearance: 10)
                }
            }
        }
    }
    /*==============================================================================*/
    /*==============================================================================*/
    
    
    
    // MARK: - Функция для показа графического отображения списка песен
    /*==============================================================================*/
    /*==============================================================================*/
    @objc func showSongsList() {
        for (_, ui) in self.musicDictionary {
            ui.imageView.removeFromSuperview()
            ui.songDurationLabel.removeFromSuperview()
            ui.songNameLabel.removeFromSuperview()
            ui.wrapButton.removeFromSuperview()
        }
        if self.favouriteSongsSegmentControl.selectedSegmentIndex == 0 {
            createSongsListUI(musicArray: self.sortedAllMusicArray)
        } else {
            createSongsListUI(musicArray: self.sortedFavouriteMusicArray)
        }
    }
    /*==============================================================================*/
    /*==============================================================================*/
    
    
    
    // MARK: - Функция для перехода к плееру
    /*==============================================================================*/
    /*==============================================================================*/
    @objc func goToPlayerViewController(sender: UIButton) {
        let mainStoryBoard = UIStoryboard(name: "Main", bundle: .main)
        for music in self.sortedAllMusicArray {
            if let musicUI = self.musicDictionary[music] {
                if musicUI.wrapButton === sender {
                    if let playerVC = mainStoryBoard.instantiateViewController(identifier: "PlayerViewController") as? PlayerViewController {
                        playerVC.songsListVC = self
                        playerVC.playingSong = music
                        if self.favouriteSongsSegmentControl.selectedSegmentIndex == 0 {
                            self.isFavouriteList = false
                        } else {
                            self.isFavouriteList = true
                        }
                        playerVC.isFavouriteList = self.isFavouriteList
                        self.present(playerVC, animated: true)
                    }
                }
            }
        }
    }
    /*==============================================================================*/
    /*==============================================================================*/
    
}
