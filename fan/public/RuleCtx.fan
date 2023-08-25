
** (Advanced) 
** Handed to 'Rule' classes during the matching process. 
@Js
mixin RuleCtx {
	
	** Call to process a sub-rule. Returns 'true' if it matched successfully.
	abstract Bool process(Rule rule)
	
	** Consumes 1 character from the underlying input stream.
	abstract Int readChar()

	** Returns the current position in the underlying input stream.
	abstract Int currentPos()
	
	** Rolls back the underlying input stream to the given position. 
	abstract Void rollbackToPos(Int pos)

	** Returns 'true' if end-of-stream is reached. 
	abstract Bool eos()

	** Logs the given message to debug. It is formatted to be the same as the other Pegger debug messages. 
	abstract Void log(Str msg)

	** Returns a PEG specific 'ParseErr' to be thrown.
	abstract PegParseErr parseErr(Str errMsg)

	** Returns the string we are matching against. 
	abstract Str str()
}
