//
//  VideoEditorMusicView.swift
//  HXPHPicker
//
//  Created by Slience on 2021/6/17.
//

import UIKit

protocol VideoEditorMusicViewDelegate: AnyObject {
    func musicView(_ musicView: VideoEditorMusicView, didSelectMusic audioPath: String?)
    func musicView(deselectMusic musicView: VideoEditorMusicView)
    func musicView(didSearchButton musicView: VideoEditorMusicView)
    func musicView(didVolumeButton musicView: VideoEditorMusicView)
    func musicView(_ musicView: VideoEditorMusicView, didOriginalSoundButtonClick isSelected: Bool)
    func musicView(_ musicView: VideoEditorMusicView, didShowLyricButton isSelected: Bool, music: VideoEditorMusic?)

    func loadMoreMusicView(_ musicView: VideoEditorMusicView,
                           completion: @escaping ([VideoEditorMusicInfo], Bool) -> Void)

    func discoverMusicView(_ musicView: VideoEditorMusicView,
                           completion: @escaping ([VideoEditorMusicInfo], Bool) -> Void)

    func favoritesMusicView(_ musicView: VideoEditorMusicView,
                            completion: @escaping ([VideoEditorMusicInfo], Bool) -> Void)
    
    func musicView(selectMusic music: VideoEditorMusic?)
}

public class VideoEditorMusicView: UIView {
    weak var videoEditor: VideoEditorViewController?
    weak var delegate: VideoEditorMusicViewDelegate?
    lazy var bgMaskLayer: CAGradientLayer = {
        let layer = PhotoTools.getGradientShadowLayer(false)
        return layer
    }()
    
