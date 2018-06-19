import qbs
import qbs.File
import qbs.FileInfo
import qbs.TextFile

Project {
  id: main
  property string coreConfig
  property string releaseType

  Probe {
    id: info
    property string fileName: "info.json"
    property var data
    configure: {
      // making sure the info file exists
      if (!File.exists(fileName)){
        throw new Error("Cannot find: " + fileName)
      }

      // parsing info contents
      data = JSON.parse(new TextFile(fileName).readAll())
    }
  }

  Application {
    Group {
      qbs.installPrefix: {

        // building the target location
        targetPrefix = FileInfo.joinPaths(main.coreConfig, info.data.name, info.data.version)

        // making sure to never override a production release
        targetFullPath = FileInfo.joinPaths(qbs.installRoot, targetPrefix)
        if (main.releaseType == "production" && File.exists(targetFullPath)) {
          throw new Error("Cannot override an existent production release: " + targetFullPath)
        }
        console.info("Target: " + targetFullPath)

        return targetPrefix
      }

      Group {
          name: "Info File"
          files: [
            "info.json"
          ]
          qbs.install: true
          qbs.installSourceBase: "./"
      }

      Group {
          name: "Active Config"
          files: [
            "src/**"
          ]
          qbs.install: true
          qbs.installDir: "config"
          qbs.installSourceBase: "./src"
      }
    }
  }
}
