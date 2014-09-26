using build

class Build : BuildPod {

	new make() {
		podName = "afPegger"
		summary = "For when Regular Expressions just aren't enough!"
		version = Version("0.0.3")

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
			"xml 1.0",			// htmlParser
			"concurrent 1.0"	// htmlParser
		]
	
		srcDirs = [`test/`, `test/htmlparser/`, `fan/`, `fan/public/`, `fan/internal/`, `fan/internal/rules/`]
		resDirs = [,]
	}
	
	override Void compile() {
		// remove test pods from final build
		testPods := "xml concurrent".split
		depends = depends.exclude { testPods.contains(it.split.first) }
		super.compile
	}
}
