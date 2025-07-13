import nigui
import os, random, parsecsv
import strutils

const playCommand = "paplay "

type
  QuizItem = tuple
    character: string
    pair: string
    audio: string

var items: seq[QuizItem] = @[]

var parser: CsvParser
parser.open("letters.csv")
while parser.readRow():
  items.add((parser.row[0].strip(), parser.row[1].strip(), parser.row[2].strip()))
parser.close()

randomize()

proc getRandomPairs(exclude: string, count: int): seq[string] =
  var candidates: seq[string] = @[]
  for item in items:
    if item.pair != exclude:
      candidates.add(item.pair)
  candidates.shuffle()
  result = candidates[0..<min(count, candidates.len)]

proc playAudio(audioFile: string) =
  if fileExists(audioFile):
    discard execShellCmd(playCommand & audioFile & " 2>/dev/null")

proc main =
  app.init()
  let window = newWindow("Icelandic Quiz")
  window.width = 300.scaleToDpi
  window.height = 200.scaleToDpi
  
  let container = newLayoutContainer(Layout_Vertical)
  window.add(container)
  
  let audioButton = newButton("▶ Play Audio")
  audioButton.fontSize = 20
  audioButton.widthMode = WidthMode_Expand
  container.add(audioButton)
  
  var answerButtons: array[4, Button]
  for i in 0..3:
    answerButtons[i] = newButton("")
    answerButtons[i].fontSize = 18
    answerButtons[i].widthMode = WidthMode_Expand
    container.add(answerButtons[i])
  
  var currentItem: QuizItem
  var currentCorrectText: string

  proc newQuestion() =
    currentItem = items.sample()
    currentCorrectText = currentItem.pair
    var options = @[currentItem.pair]
    options.add(getRandomPairs(currentItem.pair, 3))
    options.shuffle()
    for i in 0..3:
      answerButtons[i].text = options[i]
  
  proc createClickHandler(buttonIndex: int): proc(event: ClickEvent) =
    result = proc(event: ClickEvent) =
      if answerButtons[buttonIndex].text == currentCorrectText:
        window.alert("Correct!")
        newQuestion()
      else:
        window.alert("Wrong! Try again.")
  
  for i in 0..3:
    answerButtons[i].onClick = createClickHandler(i)
  
  audioButton.onClick = proc(event: ClickEvent) =
    playAudio(currentItem.audio)
  
  newQuestion()
  window.show()
  app.run()

main()
