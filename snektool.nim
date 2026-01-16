import std/[strutils, encodings, os], regex, nigui
var filePath = ""
let outputDir = "./samples/"
var file = ""
app.init()
var logs = newTextArea(" ")
logs.editable = false

proc addLog(text : string) =
    logs.text = logs.text & "\n" & text

proc openFlp(): string =
    var fileDialog = newOpenFileDialog()
    fileDialog.title = "Open FL Project"
    fileDialog.run()
    if fileDialog.files.len > 0:
        return fileDialog.files[0]
    else:
        return "Failed"

proc copySamplesByPattern(startPatt : string = "\0:\0\\"): string = 
    # TODO: optional flstudio-based samples copying
    var succFiles = 0
    var failFiles = 0
    if filePath != "":
        let prOutputDir = outputDir
        createDir(prOutputDir)
        if not (startPatt in file):
            return "File is invalid or empty"
        while startPatt in file:
            let startf = file.find(startPatt)-1
            var testpath = file.substr(startf, startf+250)
            # echo "FOUND ", testpath
            testpath = convert(testpath, "UTF-8", "UTF-16")
            # echo "TESTPATH1 ", testpath
            let endregex = re"\.wav|\.mp3|\.ogg"
            var m: RegexMatch
            var endf = -1
            if testpath.find(endregex, m):
                endf = m.boundaries.a
            let fullendf = startf+endf+3
            # echo "STARTF ", startf, " - ", "FULLENDF ", fullendf
            if endf > 0:
                testpath = testpath.substr(0, endf+3)
                if fileExists(testpath):
                    copyFile(testpath, prOutputDir & splitFile(testpath).name & splitFile(testpath).ext)
                    echo "+SAMPLE ", testpath
                    addLog("+SAMPLE " & testpath)
                    succFiles += 1
                else:
                    echo "!FAILED TO COPY ", testpath
                    addLog("!FAILED TO COPY " & testpath)
                    failFiles += 1
                file = file.substr(fullendf)
            else:
                file = file.substr(startf+2)
                continue
        addLog("================= Results\nSucc: " & intToStr(succFiles) & "\nFaiwwed: " & intToStr(failFiles) & "\nTotaw: " & intToStr(succFiles+failFiles))
        return "Finished!"
    else:
        return "File not found"

var window = newWindow("Snektool")
window.width = 350.scaleToDpi
window.height = 270.scaleToDpi
window.iconPath = "snektool.png"
window.resizable = false

var mainContainer = newLayoutContainer(Layout_Vertical)
mainContainer.padding = 6
mainContainer.width = window.width - 6*2
mainContainer.height = window.height - 10*2
window.add(mainContainer)

var pathLabel = newLabel("Open .flp fiwwe (pwease)")
pathLabel.minWidth = window.width - 6*2 - 30
pathLabel.fontSize = 20
mainContainer.add(pathLabel)

var startButton = newButton("Stawt :3")
startButton.enabled = false
startButton.onClick = proc(event: ClickEvent) =
    window.alert((copySamplesByPattern()), "Awert")

var openButton = newButton("Opew")
openButton.onClick = proc(event: ClickEvent) = 
    var res = openFlp()
    if res != "Failed":
        pathLabel.text = "Fiwwe: " & splitFile(res).name
        startButton.enabled = true
        startButton.focus()
        filePath = res
        file = readFile(res)
mainContainer.add(openButton)
openButton.focus()

mainContainer.add(startButton)
mainContainer.add(logs)
window.show()
app.run()
