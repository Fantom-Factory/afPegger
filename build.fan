using build

class Build : BuildPod {

	new make() {
		podName = "afPegger"
		summary = "For when Regular Expressions just aren't enough!"
		version = Version("0.0.1")

		meta = [
			"proj.name"		: "Pegger",
			"tags"			: "system",
			"repo.private"	: "true"
		]

		depends = ["sys 1.0"]
		srcDirs = [`test/`, `fan/`, `fan/public/`, `fan/internal/`]
		resDirs = [,]

		docApi = true
		docSrc = true
	}
}
