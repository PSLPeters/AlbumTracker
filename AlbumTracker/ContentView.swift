//
//  ContentView.swift
//  AlbumTracker
//
//  Created by Michael Peters on 3/13/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var isShowingAlbumSheet = false
    @State private var isShowingStatisticsSheet = false
    
    @AppStorage("isDarkModeOn") var isDarkModeOn = false
    
    @Environment(\.modelContext) var context
    @FocusState private var isAddFocused: Bool
    @Query(sort: \modelAlbum.artistName)
    var arrAlbums: [modelAlbum] = []
    
    var arrFilteredAlbums: [modelAlbum]
    {
        guard !searchTerm.isEmpty else { return arrAlbums }
        return arrAlbums.filter
        {
            $0.artistName.localizedCaseInsensitiveContains(searchTerm)
        }
    }
    
    @State private var albumToEdit: modelAlbum?
    @State private var searchTerm = ""
    
        var body: some View {
            NavigationStack{
                List {
                    ForEach(arrFilteredAlbums) { album in
                        AlbumCell(album: album)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                albumToEdit = album
                            }
                    }
                    .onDelete(perform: { indexSet in
                        for index in indexSet {
                            context.delete(arrFilteredAlbums[index])
                        }
                        PetersHaptics.process.impact(.heavy)
                    })
                }
                .navigationTitle("Albums")
                .navigationBarTitleDisplayMode(.large)
                .searchable(text: $searchTerm, prompt: "Search albums")
                .sheet(isPresented: $isShowingAlbumSheet) { AddAlbumSheet() }
                .sheet(item: $albumToEdit)
                {
                    album in
                    UpdateAlbumSheet(album: album)
                }
                .toolbar {
                    ToolbarItemGroup(placement: .topBarLeading) {
                        Button {
                            isDarkModeOn.toggle()
                        } label: {
                            let image = isDarkModeOn ? "lightbulb" : "lightbulb.fill"
                            Image(systemName: image)
                        }
                    }
                        ToolbarItemGroup(placement: .topBarTrailing) {
                            if !arrAlbums.isEmpty
                            {
                                EditButton()
                                Button("Add Album", systemImage: "plus")
                                {
                                    isShowingAlbumSheet = true
                                    PetersHaptics.process.impact(.soft)
                                }
                            }
                    }
                }
                .overlay {
                    if arrAlbums.isEmpty {
                        ContentUnavailableView(
                            label:
                                    {
                                        Label("No Albums", systemImage: "music.quarternote.3")
                                    }
                            , description:
                                    {
                                        Text("Start adding albums to see your list.")
                                    }
                            , actions:
                                {
                                    Button("Add Album")
                                    {
                                        isShowingAlbumSheet = true
                                        PetersHaptics.process.impact(.soft)
                                    }
                                }
                        )
                        }
                    }
                .toolbar {
                    ToolbarItemGroup(placement: .bottomBar)
                        {
                            Button {
                                isShowingStatisticsSheet = true
                            } label: {
                                Text("Statistics")
                            }
                            .sheet(isPresented: $isShowingStatisticsSheet) {
                                VStack {
                                    ZStack {
                                        HStack {
                                            Button {
                                                isShowingStatisticsSheet = false
                                            } label: {
                                                Text("Close")
                                            }
                                            .padding([.leading, .top])
                                            Spacer()
                                        }
                                        HStack {
                                            Text("Statistics")
                                            .padding(.top)
                                        }
                                    }
                                    Spacer()
                                    Form {
                                        Section ("Counts:") {
                                            let albumCount = arrAlbums.count
                                            let purchasedTotal = arrAlbums.filter{ $0.selectedAlbumConditionIndex == 0 }.count
                                            let burntTotal = arrAlbums.filter{ $0.selectedAlbumConditionIndex == 1 }.count
                                            
                                            LabeledContent("Albums", value: albumCount.withCommas())
                                            LabeledContent("Purchased Albums", value: purchasedTotal.withCommas())
                                            LabeledContent("Burnt Albums", value: burntTotal.withCommas())
                                        }
                                    }
                                }
                                .presentationDetents([.medium])
                                .presentationDragIndicator(.visible)
                            }
                        }
                    }
                }
            .preferredColorScheme(isDarkModeOn ? .dark : .light)
        }
}

#Preview {
    ContentView()
}

struct AlbumCell: View {
    
    let album: modelAlbum
    
    var body: some View {
            HStack {
            Text(album.artistName)
            Spacer()
            Text(album.albumTitle)
        }
    }
}

struct AddAlbumSheet: View {
    @Environment(\.modelContext) var context
    @Environment(\.dismiss) private var dismiss
    
    enum FocusedField {
        case artistName
        case albumTitle
    }
    @FocusState private var focusedField: FocusedField?
    
    @State private var artistName: String = ""
    @State private var albumTitle: String = ""
    @State private var selectedAlbumConditionIndex: Int = 0
  
    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    TextField("Artist Name", text: $artistName)
                        .focused($focusedField, equals: .artistName)
                    TextField("Album Title", text: $albumTitle)
                        .focused($focusedField, equals: .albumTitle)
                    HStack {
                        Text("Condition:")
                        Picker("Select Profile", selection: $selectedAlbumConditionIndex) {
                            ForEach(arrAlbumConditions.indices, id:\.self) { index in
                                let foundIndex = arrAlbumConditions[index]
                                Text((foundIndex.name))
                                    .tag(index)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                }
            }
            .onAppear {
                focusedField = .artistName
            }
            .navigationTitle("New Album")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button("Cancel")
                    {
                        dismiss()
                    }
                }
                
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button("Save")
                    {
                        let album = modelAlbum(
                            artistName: artistName,
                            albumTitle: albumTitle,
                            selectedAlbumConditionIndex: selectedAlbumConditionIndex)
                        context.insert(album)
                        dismiss()
                    }
                    .disabled(artistName.isEmpty || albumTitle.isEmpty)
                }
            }
        }
    }
}

struct UpdateAlbumSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var album: modelAlbum
    
    enum FocusedField {
        case artistName
        case albumTitle
    }
    @FocusState private var focusedField: FocusedField?
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Artist Name", text: $album.artistName)
                    .focused($focusedField, equals: .artistName)
                TextField("Album Title", text: $album.albumTitle)
                    .focused($focusedField, equals: .albumTitle)
                HStack {
                    Text("Condition:")
                    Picker("Select Profile", selection: $album.selectedAlbumConditionIndex) {
                        ForEach(arrAlbumConditions.indices, id:\.self) { index in
                            let foundIndex = arrAlbumConditions[index]
                            Text((foundIndex.name))
                                .tag(index)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }
            .onAppear {
                focusedField = .artistName
            }
            .navigationTitle($album.albumTitle.wrappedValue == "" ? "Expense Name" : $album.albumTitle.wrappedValue)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button("Done")
                    {
                        dismiss()
                    }
                }
            }
        }
    }
}

class PetersHaptics {
    static let process = PetersHaptics()
    
    private init() { }

    func impact(_ feedbackStyle: UIImpactFeedbackGenerator.FeedbackStyle) {
        UIImpactFeedbackGenerator(style: feedbackStyle).impactOccurred()
    }
    
    func notification(_ feedbackType: UINotificationFeedbackGenerator.FeedbackType) {
        UINotificationFeedbackGenerator().notificationOccurred(feedbackType)
    }
}

extension Int {
    func withCommas() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        return numberFormatter.string(from: NSNumber(value:self))!
    }
}
