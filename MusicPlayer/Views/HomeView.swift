import SwiftUI

struct SongTypeView: View {
    var title: String
    var imageName: String

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 150, height: 150)
                .cornerRadius(20)

            Color.black.opacity(0.4)
                .cornerRadius(20)

            Text(title)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
                .rotationEffect(.degrees(-10))
                .padding(8)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
            
            
        }
        .frame(width: 150, height:150)
    }
}

struct SongTypesListView: View {
    @EnvironmentObject var mediaPlayerState: MediaPlayerState

    var body: some View {
        LazyVStack(alignment: .leading, spacing: 40) {
            VStack(alignment: .leading) {
                Text("Today’s Biggest Hits")
                    .font(.title)
                    .bold()
                    .padding(.leading, 20)
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 20) {
                        ForEach(SongType.allCases, id: \.self) { songType in
                            NavigationLink(
                                destination: SongListView(songType: songType)
                                    .environmentObject(mediaPlayerState)
                            ) {
                                if songType != .space
                                    {SongTypeView(title: songType.rawValue, imageName: songType.rawValue)}
                                    else{
                                        SongTypeView(title: songType.rawValue, imageName: "space")
                                    }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }

            VStack(alignment: .leading) {
                Text("Trending Genres")
                    .font(.title)
                    .bold()
                    .padding(.leading, 20)
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 20) {
                        ForEach(SongType.allCases, id: \.self) { songType in
                            NavigationLink(
                                destination: SongListView(songType: songType)
                                    .environmentObject(mediaPlayerState)
                            ) { if songType != .space
                                {SongTypeView(title: songType.rawValue, imageName: songType.rawValue)}
                                else{
                                    SongTypeView(title: songType.rawValue, imageName: "space")
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
        .padding(.vertical)
    }
}

struct HomeView: View {
    @EnvironmentObject var mediaPlayerState: MediaPlayerState

    var body: some View {
        NavigationView {
            ZStack {
                Image("background")
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                    .opacity(0.3)

                ScrollView(.vertical, showsIndicators: false) {
                    SongTypesListView()
                        .environmentObject(mediaPlayerState)
                        .padding()
                        .padding(.top, 20)
                }
                .padding(.leading, 150) 
            }
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden(true)
        }
        .accentColor(.red)
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
