//
//@Js
//internal class NoOpRule : Rule {
//	private Bool	pass
//	
//	new make(Bool pass) {
//		this.pass	= pass
//	}
//	
//	override Bool doProcess(RuleCtx ctx) {
//		return pass
//	}
//
//	override Str _expression() {
//		"\\noop(${pass})"
//	}
//}
//
//@Js	// todo rename to LogRule ???
//internal class DumpRule : Rule {
//	private Str		msg
//	
//	new make(Str msg) {
//		this.msg	= msg
//	}
//	
//	override Bool doProcess(RuleCtx ctx) {
//		echo("DUMP: $msg")
//		ctx.log("DUMP: $msg")
//		return true
//	}
//
//	override Str _expression() {
//		"\\dump(${msg.toCode(null)})"
//	}
//}
//
//@Js
//internal class TraceRule : Rule {
//	// is this of any use?
//}