    lazy var _searchBgView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hexString: "F6F7FB")
        view.layer.opacity = 0.2
        return view
    }()
    lazy var searchBgView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        view.addSubview(_searchBgView)
        view.addSubview(searchButton)
        return view
    }()
    lazy var searchButton: UIView = {
        let view = UIView()
        
        let label = UILabel()
        label.text = "Musik suchen …".localized
        label.textColor = UIColor(hexString: "E2E6F0")
        label.font = .mediumPingFang(ofSize: 14)
        
        let imageView = UIImageView(image: "hx_editor_video_music_search".image?.withRenderingMode(.alwaysTemplate))
        imageView.contentMode = .scaleAspectFit
        imageView.width = 20
        imageView.tintColor = UIColor(hexString: "E2E6F0")
        
        let stackView = UIStackView()
        stackView.addArrangedSubview(label)
        stackView.addArrangedSubview(imageView)
        stackView.spacing = 5
        
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(didSearchButtonClick), for: .touchUpInside)
        
        view.addSubview(stackView)
        view.addSubview(button)
                
        imageView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        button.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        
        button.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        button.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        button.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        button.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        imageView.widthAnchor.constraint(equalToConstant: 20).isActive = true
        imageView.heightAnchor.constraint(equalTo: stackView.heightAnchor).isActive = true
        
        return view
    }()
    @objc func didSearchButtonClick() {
        delegate?.musicView(didSearchButton: self)
    }
    lazy var volumeBgView: UIView = {
        let view = UIView()
        view.addSubview(volumeButton)
        return view
    }()
    lazy var volumeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage("hx_editor_video_music_volume".image?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.setTitle("音量".localized, for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -3, bottom: 0, right: 0)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 3, bottom: 0, right: 0)
        button.titleLabel?.font = .mediumPingFang(ofSize: 14)
        button.tintColor = .white
        button.imageView?.tintColor = .white
        button.addTarget(self, action: #selector(didVolumeButtonClick), for: .touchUpInside)
        return button
    }()
    @objc func didVolumeButtonClick() {
        delegate?.musicView(didVolumeButton: self)
    }
    lazy var flowLayout: UICollectionViewFlowLayout = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        return flowLayout
    }()
    
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: CGRect(x: 0, y: 0, width: 0, height: 50),
            collectionViewLayout: flowLayout
        )
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.decelerationRate = .fast
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        }
        collectionView.register(VideoEditorMusicViewCell.self, forCellWithReuseIdentifier: "VideoEditorMusicViewCellID")
        self.config.registerCells?(collectionView)
        return collectionView
    }()
    
    lazy var backgroundButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("配乐".localized, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.font = UIFont.mediumPingFang(ofSize: 16)
        button.setImage("hx_photo_box_normal".image, for: .normal)
        button.setImage("hx_photo_box_selected".image, for: .selected)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0)
        button.tintColor = .white
        button.addTarget(self, action: #selector(didButtonClick(button:)), for: .touchUpInside)
        button.isHidden = musics.isEmpty
        button.alpha = musics.isEmpty ? 0 : 1
        return button
    }()
    
    lazy var originalSoundButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("视频原声".localized, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.font = UIFont.mediumPingFang(ofSize: 16)
        button.setImage("hx_photo_box_normal".image, for: .normal)
        button.setImage("hx_photo_box_selected".image, for: .selected)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0)
        button.tintColor = .white
        button.addTarget(self, action: #selector(didButtonClick(button:)), for: .touchUpInside)
        button.isSelected = true
        return button
    }()
    
    lazy var showLyricButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("歌词".localized, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.font = UIFont.mediumPingFang(ofSize: 16)
        button.setImage("hx_photo_box_normal".image, for: .normal)
        button.setImage("hx_photo_box_selected".image, for: .selected)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0)
        button.tintColor = .white
        button.addTarget(self, action: #selector(didButtonClick(button:)), for: .touchUpInside)
        // button.isHidden = musics.isEmpty
        button.isHidden = true
        button.alpha = musics.isEmpty ? 0 : 1
        return button
    }()
    
    @objc func didButtonClick(button: UIButton) {
        if isloading {
            return
        }
        button.isSelected = !button.isSelected
        if button == backgroundButton {
            if button.isSelected {
                if selectedIndex == -1 {
                    selectedIndex = 0
                }
                playMusic()
            }else {
                stopMusic()
                showLyricButton.isSelected = false
                delegate?.musicView(self, didShowLyricButton: false, music: nil)
            }
        }else if button == originalSoundButton {
            delegate?.musicView(self, didOriginalSoundButtonClick: button.isSelected)
        }else {
            if !backgroundButton.isSelected && button.isSelected {
                if selectedIndex == -1 {
                    selectedIndex = 0
                }
                playMusic()
            }else {
                delegate?.musicView(self, didShowLyricButton: button.isSelected, music: currentMusic())
            }
        }
    }
    var isloading: Bool = false
    var pageWidth: CGFloat = 0
    var selectedIndex: Int = -1
    var currentPlayIndex: Int = -2
    var beforeIsSelect = false
    var musics: [VideoEditorMusic] = []
    let config: VideoEditorConfiguration.Music
    var didEnterPlayGround = false

    var viewHeight: CGFloat {
        return UIScreen.main.bounds.height - 200
    }
    init(config: VideoEditorConfiguration.Music, viewHeight: CGFloat) {
        // self.viewHeight = viewHeight
        self.config = config
        super.init(frame: .zero)
        setMusics(infos: config.infos)
        addSubview(bgImageViewView)
        addSubview(bgView)
        layer.addSublayer(bgMaskLayer)
        addSubview(collectionView)

        addSubview(discoverBgView)
        addSubview(discoverButton)

        addSubview(favoritesBgView)
        addSubview(favoritesButton)
        
        addSubview(collectionViewTitleLabel)

        if config.showSearch {
            addSubview(searchBgView)
        }
        
        addSubview(volumeBgView)
        addSubview(backgroundButton)
        
        if config.showOriginalSound {
            addSubview(originalSoundButton)
        } else {
            originalSoundButton.isSelected = false
            delegate?.musicView(self, didOriginalSoundButtonClick: originalSoundButton.isSelected)
        }
        
        addSubview(showLyricButton)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidEnterPlayGround),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }
    
    lazy var bgImageViewView: UIImageView = {
        let view = UIImageView(frame: .zero)
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        setupViewRadius(view: view, radius: 40)
        return view
    }()
    lazy var bgView: UIVisualEffectView = {
        let visualEffect = UIBlurEffect.init(style: .light)
        let view = UIVisualEffectView.init(effect: visualEffect)
        view.alpha = 0.6
        setupViewRadius(view: view, radius: 40)
        return view
    }()
    func setupViewRadius(view: UIView, radius: CGFloat) {
        view.clipsToBounds = true
        view.layer.cornerRadius = radius
        view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
    }
    
    @objc func appDidEnterBackground() {
        if backgroundButton.isSelected && currentPlayIndex != -2 {
            beforeIsSelect = true
        }
        // stopMusic()
        didEnterPlayGround = true
    }
    @objc func appDidEnterPlayGround() {
        if !didEnterPlayGround {
            return
        }
        if backgroundButton.isSelected && beforeIsSelect {
            playMusic()
        }else {
            backgroundButton.isSelected = false
            showLyricButton.isSelected = false
            delegate?.musicView(self, didShowLyricButton: false, music: nil)
        }
        beforeIsSelect = false
        didEnterPlayGround = false
    }
    func setMusics(infos: [VideoEditorMusicInfo]) {
        var musicArray: [VideoEditorMusic] = []
        for musicInfo in infos {
            let music = VideoEditorMusic(
                audioURL: musicInfo.audioURL,
                lrc: musicInfo.lrc,
                other: musicInfo.other
            )
            musicArray.append(music)
        }
        musics = musicArray
    }
    func reset() {
        selectedIndex = -1
        backgroundButton.isSelected = false
        showLyricButton.isSelected = false
        delegate?.musicView(self, didShowLyricButton: false, music: nil)
        stopMusic()
        // collectionView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
    }
    func reloadContentOffset() {
        // collectionView.setContentOffset(collectionView.contentOffset, animated: false)
    }
    func reloadData(infos: [VideoEditorMusicInfo]) {
        setMusics(infos: infos)
        collectionView.reloadData()
        isloading = false
        backgroundButton.isHidden = infos.isEmpty
        // showLyricButton.isHidden = infos.isEmpty
        showLyricButton.isHidden = true
        if !infos.isEmpty {
            backgroundButton.isHidden = false
            // showLyricButton.isHidden = false
            showLyricButton.isHidden = true
        }
        UIView.animate(withDuration: 0.25) {
            self.backgroundButton.alpha = infos.isEmpty ? 0 : 1
            self.showLyricButton.alpha = infos.isEmpty ? 0 : 1
            self.setBottomButtonFrame()
        } completion: { _ in
            if infos.isEmpty {
                self.backgroundButton.isHidden = true
                self.showLyricButton.isHidden = true
            }
        }

    }
    func showLoading() {
        if !musics.isEmpty {
            return
        }
        let loadMusic = VideoEditorMusic(
            audioURL: URL(fileURLWithPath: ""),
            lrc: "",
            other: [:]
        )
        loadMusic.isLoading = true
        musics = [loadMusic]
        collectionView.reloadData()
        isloading = true
    }
    
    func currentMusic() -> VideoEditorMusic? {
        if currentPlayIndex < 0 {
            return nil
        }
        return musics[currentPlayIndex]
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        bgView.frame = bounds
        bgImageViewView.frame = bounds
        bgImageViewView.image = config.backgroundImage
        bgMaskLayer.frame = bounds
        let topMargin: CGFloat = 44
        let margin: CGFloat = 30

//        let searchTextWidth = searchButton.currentTitle?.width(
//            ofFont: UIFont.mediumPingFang(ofSize: 14),
//            maxHeight: 30
//        ) ?? 0
//        var searchButtonWidth = searchTextWidth + (searchButton.currentImage?.width ?? 0) + 20
//        if searchButtonWidth < 65 {
//            searchButtonWidth = 65
//        }

        let volumeTextWidth = volumeButton.currentTitle?.width(
            ofFont: UIFont.mediumPingFang(ofSize: 14),
            maxHeight: 30
        ) ?? 0
        var volumeButtonWidth = volumeTextWidth + (volumeButton.currentImage?.width ?? 0) + 20
        if volumeButtonWidth < 65 {
            volumeButtonWidth = 65
        }

        favoritesBgView.x = marginLeft
        favoritesBgView.y = searchBgView.frame.maxY + 20
        
        discoverBgView.x = favoritesBgView.frame.maxX + 8
        discoverBgView.y = favoritesBgView.y
        
        discoverButton.width = discoverBgView.width
        favoritesButton.width = favoritesBgView.width

        discoverButton.center = discoverBgView.center
        favoritesButton.center = favoritesBgView.center

        searchBgView.frame = CGRect(
            x: marginLeft,
            y: topMargin,
            width: contentWidth,
            height: 60
        )
        _searchBgView.frame = searchBgView.bounds
        searchButton.frame = searchBgView.bounds
        
        collectionViewTitleLabel.x = marginLeft
        collectionViewTitleLabel.y = favoritesBgView.frame.maxY + 20
        
        volumeBgView.frame = CGRect(
            x: searchBgView.frame.maxX - volumeButtonWidth + 10,
            y: originalSoundButton.y,
            width: volumeButtonWidth,
            height: 30
        )
        volumeButton.frame = volumeBgView.bounds
        
        
        pageWidth = width - margin * 2 - UIDevice.leftMargin - UIDevice.rightMargin + flowLayout.minimumLineSpacing
        collectionView.frame = CGRect(x: 0,
                                      y: collectionViewTitleLabel.frame.maxY + 8,
                                      width: width,
                                      height: viewHeight - (collectionViewTitleLabel.frame.maxY + 8) - 75)
        flowLayout.itemSize = CGSize(width: width, height: 85)
        setBottomButtonFrame()
    }
    func setBottomButtonFrame() {
        
        let buttonHeight: CGFloat = 25
        let imageWidth = backgroundButton.currentImage?.width ?? 0
        let bgTextWidth = backgroundButton.currentTitle?.width(
            ofFont: UIFont.mediumPingFang(ofSize: 16),
            maxHeight: buttonHeight
        ) ?? 0
        let bgButtonWidth = imageWidth + bgTextWidth + 10
        
        let originalTextWidth = originalSoundButton.currentTitle?.width(
            ofFont: UIFont.mediumPingFang(ofSize: 16),
            maxHeight: buttonHeight
        ) ?? 0
        let originalButtonWidth = imageWidth + originalTextWidth + 10
        
        let showLyricTextWidth = showLyricButton.currentTitle?.width(
            ofFont: UIFont.mediumPingFang(ofSize: 16),
            maxHeight: buttonHeight
        ) ?? 0
        let showLyricWidth = imageWidth + showLyricTextWidth + 10
        
        originalSoundButton.frame = CGRect(
            x: marginLeft - 6,
            y: collectionView.frame.maxY + 20,
            width: originalButtonWidth,
            height: buttonHeight
        )
        originalSoundButton.centerX = width * 0.5
        
        let margin: CGFloat = 35
        backgroundButton.frame = CGRect(
            x: originalSoundButton.x - margin - bgButtonWidth,
            y: collectionView.frame.maxY + 20,
            width: bgButtonWidth,
            height: buttonHeight
        )
        
        showLyricButton.frame = CGRect(
            x: originalSoundButton.frame.maxX + margin,
            y: backgroundButton.y,
            width: showLyricWidth,
            height: buttonHeight
        )

            backgroundButton.x = UIDevice.leftMargin + margin
            backgroundButton.isHidden = true

            originalSoundButton.x = marginLeft - 6
            volumeBgView.centerY = originalSoundButton.centerY
            volumeBgView.x = searchBgView.frame.maxX - volumeBgView.width + 10
            volumeButton.frame = volumeBgView.bounds

            showLyricButton.x = originalSoundButton.frame.maxX
            showLyricButton.isHidden = true
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    var isLoading = false
    var isLoadMore = false
    var hasMore = true

    var marginLeft: CGFloat = 20
    var marginRight: CGFloat = 20
    var contentWidth: CGFloat {
        return UIScreen.main.bounds.width - marginLeft - marginRight
    }
    lazy var discoverBgView: UIView = {
        let view = UIView()
        view.frame = CGRect(origin: .zero, size: CGSize(width: (contentWidth - 8) / 2, height: 30))
        view.backgroundColor = .clear
        return view
    }()
    lazy var favoritesBgView: UIView = {
        let view = UIView()
        view.frame = CGRect(origin: .zero, size: CGSize(width: (contentWidth - 8) / 2, height: 30))
        view.backgroundColor = .clear
        view.isHidden = true
        return view
    }()
    lazy var discoverButton: UIButton = {
        let button = UIButton(frame: CGRect(origin: .zero, size: CGSize(width: 100, height: 30)))
        button.setTitle("Importieren".localized, for: .normal)
        button.titleLabel?.font = .mediumPingFang(ofSize: 14)
        button.tintColor = .white
        button.addTarget(self, action: #selector(didDiscoverButtonClick), for: .touchUpInside)
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 1
        if #available(iOS 13.0, *) {
            button.layer.borderColor = UIColor.link.cgColor
        } else {
            button.layer.borderColor = UIColor.blue.cgColor
        }
        button.layer.masksToBounds = true
        return button
    }()
    lazy var favoritesButton: UIButton = {
        let button = UIButton(frame: CGRect(origin: .zero, size: CGSize(width: 100, height: 30)))
        button.setTitle("Gespeichert".localized, for: .normal)
        button.titleLabel?.font = .mediumPingFang(ofSize: 14)
        button.tintColor = .white
        button.addTarget(self, action: #selector(didFavoritesButtonClick), for: .touchUpInside)
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 1
        if #available(iOS 13.0, *) {
            button.layer.borderColor = UIColor.link.cgColor
        } else {
            button.layer.borderColor = UIColor.blue.cgColor
        }
        button.layer.masksToBounds = true
        return button
    }()
    lazy var collectionViewTitleLabel: UILabel = {
        let label = UILabel(frame: CGRect(origin: .zero, size: CGSize(width: contentWidth, height: 21)))
        label.text = "Für dich".localized
        label.font = .mediumPingFang(ofSize: 14)
        label.textColor = .white
        return label
    }()

    @objc func didDiscoverButtonClick() {
        if #available(iOS 13.0, *) {
            discoverButton.backgroundColor = .link
        } else {
            discoverButton.backgroundColor = .blue
        }
        favoritesButton.backgroundColor = .clear

        updateOtherMusic()

        musics.removeAll()
        collectionView.reloadData()
        delegate?.discoverMusicView(
            self,
            completion: { [weak self] musicInfos, hasMore in
                guard let self = self else { return }

                self.musics.removeAll()
                self.updateData(otherMusic: self.videoEditor?.otherMusic,
                                musicInfos: musicInfos,
                                hasMore: hasMore)
            })
    }

    @objc func didFavoritesButtonClick() {
        discoverButton.backgroundColor = .clear
        if #available(iOS 13.0, *) {
            favoritesButton.backgroundColor = .link
        } else {
            favoritesButton.backgroundColor = .blue
        }

        updateOtherMusic()

        musics.removeAll()
        collectionView.reloadData()
        delegate?.favoritesMusicView(
            self,
            completion: { [weak self] musicInfos, hasMore in
                guard let self = self else { return }

                self.musics.removeAll()
                self.updateData(otherMusic: self.videoEditor?.otherMusic,
                                musicInfos: musicInfos,
                                hasMore: hasMore)
            })
    }
    
    func updateOtherMusic() {
        if selectedIndex >= 0
            && selectedIndex < musics.count {
            
            videoEditor?.otherMusic = musics[selectedIndex]
            videoEditor?.otherMusic?.isOtherMusic = true
            videoEditor?.otherMusic?.isSelected = true
        }
    }

    private func updateData(otherMusic: VideoEditorMusic?,
                            musicInfos: [VideoEditorMusicInfo],
                            hasMore: Bool) {
        
        if let otherMusic = otherMusic {
            otherMusic.isOtherMusic = true
            otherMusic.isSelected = true
            
            selectedIndex = 0
            currentPlayIndex = 0
            
            self.musics.append(otherMusic)
        }
        
        for musicInfo in musicInfos
        where musicInfo.audioURL.absoluteString != otherMusic?.audioURL.absoluteString {
            
            let music = VideoEditorMusic(
                audioURL: musicInfo.audioURL,
                lrc: musicInfo.lrc,
                other: musicInfo.other
            )

            self.musics.append(music)
        }

        self.collectionView.reloadData()

        self.hasMore = hasMore
        self.isLoadMore = false
    }
}

