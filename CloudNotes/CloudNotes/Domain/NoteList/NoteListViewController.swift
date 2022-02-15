import UIKit

class NoteListViewController: UITableViewController {
    private var noteListData = [Content]() {
        didSet {
            tableView.reloadData()
        }
    }
    private weak var dataSourceDelegate: NoteListViewDelegate?

    private lazy var addButton: UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.image = UIImage(systemName: "plus")
        button.target = self
        button.action = #selector(touchUpPlusButton)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.register(
            NoteListCell.self,
            forCellReuseIdentifier: String(describing: NoteListCell.self)
        )

        configureNavigationBar()
    }

    func setDelegate(delegate: NoteListViewDelegate) {
        self.dataSourceDelegate = delegate
    }

    // MARK: - Manipulate DataSource

    func setNoteListData(_ data: [Content]) {
        self.noteListData = data
    }

    @objc func touchUpPlusButton() {
        self.dataSourceDelegate?.creatNote()
    }

    // MARK: - Configure Navigation Bar

    private func configureNavigationBar() {
        self.title = "메모"

        self.navigationItem.rightBarButtonItem = addButton
    }

    // MARK: - Table View Data Source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return noteListData.count
    }

    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: String(describing: NoteListCell.self),
            for: indexPath
        ) as? NoteListCell else {
            return UITableViewCell()
        }

        cell.configureContent(for: noteListData[indexPath.row])

        return cell
    }

    // MARK: - Table View Delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dataSourceDelegate?.passNote(index: indexPath.row)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
