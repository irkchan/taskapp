//
//  ViewController.swift
//  taskapp
//
//  Created by 吉田なつみ on 2021/10/04.
//

import UIKit
import RealmSwift
import UserNotifications

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    // Realmインスタンスを取得する
    let realm = try! Realm()
    
    // DB内のタスクが格納されるリスト。
    // 日付の近い順でソート：昇順
    // 以降内容をアップデートするとリスト内は自動的に更新される。
    var taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: true)
    
    var filterdDatas = [String]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        searchBar.placeholder="検索したいワード"
        
    }

    //検索バーにテキストを入力した時にfunctionを動かす
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText: String) -> Bool{
        //searchBar.backgroundColor = UIColor.red
        
        if searchBar.text == "" {
            taskArray = realm.objects(Task.self)
            tableView.reloadData()
        }else{
            let predicate = NSPredicate(format: "category = %@", searchBar.text!)
            taskArray = realm.objects(Task.self).filter(predicate)
            tableView.reloadData()
        }
        
        print("検索しました")
        return true
    }
    /*func searchBar(_ searchBar: UISearchBar,textDidChange searchText: String)-> Bool {
        return true
    }*/
    
    // データの数（＝セルの数）を返すメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskArray.count
    }
    
    // 各セルの内容を返すメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 再利用可能な cell を得る
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        // Cellに値を設定する
        let task = taskArray[indexPath.row]
        cell.textLabel?.text = task.title
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let dateString:String = formatter.string(from: task.date)
        cell.detailTextLabel?.text = dateString
        
        
        return cell
    }
    
    // 各セルを選択した時に実行されるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "cellSegue",sender: nil)
    }
    
    // セルが削除が可能なことを伝えるメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath)-> UITableViewCell.EditingStyle {
        return .delete
    }
    
    
    // Delete ボタンが押された時に呼ばれるメソッド
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // --- ここから ---
               if editingStyle == .delete {
                   // 削除するタスクを取得する
                   let task = self.taskArray[indexPath.row]

                   // ローカル通知をキャンセルする
                   let center = UNUserNotificationCenter.current()
                   center.removePendingNotificationRequests(withIdentifiers: [String(task.id)])

                   // データベースから削除する
                   try! realm.write {
                       self.realm.delete(task)
                       tableView.deleteRows(at: [indexPath], with: .fade)
                   }

                   // 未通知のローカル通知一覧をログ出力
                   center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
                       for request in requests {
                           print("/---------------")
                           print(request)
                           print("---------------/")
                       }
                   }
               } // --- ここまで変更 ---
    }
    // segue で画面遷移する時に呼ばれる
       override func prepare(for segue: UIStoryboardSegue, sender: Any?){
           let inputViewController:InputViewController = segue.destination as! InputViewController

           if segue.identifier == "cellSegue" {
               let indexPath = self.tableView.indexPathForSelectedRow
               inputViewController.task = taskArray[indexPath!.row]
           } else {
               let task = Task()

            let allTasks = realm.objects(Task.self)
               if allTasks.count != 0 {
                   task.id = allTasks.max(ofProperty: "id")! + 1
               }

               inputViewController.task = task
           }
       }
    // 入力画面から戻ってきた時に TableView を更新させる
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    
}

/*extension ViewController: UITextFieldDelegate {
    private func searchBar(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = searchBar.text {
            (string.count == 0) ? filterText(String(text.dropLast())) : filterText(text+string)
        }
        return true
    }

    func filterText(_ query: String) {
        filterdDatas.removeAll()
        taskArray.forEach { Task in
            if Task.lowercased().starts(with: query.lowercased()) {
                filterdDatas.append(Task)
            }
        }
        tableView.reloadData()
    }
}
 */
