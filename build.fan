using build

class Build : BuildPod {

    new make() {
        podName = "afPegger"
        summary = "Parsing Expression Grammar (PEG) for when Regular Expressions just aren't enough!"
        version = Version("1.1.9")

        meta = [
            "pod.dis"       : "Pegger",
            "repo.tags"     : "system",
            "repo.public"   : "true",
	
			// ---- SkySpark ----
			"ext.name"		: "afPegger",
			"ext.icon"		: "afPegger",
			"skyarc.icons"	: "true",
        ]

        depends = [
            // ---- Core ----
            "sys 1.0.70 - 1.0",
        ]

        srcDirs = [`fan/`, `fan/internal/`, `fan/internal/rules/`, `fan/public/`, `test/`]
        resDirs = [`doc/`, `svg/`]
		
		docApi  = true
		docSrc  = true
		
		meta["afBuild.docApi"]	= "true"
		meta["afBuild.docSrc"]	= "true"
    }
}