extension VideoEditorMusicView: UICollectionViewDataSource,
                                UICollectionViewDelegate,
                                UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        musics.count
    }
    public func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        
        if let cell = config.cellForItemAt?(musics, collectionView, indexPath) {
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "VideoEditorMusicViewCellID",
            for: indexPath
        ) as! VideoEditorMusicViewCell
        cell.music = musics[indexPath.item]
        return cell
    }
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        /*
        let offsetX = pageWidth * CGFloat(indexPath.item)
        if (indexPath.item == selectedIndex && backgroundButton.isSelected) ||
            collectionView.contentOffset.x != offsetX {
            return
        }
        */
        
        
        if selectedIndex == indexPath.item {
            
            reset()
            delegate?.musicView(selectMusic: nil)
            
        } else {
        
        selectedIndex = indexPath.item
        //if collectionView.contentOffset.x == offsetX {
            playMusic()
            delegate?.musicView(selectMusic: musics[indexPath.item])
        //}else {
        //    collectionView.setContentOffset(CGPoint(x: offsetX, y: collectionView.contentOffset.y), animated: true)
        //}
            
        }
        
    }
    
    public func scrollViewWillEndDragging(
        _ scrollView: UIScrollView,
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>
    ) {
        /*
        if selectedIndex == -1 { selectedIndex = 0 }
        let finalPoint = targetContentOffset.pointee
        let pageWidth = pageWidth
        let startX = pageWidth * CGFloat(selectedIndex)
        var index = selectedIndex
        let margin = flowLayout.itemSize.width * 0.3
        if finalPoint.x < startX - margin {
            index -= 1
        }else if finalPoint.x > startX + margin {
            index += 1
        }else {
            if velocity.x != 0 {
                index = velocity.x > 0 ? index + 1 : index - 1
            }
        }
        index = min(index, musics.count - 1)
        index = max(0, index)
        let offsetX = pageWidth * CGFloat(index)
        selectedIndex = index
        targetContentOffset.pointee.x = offsetX
        */
    }
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        /*
        if !scrollView.isTracking && config.autoPlayWhenScrollingStops {
            playMusic()
        }
        */
    }
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        /*
        if !decelerate {
            if selectedIndex == -1 { return }
            let offsetX = pageWidth * CGFloat(selectedIndex)
            scrollView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: true)
        }
        */
    }
    
    public func playMusic() {
        if selectedIndex == -1 { return }
        if currentPlayIndex == selectedIndex { return }
        stopMusic()
        
        if !config.customPlay {
            /*
            let currentX = pageWidth * CGFloat(selectedIndex)
            if collectionView.contentOffset.x != currentX {
                collectionView.setContentOffset(CGPoint(x: currentX, y: 0), animated: false)
            }
            */
            let cell = collectionView.cellForItem(
                at: IndexPath(
                    item: selectedIndex,
                    section: 0
                )
            ) as? VideoEditorMusicViewCell
            if cell?.music.isLoading == true {
                return
            }
            cell?.playMusic(completion: { [weak self] path, music in
                guard let self = self else { return }
                self.backgroundButton.isSelected = true
                let shake = UIImpactFeedbackGenerator(style: .light)
                shake.prepare()
                shake.impactOccurred()
                self.delegate?.musicView(self, didSelectMusic: path)
                if self.showLyricButton.isSelected {
                    self.delegate?.musicView(self, didShowLyricButton: true, music: music)
                }
            })
        } else {
            customPlay(music: musics[selectedIndex])
        }
        
        currentPlayIndex = selectedIndex
    }
    public func stopMusic() {
        if let beforeCell = collectionView.cellForItem(
            at: IndexPath(
                item: currentPlayIndex,
                section: 0
            )
        ) as? VideoEditorMusicViewCell {
            if beforeCell.music.isLoading == true {
                return
            }
            config.stop?(currentPlayIndex)
            collectionView.reloadData()
            beforeCell.stopMusic()
        }else {
            if currentPlayIndex >= 0 && currentPlayIndex < musics.count {
                let currentMusic = musics[currentPlayIndex]
                PhotoManager.shared.suspendTask(currentMusic.audioURL)
                currentMusic.isSelected = false
                videoEditor?.otherMusic?.isSelected = false
                config.stop?(currentPlayIndex)
                collectionView.reloadData()
            }
            PhotoManager.shared.stopPlayMusic()
        }
        
        currentPlayIndex = -2
        delegate?.musicView(deselectMusic: self)
    }
}

