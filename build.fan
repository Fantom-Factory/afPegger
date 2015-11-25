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
	
		srcDirs = [`test/`, `test/htmlparser/`, `fan/`, `fan/public/`, `fan/internal/`, `fan/internal/rules/`]
		resDirs = [`doc/`]
	}
	
	@Target { help = "Compile to pod file and associated natives" }
	override Void compile() {
		// remove test pods from final build
		testPods := "xml concurrent".split
		depends = depends.exclude { testPods.contains(it.split.first) }
		super.compile
	}
}
