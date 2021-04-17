//
//  InstructionsView.swift
//  PhotoSMS
//
//  Created by Aung Ko Min on 6/4/21.
//

import SwiftUI
import AVKit

struct InstructionsView: View {
    var body: some View {
        VideoPlayer(player: AVPlayer(url: URL(string: "https://firebasestorage.googleapis.com/v0/b/photosms-1bc29.appspot.com/o/guide.MP4?alt=media&token=252d56a6-d6fa-4961-b8ea-d9995725004a")!))
            .edgesIgnoringSafeArea(.all)
    }
}
