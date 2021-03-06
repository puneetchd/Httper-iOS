//
//  SaveToProjectViewController.swift
//  Httper
//
//  Created by Meng Li on 2019/01/03.
//  Copyright © 2019 MuShare Group. All rights reserved.
//

import RxDataSourcesSingleSection

class SaveToProjectViewController: BaseViewController<SaveToProjectViewModel> {
    
    private lazy var addProjectBarButtonItem: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: nil)
        barButtonItem.rx.tap.bind { [unowned self] in
            self.viewModel.addProject()
        }.disposed(by: disposeBag)
        return barButtonItem
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.hideFooterView()
        tableView.register(cellType: ProjectTableViewCell.self)
        tableView.backgroundColor = .clear
        tableView.rowHeight = 50
        tableView.rx.itemSelected.subscribe(onNext: { [unowned self] in
            self.viewModel.pickProject(at: $0.row)
        }).disposed(by: disposeBag)
        tableView.es.addPullToRefresh { [unowned self] in
            self.viewModel.syncProjects {
                tableView.es.stopPullToRefresh(ignoreDate: true, ignoreFooter: true)
            }
        }
        return tableView
    }()
    
    private lazy var dataSource = ProjectTableViewCell.tableViewSingleSectionDataSource()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .background
        navigationItem.rightBarButtonItem = addProjectBarButtonItem
        view.addSubview(tableView)
        createConstraints()
        
        viewModel.title.bind(to: rx.title).disposed(by: disposeBag)
        viewModel.projectSection.bind(to: tableView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.syncProjects()
    }
    
    private func createConstraints() {
        tableView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(topPadding)
            $0.left.right.bottom.equalToSuperview()
        }
    }
    
}
