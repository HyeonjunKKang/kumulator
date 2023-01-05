//
//  LiberalBasicHumanitiesInputViewController.swift
//  kumulator
//
//  Created by 강현준 on 2022/09/04.
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseDatabase

class LiberalBasicHumanitiesInputViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    let SubjectList = LiberalBasicHumanities()
    
    let uid = Auth.auth().currentUser?.uid
    let ref = Database.database().reference()
    
    @IBOutlet weak var TableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        TableView.dataSource = self
        TableView.delegate = self
    }
    
    @IBAction func OkButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func SelectSwitch(_ sender: UISwitch) {
        
        //스위치가 위치한 셀의 indexpath row를 가져와서 셀들의 스위치를 다루는 코드
        let contentView = sender.superview
        let cell = contentView?.superview as! LiberalBasicHumanitiesCell
        let indexPath = TableView.indexPath(for: cell)
        let row = indexPath?.row
        
        //스위치가 on일경우에 추가
        if sender.isOn != false{                        //고유 키를 생성해서 추가
            ref.child("LiberalBasicHumanities").child(uid!).childByAutoId().setValue(SubjectList.LiberalBasicHumanities[row!].SubjectName)
        }else{
            //스위치가 on일경우 off상태가 되면 데이터베이스에서 삭제
            ref.child("LiberalBasicHumanities").child(uid!).observeSingleEvent(of: .value) { snapshot in
                
                let value = snapshot.value
                guard let dic = value as? [String: Any] else { return }
                for index in dic{
                    if(index.value as! String == self.SubjectList.LiberalBasicHumanities[row!].SubjectName){
                        self.ref.child("LiberalBasicHumanities").child(self.uid!).child(index.key).removeValue()
                    }
                }
                
            }
        }
        
    }
    //테이블 뷰에 나타날 셀의 갯수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SubjectList.LiberalBasicHumanities.count
        }
    
    //셀의 정보를 리턴함.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell: LiberalBasicHumanitiesCell = tableView.dequeueReusableCell(withIdentifier: "LiberalBasicHumanitiesCell", for: indexPath) as? LiberalBasicHumanitiesCell else { return UITableViewCell() }
        
        cell.SubjectNameLabel.text = self.SubjectList.LiberalBasicHumanities[indexPath.row].SubjectName
        cell.CreditLabel.text = String(self.SubjectList.LiberalBasicHumanities[indexPath.row].SubjectCredit)
        
        //스위치의 on off 상태 초기화
        ref.child("LiberalBasicHumanities").child(uid!).observeSingleEvent(of: .value) { snapshot in
            
            let value = snapshot.value
            guard let dic = value as? [String: Any] else { return }
            for index in dic{
                if(index.value as! String == self.SubjectList.LiberalBasicHumanities[indexPath.row].SubjectName){
                    cell.SelectSwitch.isOn = true
                }
            }
        }
        return cell
    }
    
    //셀의 높이를 리턴함
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}

class LiberalBasicHumanitiesCell: UITableViewCell{
    @IBOutlet weak var SubjectNameLabel: UILabel!
    @IBOutlet weak var CreditLabel: UILabel!
    @IBOutlet weak var SelectSwitch: UISwitch!
}
