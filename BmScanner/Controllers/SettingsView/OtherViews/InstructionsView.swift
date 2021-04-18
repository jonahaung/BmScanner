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
        VideoPlayer(player: AVPlayer(url: AppInfo.guideURL))
            .edgesIgnoringSafeArea(.all)
    }
}
