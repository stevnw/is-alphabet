import nigui
import os, parsecsv, strutils, osproc, math

const playCommand = "paplay "

type
  AlphabetItem = tuple
    character: string
    pair: string
    audio: string

var items: seq[AlphabetItem] = @[]

var parser: CsvParser
parser.open("letters.csv")
while parser.readRow():
  items.add((parser.row[0].strip(), parser.row[1].strip(), parser.row[2].strip()))
parser.close()

proc playAudio(audioFile: string) =
  if fileExists(audioFile):
    discard execShellCmd(playCommand & audioFile & " 2>/dev/null")

proc startQuiz() =
  if fileExists("alphabet"):
    discard startProcess("./alphabet")
  elif fileExists("alphabet.exe"):
    discard startProcess("alphabet.exe")
  else:
    echo "Quiz executable not found!"

proc main() =
  app.init()
  
  let window = newWindow("Icelandic Alphabet")
  window.width = 600.scaleToDpi
  window.height = 500.scaleToDpi
  
  let mainContainer = newLayoutContainer(Layout_Vertical)
  window.add(mainContainer)
  
  let titleLabel = newLabel("Icelandic Alphabet")
  titleLabel.fontSize = 24
  mainContainer.add(titleLabel)
  
  let gridContainer = newLayoutContainer(Layout_Vertical)
  mainContainer.add(gridContainer)
  
  let columnsPerRow = 6
  let totalRows = int(ceil(items.len.float / columnsPerRow.float))
  
  for row in 0..<totalRows:
    let rowContainer = newLayoutContainer(Layout_Horizontal)
    gridContainer.add(rowContainer)
    
    for col in 0..<columnsPerRow:
      let index = row * columnsPerRow + col
      if index < items.len:
        let item = items[index]
        let button = newButton(item.pair)
        button.fontSize = 14
        button.widthMode = WidthMode_Expand
        button.heightMode = HeightMode_Expand
        
        proc createClickHandler(audioFile: string, character: string): proc(event: ClickEvent) =
          result = proc(event: ClickEvent) =
            # echo "Button pressed: ", character, " Audio: ", audioFile # debuig line, probs remove?
            playAudio(audioFile)
        
        button.onClick = createClickHandler(item.audio, item.character)
        
        rowContainer.add(button)
      else:
        let spacer = newControl()
        spacer.widthMode = WidthMode_Expand
        rowContainer.add(spacer)
  
  let quizButton = newButton("Start Quiz")
  quizButton.fontSize = 18
  quizButton.widthMode = WidthMode_Expand
  quizButton.onClick = proc(event: ClickEvent) =
    startQuiz()
  
  mainContainer.add(quizButton)
  
  window.show()
  app.run()

main()
