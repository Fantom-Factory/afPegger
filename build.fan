using build

class Build : BuildPod {

	new make() {
		podName = "afPegger"
		summary = "For when Regular Expressions just aren't enough!"
		version = Version("0.1.0")

		meta = [
			"proj.name"		: "Pegger",
			"repo.internal"	: "true",
			"repo.tags"		: "system",
			"repo.public"	: "false"
		]

		depends = [
			"sys 1.0",

			// ---- Core ------------------------
			"afBeanUtils 1.0.8 - 1.0",	// for ArgNotFoundErr
			
			// ---- Test ------------------------
			"xml        1.0",	// htmlParser
			"concurrent 1.0"	// htmlParser
		]
	
		srcDirs = [`fan/`, `fan/internal/`, `fan/internal/rules/`, `fan/public/`, `test/`, `test/htmlparser/`]
		resDirs = [`doc/`]
		
		meta["afBuild.testPods"]	= "xml concurrent"
	}	
}
