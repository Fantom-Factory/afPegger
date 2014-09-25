using build

class Build : BuildPod {

	new make() {
		podName = "afPegger"
		summary = "For when Regular Expressions just aren't enough!"
		version = Version("0.0.1")

		meta = [
			"proj.name"		: "Pegger",
			"internal"		: "true",
			"tags"			: "system",
			"repo.private"	: "true"
		]

		depends = [
			"sys 1.0",

			// ---- Core ------------------------
			"afBeanUtils 1.0",
			
			// ---- Test ------------------------
			"xml 1.0",
			"concurrent 1.0"	// html2xml
		]
	
		srcDirs = [`test/`, `test/htmlparser/`, `fan/`, `fan/public/`, `fan/internal/`, `fan/internal/rules/`]
		resDirs = [,]
	}
}