extension VideoEditorMusicView {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let maxOffsetY = contentHeight - scrollView.height + scrollView.contentInset.bottom
        if offsetY > maxOffsetY - 100 && hasMore {
            if !isLoadMore && !isLoading && !musics.isEmpty {
                isLoadMore = true
                
                delegate?.loadMoreMusicView(
                    self,
                    completion: { [weak self] musicInfos, hasMore in
                        guard let self = self else { return }
                        self.updateData(otherMusic: nil,
                                        musicInfos: musicInfos,
                                        hasMore: hasMore)
                    })
            }
        }
    }
}

extension VideoEditorMusicView {
    public func searchMusicViewDidSelectItem() {
        musics.filter({ $0.isSelected }).forEach { $0.isSelected = false }
        musics.removeAll(where: { $0.isOtherMusic
            || $0.audioURL.absoluteString == videoEditor?.otherMusic?.audioURL.absoluteString })
        
        if let otherMusic = videoEditor?.otherMusic {
            
            otherMusic.isOtherMusic = true
            otherMusic.isSelected = true
            
            selectedIndex = 0
            currentPlayIndex = 0
            musics.insert(otherMusic, at: selectedIndex)
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.collectionView.reloadData()
        }
    }
}

extension VideoEditorMusicView {
    func customPlay(music: VideoEditorMusic) {
        let completion: (String, VideoEditorMusic) -> Void = { [weak self] path, music in
            guard let self = self else { return }
            self.delegate?.musicView(self, didSelectMusic: path)
        }
        
        if music.audioURL.isFileURL {
            playLocalMusic(music: music, completion: completion)
        } else {
            playNetworkMusic(music: music, completion: completion)
        }
    }
    
