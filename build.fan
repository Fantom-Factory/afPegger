using build

class Build : BuildPod {

    new make() {
        podName = "afPegger"
        summary = "Parsing Expression Grammar (PEG) for when Regular Expressions just aren't enough!"
        version = Version("1.0.0")

        meta = [
            "pod.dis"       : "Pegger",
            "repo.tags"     : "system",
            "repo.public"   : "true"
        ]

        depends = [
            // ---- Core ------------------------
            "sys        1.0",

            // ---- Test ------------------------
            "xml        1.0",   // htmlParser
            "concurrent 1.0"    // htmlParser
        ]

        srcDirs = [`fan/`, `fan/internal/`, `fan/internal/rules/`, `fan/public/`, `test/`, `test/htmlparser/`]
        resDirs = [`doc/`]

        meta["afBuild.testPods"]    = "xml concurrent"
    }
}
