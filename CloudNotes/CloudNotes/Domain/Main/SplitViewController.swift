import UIKit

class SplitViewController: UISplitViewController {
    private let noteListViewController = NoteListViewController()
    private let detailedNoteViewController = DetailedNoteViewController()
    private var dataSourceProvider: NoteDataSource?
    private var currentNoteIndex: Int?

    override func viewDidLoad() {
        super.viewDidLoad()

        dataSourceProvider = CDDataSourceProvider()
        self.preferredDisplayMode = .oneBesideSecondary
        self.preferredSplitBehavior = .tile
        self.setViewController(noteListViewController, for: .primary)
        self.setViewController(detailedNoteViewController, for: .secondary)
        fetchNotes()

        noteListViewController.setDelegate(delegate: self)
        detailedNoteViewController.setDelegate(delegate: self)
    }

    private func fetchNotes() {
        do {
            try dataSourceProvider?.fetch()
        } catch {
            print(error.localizedDescription)
        }

        passInitialData()
    }

    private func passInitialData() {
        guard let data = dataSourceProvider?.noteList else {
            return
        }

        noteListViewController.setNoteList(data)
        detailedNoteViewController.setNoteData(data.first)
        self.currentNoteIndex = 0
    }
}

// MARK: - NoteList View Delegate
extension SplitViewController: NoteListViewDelegate {
    func deleteNote(_ note: Content, index: Int) {
        do {
            try dataSourceProvider?.deleteNote(note)
        } catch {
            print(error)
        }

        guard let noteList = dataSourceProvider?.noteList else {
            return
        }

        noteListViewController.delete(at: index)
        var changedIndex: Int?
        if noteList.count == index {
            changedIndex = index - 1
        } else {
            changedIndex = index
        }

        guard let index = changedIndex else {
            return
        }

        detailedNoteViewController.setNoteData(noteList[safe: index])
    }

    func creatNote() {
        let note = Content(
            title: "",
            body: "",
            lastModifiedDate: Date().timeIntervalSince1970,
            identification: UUID()
        )
        do {
            try dataSourceProvider?.createNote(note)
        } catch let error {
            print(error)
        }

        guard let noteList = dataSourceProvider?.noteList else {
            return
        }

        guard let note = noteList.first else {
            return
        }

        noteListViewController.insert(note)
        noteListViewController.selectedIndexPath = IndexPath(row: 0, section: 0)

        detailedNoteViewController.setNoteData(note)
    }

    func passNote(at index: Int) {
        self.currentNoteIndex = index
        detailedNoteViewController.setNoteData(dataSourceProvider?.noteList[index])
        self.view.endEditing(true)
    }
}

// MARK: - DetailedNote View Delegate

extension SplitViewController: DetailedNoteViewDelegate {
    func deleteNote(_ note: Content) {
        do {
            try dataSourceProvider?.deleteNote(note)
        } catch {
            print(error)
        }

        guard let noteList = dataSourceProvider?.noteList else {
            return
        }

        guard let index = self.currentNoteIndex else {
            return
        }

        noteListViewController.delete(at: index)
        detailedNoteViewController.setNoteData(noteList.first)
    }

    func passModifiedNote(_ note: Content) {
        do {
            try dataSourceProvider?.updateNote(note)
        } catch let error {
            print(error)
        }

        guard let noteList = dataSourceProvider?.noteList else {
            return
        }

        noteListViewController.setNoteList(noteList)
    }
}

// MARK: - Array Extension

private extension Array {
    subscript (safe index: Int) -> Element? {
        return indices ~= index ? self[index] : nil
    }
}
