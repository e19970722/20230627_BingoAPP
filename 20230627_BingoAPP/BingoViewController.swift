//
//  ViewController.swift
//  20230627_BingoAPP
//
//  Created by Yen Lin on 2023/6/27.
//

import UIKit

class BingoViewController: UIViewController {

    //放按鈕的容器
    let numberPadView: UIView = {
       let holder = UIView()
        return holder
    }()
    
    let gameTitle: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .darkGray
        label.text = "B   I   N   G   O"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        return label
    }()
    
    //Bingo Number 機器產生
    let machineLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "nil"
        label.textColor = .black
        label.font = .systemFont(ofSize: 64, weight: .bold)
        return label
    }()
    
    //Bingo Number 機器產生
    let resetLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "16"
        label.textColor = .black
        label.font = .systemFont(ofSize: 18, weight: .bold)
        return label
    }()
    
    //重置按鈕，每按一次就會更新亂數
    let resetButton: UIButton = {
       let button = UIButton()
        button.backgroundColor = .link
        button.setTitle("Reset", for: .normal)
        button.layer.cornerRadius = 10
        button.clipsToBounds = true

        return button
    }()
    
    //=======================================//
    
    //幾*幾的Bingo盤
    var numberOfRows = 5
    
    //紀錄有沒有被按過的2D Array
    var recordArr = [[Int]]()
    
    //亂數的頂端
    let upperRange = 25
    
    //幾條線就算贏？
    var bingoLines = 0
    var linesWin = 2
    
    //機器產生的Array
    var machineNumArr = [String]()
    
    //使用者的Array
    var userNumArr = [String]()
    
    //按鈕間距
    let marginSize: CGFloat = 16
    
    //按鈕大小
    var buttonSize: CGFloat = 0
    
    //Bingo盤上的所有Button
    var buttons = [UIButton]()
    
    //正、斜線 只要一次就好
    var forwardDidConnect = false
    var backDidConnect = false
    
    //=======================================//
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        view.addSubview(gameTitle)
        view.addSubview(machineLabel)
        view.addSubview(resetButton)
        
        
        
        
        setNumberPad(numberOfRows: numberOfRows)
        
        //Bingo盤
        view.addSubview(numberPadView)
        
        //重置按鈕
        resetButton.addTarget(self, action: #selector(resetButtonPressed), for: .touchUpInside)
        
        //產生亂數
        resetButtonPressed()
        
    }
    
    override func viewDidLayoutSubviews() {
        
        let marginSize = 16.0
        
        gameTitle.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            gameTitle.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: marginSize),
            gameTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        machineLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            machineLabel.topAnchor.constraint(equalTo: gameTitle.bottomAnchor, constant: marginSize*2),
            machineLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            machineLabel.widthAnchor.constraint(equalToConstant: view.frame.size.width)
        ])
        
        
        resetButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            resetButton.topAnchor.constraint(equalTo: machineLabel.bottomAnchor, constant: marginSize),
            resetButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            resetButton.widthAnchor.constraint(equalToConstant: view.frame.size.width/3)
        ])
       
        //使用者的Bingo盤
        numberPadView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            numberPadView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            numberPadView.widthAnchor.constraint(equalToConstant: view.frame.size.width),
            numberPadView.heightAnchor.constraint(equalToConstant: view.frame.size.width)
        ])
        
        
        
    }
    
    //按鈕UI
    func setNumberPad(numberOfRows: Int) {
                
        //Bingo按鈕 —— 3個按鈕就有3+1個間距
        buttonSize = (view.frame.size.width - marginSize * (CGFloat(numberOfRows)+1)) / CGFloat(numberOfRows)
        
        var buttonNumber = 0
                
        for row in 0..<numberOfRows {
            for column in 0..<numberOfRows {
                
                //從1開始，幫按鈕編號 tag用
                buttonNumber += 1
                
                //按鈕樣式
                let button: UIButton = {
                    let button = UIButton()
                    button.backgroundColor = .orange
                    button.tintColor = .white
                    button.layer.cornerRadius = 10
                    button.clipsToBounds = true
                    return button
                }()
                
                //每移動一格，就會加上間距和按鈕大小
                button.frame = CGRect(x: marginSize + CGFloat(column) * (marginSize + buttonSize),
                                       y: marginSize + CGFloat(row) * (marginSize + buttonSize),
                                       width: buttonSize, height: buttonSize)
                
                button.tag = buttonNumber
                buttons.append(button)
                button.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
                numberPadView.addSubview(button)
            }
        }
    }
    
    //機器產生BingoNumber
    func generateMachineRandom() {
        
        //產生亂數1-25
        var randomNum = String(Int.random(in: 1...upperRange))
        
        //不要重複
        while machineNumArr.contains(randomNum) {
            randomNum = String(Int.random(in: 1...upperRange))
        }
        machineNumArr.append(String(randomNum))
        machineLabel.text = "\(randomNum)"
        
        //把user有該數字的按鈕註記
        if userNumArr.contains(randomNum){
            
            let markedIndex = userNumArr.firstIndex(where: {$0 == randomNum})!
            buttons[markedIndex].backgroundColor = .lightGray
//            print("一樣囉！！", markedIndex+1)
            let row = markedIndex / numberOfRows
            let col = markedIndex % numberOfRows
            recordArr[row][col] = 1
            checkBingo(row: row, col: col)
        }
    }
    
    //檢查用
    func printMachineUser(){
        print(machineNumArr)
        print(userNumArr)
    }
    
    
    
    //每當按下重置按鈕，Bingo盤上的數字就會重新產生
    @objc func resetButtonPressed() {
        bingoLines = 0
        machineNumArr = []
        userNumArr = []
        
        //紀錄連線的空2D Array
        recordArr = [[Int]](repeating: [Int](repeating: 0, count: numberOfRows), count: numberOfRows)
        
        generateRandomNum()
        generateMachineRandom()
    }
    
    //重新產生Bingo盤上的亂數1-25
    func generateRandomNum() {

        //產生亂數1-25
        var randomNum = String(Int.random(in: 1...upperRange))

        for i in 0..<buttons.count {

            //不要重複
            while userNumArr.contains(randomNum) {
                randomNum = String(Int.random(in: 1...upperRange))
            }
            userNumArr.append(randomNum)
            buttons[i].setTitle("\(randomNum)", for: .normal)
            buttons[i].backgroundColor = .orange
        }
        
    }
    
    
    
    
    
    @objc func buttonPressed(_ sender: UIButton) {
        
        let tag = sender.tag - 1
        let row = tag / numberOfRows
        let col = tag % numberOfRows
        
        //判斷按鈕有沒有被按過
        if recordArr[row][col] != 1 {
            
            sender.backgroundColor = .lightGray
            
            if let buttonTitle = sender.titleLabel?.text {
                machineNumArr.append(buttonTitle)
            }
            
            recordArr[row][col] = 1
            checkBingo(row: row, col: col)
            
            // 使用者選完，再換機器給新數字
            generateMachineRandom()
        }
    }
    
    func checkBingo(row: Int, col: Int) {
                
        var horiLine = 0
        var vertLine = 0
        var forwardSlash = 0
        var backSlash = 0
        
        for i in 0..<numberOfRows {
            for j in 0..<numberOfRows {
                
                //檢查水平線
                if i == row {
                    if recordArr[i][j] == 1 {
                        horiLine += 1
                        if horiLine == numberOfRows {
                            bingoLines += 1
                        }
                    }
                }
                
                //檢查垂直線
                if j == col {
                    if recordArr[i][j] == 1 {
                        vertLine += 1
                        if vertLine == numberOfRows {
                            bingoLines += 1
                        }
                    }
                }
                
                //判斷正斜線
                if forwardDidConnect == false {
                    if i == j {
                        if recordArr[i][j] == 1 {
                            forwardSlash += 1
                            if forwardSlash == numberOfRows  {
                                bingoLines += 1
                                forwardDidConnect = true
                            }
                        }
                    }
                }
                
        
                //判斷反斜線
                if backDidConnect == false {
                    if (i + j) == numberOfRows - 1 {
                        if recordArr[i][j] == 1 {
                            backSlash += 1
                            if backSlash == numberOfRows {
                                bingoLines += 1
                                backDidConnect = true
                            }
                        }
                    }
                }
            }
        }
        
        //跳出你贏了的通知
        if bingoLines >= linesWin {
            
            print("Yes")
            
            let controller = UIAlertController(title: "You Win !", message: "", preferredStyle: .alert)
            let playAgainAction = UIAlertAction(title: "Play Again", style: .default) { _ in
                self.resetButtonPressed()
            }
            controller.addAction(playAgainAction)
            present(controller, animated: true)
        }
        
    }
    

    
}