    func playLocalMusic(music: VideoEditorMusic,
                        completion: @escaping (String, VideoEditorMusic) -> Void) {
        
        music.localAudioPath = music.audioURL.path
        didPlay(music: music, audioPath: music.audioURL.path)
        music.isSelected = true
        
        completion(music.audioURL.path, music)
    }
    
    func playNetworkMusic(music: VideoEditorMusic,
                          completion: @escaping (String, VideoEditorMusic) -> Void) {
        let key = music.audioURL.absoluteString
        let audioTmpURL = PhotoTools.getAudioTmpURL(for: key)
        
        if PhotoTools.isCached(forAudio: key) {
            
            music.localAudioPath = audioTmpURL.path
            didPlay(music: music, audioPath: audioTmpURL.path)
            music.isSelected = true
            
            completion(audioTmpURL.path, music)
            return
        }
        
        config.showLoading?()
        PhotoManager.shared.downloadTask(
            with: music.audioURL,
            toFile: audioTmpURL,
            ext: music
        ) { audioURL, error, ext in
            self.config.hideLoading?()
            
            if let audioURL = audioURL {
                
                music.localAudioPath = audioURL.path
                self.didPlay(music: music, audioPath: audioURL.path)
                music.isSelected = true
                
                completion(audioURL.path, music)
            } else {
                self.resetStatus()
            }
        }
    }
    
    func didPlay(music: VideoEditorMusic, audioPath: String) {
        PhotoManager.shared.playMusic(filePath: audioPath) {}
        
        config.didPlay?(selectedIndex)
        collectionView.reloadData()
    }
    
    func resetStatus() {
        
    }
}
