using build

class Build : BuildPod {

    new make() {
        podName = "afPegger"
        summary = "Parsing Expression Grammar (PEG) for when Regular Expressions just aren't enough!"
        version = Version("1.0.1")

        meta = [
            "pod.dis"       : "Pegger",
            "repo.tags"     : "system",
            "repo.public"   : "true"
        ]

        depends = [
            // ---- Core ------------------------
            "sys        1.0",

            // ---- Test ------------------------
            "concurrent 1.0"    // htmlParser
        ]

        srcDirs = [`fan/`, `fan/internal/`, `fan/internal/rules/`, `fan/public/`, `test/`]
        resDirs = [`doc/`, `res/`]

        meta["afBuild.testPods"]    = "xml concurrent"
    }
}
